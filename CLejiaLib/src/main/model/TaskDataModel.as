package main.model
{
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.model.BaseDataModel;
	import cloud.core.utils.CDebug;
	
	import l3dbuild.geometry.L3DLoadHelper;
	
	import main.dict.EventTypeDict;
	import main.extension.CTextureMaterial;
	import main.model.vo.task.CParam3DTaskVO;
	import main.model.vo.task.CUnit3DTaskVO;
	import main.model.vo.task.ITaskVO;
	
	import wallDecorationModule.dict.CDecorationParamDict;
	import wallDecorationModule.interfaces.ICQuotes;

	[Event(name="LoadComplete", type="flash.events.Event")]
	[Event(name="LoadAllComplete", type="flash.events.Event")]
	/**
	 * 任务数据模型类
	 * @author cloud
	 */
	public class TaskDataModel extends BaseDataModel
	{
		private var _cacheDic:Dictionary;
		private var _loadQueue:Array;
		private var _loader:L3DLoadHelper;
		private var _stage3d:Stage3D;
		private var _curIndex:int;
		private var _curCode:String;
		private var _curMaterialCode:String;
		private var _curType:uint;
		private var _curMesh:L3DMesh;
		private var _curMaterial:CTextureMaterial;
		private var _curTaskVos:Vector.<ITaskVO>;
		private var _isLoadEnd:Boolean=true;
		/**
		 * 是否需要加载 
		 * @return	 Boolean
		 * 
		 */
		public function get	 canLoad():Boolean
		{
			return _loadQueue.length>0;
		}
		public function get isLoadEnd():Boolean
		{
			return _isLoadEnd;
		}
		public var loadMode:String="_";
		
		public function get stage3d():Stage3D
		{
			return _stage3d;
		}
		public function get curCode():String
		{
			return _curCode; 
		}
		public function get curMaterialCode():String
		{
			return _curMaterialCode;
		}
		public function get curType():uint
		{
			return _curType;
		}
		public function get curMesh():L3DMesh
		{
			return _curMesh;
		}
		public function get curMaterial():CTextureMaterial
		{
			return _curMaterial;
		}
		public function get curTaskVos():Vector.<ITaskVO>
		{
			return _curTaskVos;
		}
		
		public function TaskDataModel()
		{
			super();
			_cacheDic=new Dictionary();
			_loadQueue=new Array();
			_curTaskVos=new Vector.<ITaskVO>();
		}
		/**
		 * 执行下载 
		 * @param isLoadMesh	执行的下载是否是模型，如果下载纹理图片，值为false
		 * 
		 */		
		private function excuteLoad(isLoadMesh:Boolean):void
		{
			if(isLoadMesh)
			{
				_loader.loadType=L3DMesh;
				_loader.LoadByCode(_curCode);
			}
			else
			{
				_loader.loadType=L3DBitmapTextureResource;
				_loader.LoadByCode(_curMaterialCode);
			}
		}
		private function onLoadComplete(evt:Event):void
		{
			if(_curCode.length>0 && _curMesh==null)
			{
				doLoadMeshSuccess();
			}
			else if(_curMaterialCode.length>0)
			{
				doLoadMaterialSuccess();
			}
		}
		private function hasCache(key:String):Boolean
		{
			return _cacheDic.hasOwnProperty(key);
		}
		private function getCache(key:String):Object
		{
			return _cacheDic[key];
		}
		private function toCache(key:String,source:Object):void
		{
			_cacheDic[key]=source;
		}
		private function doLoadMeshSuccess():void
		{
			if(!hasCache(_curCode))
			{
				_curMesh=_loader.mesh;
				if(CDecorationParamDict.instance.isLoftingLineByStr(_curMesh.family))
				{
					var num:Number=_curMesh.Length;
					_curMesh.Length=_curMesh.Width;
					_curMesh.Width=_curMesh.Height;
					_curMesh.Height=num;
				}
				toCache(_curCode,_curMesh);
			}
			else
			{
				_curMesh=getCache(_curCode) as L3DMesh;
			}
			//处理纹理图片
			if(_curMaterialCode.length>0)
			{
				if(!hasCache(_curMaterialCode))
				{
					//下载纹理图片
					excuteLoad(false);
				}
				else
				{
					//执行加载成功,
					doLoadMaterialSuccess();
				}
				CDebug.instance.traceStr("加载模型成功："+_curCode);
			}
			else
			{
				CDebug.instance.throwError("TaskDataModel","doLoadMeshSuccess","code",String(_curCode+" 格式不正确，无法加载对应纹理"));
			}
		}
		
		private function doLoadMaterialSuccess():void
		{
			if(!hasCache(_curMaterialCode))
			{
				var textureResource:L3DBitmapTextureResource=new L3DBitmapTextureResource(_loader.l3dBitmapTextureResource.data);
				textureResource.Url=_loader.l3dBitmapTextureResource.Url;
				_curMaterial=new CTextureMaterial(textureResource);
				toCache(_curMaterialCode,_curMaterial);
			}
			else
			{
				_curMaterial=getCache(_curMaterialCode) as CTextureMaterial;
			}
			//获取当前下载任务对应的任务数据集合
			var datas:Vector.<ICData>=getCacheDatasByType(_curType);
			var quotesVo:ICQuotes;
			for each(var taskVo:ITaskVO in datas)
			{
				quotesVo=taskVo as ICQuotes;
				if(taskVo.code==_curCode && taskVo.material==_curMaterialCode)
				{
					if(quotesVo!=null)
					{
						if(_curMesh!=null)
						{
							quotesVo.price=_curMesh.Price;
							quotesVo.name=_curMesh.name;
							quotesVo.previewBuffer=_loader.materialInfo.previewBuffer;
							quotesVo.qLength=_curMesh.Length;
							quotesVo.qWidth=_curMesh.Width;
							quotesVo.qHeight=_curMesh.Height;
						}
						else
						{
							quotesVo.price=_loader.materialInfo.price;
							quotesVo.name=_loader.materialInfo.name;
							quotesVo.previewBuffer=_loader.materialInfo.previewBuffer;	
						}
					}
					if(taskVo is CParam3DTaskVO)
					{
						_curTaskVos.push((taskVo as CParam3DTaskVO).clone());
					}
					else if(taskVo is CUnit3DTaskVO)
					{
						_curTaskVos.push((taskVo as CUnit3DTaskVO).clone());
					}
				}
			}	
			
			this.dispatchEvent(new Event(EventTypeDict.EVENT_LOADCOMPLETE));
			loadNext();
		}
		private function doStartLoad():void
		{
			if(_loadQueue.length==0) return;
			_isLoadEnd=false;
			_curIndex=_loadQueue.length-1;
			_curCode=_loadQueue[_curIndex];
			_curMaterialCode=_loadQueue[_curIndex-1];
			_curType=_loadQueue[_curIndex-2];
			if(_curCode.length==0)
			{
				//没有模型code，处理纹理图片是否下载
				if(!hasCache(_curMaterialCode))
				{
					excuteLoad(false);
				}
				else
				{
					doLoadMaterialSuccess();
				}
			}
			else
			{
				//处理模型是否下载
				if(!hasCache(_curCode))
				{
					excuteLoad(true);
				}
				else
				{
					doLoadMeshSuccess();
				}
			}
		}
		private function doPauseLoad():void
		{
			_isLoadEnd=true;
		}
		
		private function loadNext():void
		{
			if(_isLoadEnd) return;
			_curType=0;
			_curCode=null;
			_curMaterialCode=null;
			_curMesh=null;
			_curMaterial=null;
			_curTaskVos.length=0;
			_loadQueue.splice(_curIndex-2,3);
			if(_loadQueue.length>0)
			{
				doStartLoad();
			}
			else
			{
				//加载队列长度为0，标记加载完成
				_isLoadEnd=true;
//				_loader.Dispose();
				if(this.hasEventListener(EventTypeDict.EVENT_LOADALLCOMPLETE))
					this.dispatchEvent(new Event(EventTypeDict.EVENT_LOADALLCOMPLETE));
			}
		}
		/**
		 * 添加任务 
		 * @param vo		任务数据
		 * @param stage3d	3D舞台
		 * 
		 */		
		public function addTask(vo:ITaskVO):void
		{
			if(vo.code.length==0 && vo.material.length==0) return;
			var index:int=vo.code.indexOf(loadMode);
			if(index>-1)
			{
				var idx:int=vo.code.indexOf(loadMode,index+1);
				if(idx<0)
					vo.material=vo.code.slice(index+1);
				else
					vo.material=vo.code.slice(index+1,idx);
				vo.code=vo.code.slice(0,index);
			}
			var canAdd:Boolean=true;
			for(var i:int=0; i<_loadQueue.length; i+=3)
			{
				if(_loadQueue[i]==vo.type && _loadQueue[i+1]==vo.material && _loadQueue[i+2]==vo.code)
				{
					canAdd=false;
					break;
				}
			}
			if(canAdd)
			{
				_loadQueue.push(vo.type);
				_loadQueue.push(vo.material);
				_loadQueue.push(vo.code);
			}
			//缓存任务数据
			addCacheData(vo);
			
		}
		public function startLoad():void
		{
			if(_isLoadEnd)
			{
				doStartLoad();
			}
		}
		public function pauseLoad():void
		{
			if(!_isLoadEnd)
			{
				doPauseLoad();
			}
		}
		public function initLoader(stage3d:Stage3D):void
		{
			if(_loader==null)
			{
				_stage3d=stage3d;
				_loader=new L3DLoadHelper(stage3d);
				_loader.addEventListener(Event.COMPLETE,onLoadComplete);
			}
		}
		override public function clearCache():void
		{
			if(_loader==null) return;
			if(!_isLoadEnd)
			{
				_loader.pause=true;
			}
//			_loader.Dispose();
			_curMesh=null;
			_curMaterial=null;
			_curTaskVos.length=0;
			_curType=0;
			_loadQueue.length=0;
			super.clearCache();
		}
	}
}