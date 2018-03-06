package main.model
{
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import L3DLibrary.L3DLibrary;
	
	import alternativa.engine3d.materials.TextureMaterial;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.datas.maps.CHashMap;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.mvcs.model.BaseDataModel;
	import cloud.core.utils.CDebugUtil;
	
	import l3dbuild.geometry.LoadHelper;
	
	import main.dict.CParamDict;
	import main.dict.EventTypeDict;
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.ITaskVO;
	
	import tools.clj.dict.CL3DConstDict;
	
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
		private var _loader:LoadHelper;
		private var _stage3d:Stage3D;
		private var _curIndex:int;
		private var _curCode:String;
		private var _curMaterialCode:String;
		private var _curType:uint;
		private var _curMesh:L3DMesh;
		private var _curMaterial:TextureMaterial;
		private var _curTaskVos:Vector.<ITaskVO>;
		private var _cacheDatas:CHashMap;
		private var _isLoadEnd:Boolean=true;
		/**
		 * 是否需要加载 
		 * @return	Boolean
		 * 
		 */
		public function get	canLoad():Boolean
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
		public function get curMaterial():TextureMaterial
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
			_cacheDatas=new CHashMap();
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
				_curMesh.PreviewBuffer=_loader.materialInfo.previewBuffer;
				if(CParamDict.Instance.isLoftingLineByStr(_curMesh.family))
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
				CDebugUtil.Instance.traceStr("加载模型成功："+_curCode);
			}
			else
			{
				_curMaterial=null;
				doComplete();
			}
		}
		
		private function doLoadMaterialSuccess():void
		{
			var textureResource:L3DBitmapTextureResource=L3DUtils.GetL3DBitmapTextureResourceInstance(L3DUtils.GetResourceUniqueID(_curCode,_loader.l3dBitmapTextureResource.Url),_loader.l3dBitmapTextureResource.data,_stage3d,L3DLibrary.L3DLibrary.TextureForceMode,L3DLibrary.L3DLibrary.runtimeMode,CL3DConstDict.SUFFIX_DIFFUSE);
//			var textureResource:L3DBitmapTextureResource=new L3DBitmapTextureResource(_loader.l3dBitmapTextureResource.data);
			textureResource.Url=_loader.l3dBitmapTextureResource.Url;
			_curMaterial=new TextureMaterial(textureResource);
			doComplete();
		}
		private function doComplete():void
		{
			//获取当前下载任务对应的任务数据集合
			var datas:Array=_cacheDatas.get(_curType) as Array;
			var quotesVo:ICQuotes;
			var vo:ICObject3D;
			var tmp:Vector3D;
			for each(var taskVo:ITaskVO in datas)
			{
				quotesVo=taskVo as ICQuotes;
				vo=taskVo as ICObject3D;
				if(taskVo.code==_curCode && taskVo.material==_curMaterialCode)
				{
					if(quotesVo!=null)
					{
						if(_curMesh!=null)
						{
							quotesVo.price=_curMesh.Price;
							quotesVo.qName=_curMesh.name;
							quotesVo.previewBuffer=_curMesh.PreviewBuffer;
							quotesVo.qLength=_curMesh.Length;
							quotesVo.qWidth=_curMesh.Width;
							quotesVo.qHeight=_curMesh.Height;
							CVector.SetTo(quotesVo.size,_curMesh.Height,_curMesh.Length,_curMesh.Width);
							if(vo!=null)
							{
								if(vo.length==0)
									vo.length=_curMesh.Length;
								if(vo.width==0)
									vo.width=_curMesh.Width;
								if(vo.height==0)
									vo.height=_curMesh.Height;
							}
						}
						else
						{
							quotesVo.qType=CParamDict.QUOTES_NESTING_BOARD;
							quotesVo.price=_loader.materialInfo.price;
							quotesVo.qName=_loader.materialInfo.name;
							quotesVo.previewBuffer=_loader.materialInfo.previewBuffer;
							tmp=_loader.materialInfo.GetSizeVector();
							CVector.SetTo(quotesVo.size,tmp.x,tmp.y,tmp.z);
						}
					}
					_curTaskVos.push((taskVo as CBaseTaskObject3DVO));
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
//				if(!hasCache(_curMaterialCode))
//				{
//					excuteLoad(false);
//				}
//				else
//				{
//					doLoadMaterialSuccess();
//				}
				if(_curMaterialCode.length!=0)
					excuteLoad(false);
				else
					loadNext();
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
			if(!_cacheDatas.containsKey(vo.type))
			{
				_cacheDatas.put(vo.type,[]);
			}
			_cacheDatas.get(vo.type).push(vo);
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
			_stage3d=stage3d;
			if(_loader==null)
			{
				_loader=new LoadHelper(stage3d);
				_loader.addEventListener(Event.COMPLETE,onLoadComplete);
			}
		}
		override public function clearAllCache():void
		{
			if(_loader==null) return;
			if(!_isLoadEnd)
			{
				_loader.pause=true;
			}
			_curMesh=null;
			_curMaterial=null;
			_curTaskVos.length=0;
			_curType=0;
			_loadQueue.length=0;
			var datas:Array;
			while(_cacheDatas.size>0)
			{
				datas=_cacheDatas.values[0];
				for each(var vo:ICData in datas)
				{
					if(vo.isLife)
						vo.clear();
				}
				datas.length=0;
				_cacheDatas.remove(_cacheDatas.keys[0]);
			}
		}
	}
}