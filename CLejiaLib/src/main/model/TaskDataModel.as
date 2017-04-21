package main.model
{
	import flash.display.Stage3D;
	import flash.events.Event;
	
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.resources.BitmapTextureResource;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.model.BaseDataModel;
	
	import l3dbuild.geometry.L3DLoadHelper;
	
	import main.dict.EventTypeDict;
	import main.dict.Object3DDict;
	import main.model.vo.task.CTaskVO;
	import main.model.vo.task.ITaskVO;

	[Event(name="LoadComplete", type="flash.events.Event")]
	/**
	 * 任务数据模型类
	 * @author cloud
	 */
	public class TaskDataModel extends BaseDataModel
	{
		private var _loadQueue:Array;
		private var _loader:L3DLoadHelper;
		private var _curType:uint;
		private var _curMesh:L3DMesh;
		private var _curMaterial:Material;
		private var _curTaskVos:Vector.<ITaskVO>;
		private var _isLoadEnd:Boolean=true;
		
		public function get curType():uint
		{
			return _curType;
		}
		public function get curMesh():L3DMesh
		{
			return _curMesh;
		}
		public function get curMaterial():Material
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
			_loadQueue=new Array();
			_curTaskVos=new Vector.<ITaskVO>();
		}
		
		private function onLoadComplete(evt:Event):void
		{
			if(_curMesh==null)
			{
				doLoadMeshSuccess();
			}
			else
			{
				doLoadMaterialSuccess();
			}
		}
		
		private function doLoadMeshSuccess():void
		{
			_curMesh=_loader.mesh;
			var index:int=_curMesh.Code.indexOf("-");
			if(index>0)
			{
				var code:String=_curMesh.Code.slice(index+1);
				_loader.loadType=L3DBitmapTextureResource;
				_loader.LoadByCode(code);
			}
		}
		
		private function doLoadMaterialSuccess():void
		{
			var datas:Vector.<ICData>=getDatasByType(_curType);
			for each(var taskVo:ITaskVO in datas)
			{
				if(taskVo.code==_curMesh.Code)
				{
					_curTaskVos.push(taskVo);
				}
			}
			switch(_curType)
			{
				case Object3DDict.OBJECT3D_WAIST:
					_curMaterial=new TextureMaterial(new BitmapTextureResource(_loader.l3dBitmapTextureResource.data));
					break;
			}
			this.dispatchEvent(new Event(EventTypeDict.EVENT_LOADCOMPLETE));
			
			loadNext();
		}
		private function doStartLoad():void
		{
			_loader.loadType=L3DMesh;
			var index:int=_loadQueue.length-1;
			_loader.LoadByCode(_loadQueue[index]);
			_curType=_loadQueue[index-1];
		}
		private function loadNext():void
		{
			_curMesh=null;
			_curMaterial=null;
			_curTaskVos.length=0;
			_curType=0;
			_loadQueue.splice(_loadQueue.length-2,2);
			if(_loadQueue.length>0)
			{
				doStartLoad();
			}
			else
			{
				//加载队列长度为0，标记加载完成
				_isLoadEnd=true;
				_loader.Dispose();
			}
		}
		/**
		 * 添加任务 
		 * @param vo		任务数据
		 * @param stage3d	3D舞台
		 * 
		 */		
		public function addTask(vo:CTaskVO,stage3d:Stage3D):void
		{
			if(_loader==null)
			{
				_loader=new L3DLoadHelper(stage3d);
				_loader.addEventListener(Event.COMPLETE,onLoadComplete);
			}
			var index:int=_loadQueue.indexOf(vo.code);
			//添加到加载队列
			if(index<0)
			{
				_loadQueue.push(vo.type);
				_loadQueue.push(vo.code);
			}
			//缓存任务数据
			addCacheData(vo);
			if(_isLoadEnd)
			{
				_isLoadEnd=false;
				doStartLoad();
			}
		}

	}
}