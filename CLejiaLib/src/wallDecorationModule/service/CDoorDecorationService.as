package wallDecorationModule.service
{
	import flash.display.Stage3D;
	import flash.events.Event;
	
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.datas.maps.CHashMap;
	
	import main.dict.EventTypeDict;
	import main.model.vo.task.CBaseTaskObject3DVO;
	
	import utils.CParamUtil;
	
	import wallDecorationModule.interfaces.ICDecorationService;
	import wallDecorationModule.model.CDoorModel;
	
	/**
	 * 门装修服务类
	 * @author cloud
	 * @2017-8-30
	 */
	public class CDoorDecorationService implements ICDecorationService
	{
		private var _isRunning:Boolean;
		private var _l3dModel:L3DModel;
		
		/**
		 * 任务数据模型 
		 */		
		private var _doorModel:CDoorModel;
		/**
		 * 下载全部完成后的回调函数 
		 */		
		private var _loadAllCompleteCallback:Function;
		/**
		 * 渲染模型的回调函数 
		 */		
		private var _renderViewCallback:Function;
		
		public function get allPlanDatas():CHashMap
		{
			return _doorModel.allPlanDatas;
		}
		
		public function get invalidPlanRenderData():Boolean
		{
			return _doorModel.invalidPlanRenderData;
		}
		
		public function set invalidPlanRenderData(value:Boolean):void
		{
			_doorModel.invalidPlanRenderData=value;
		}
		
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		public function CDoorDecorationService()
		{
			_l3dModel=new L3DModel();
			_doorModel=new CDoorModel();
		}
		
		private function createMeshHandler(evt:Event):void
		{
			var parentMeshVos:Vector.<CBaseTaskObject3DVO>;
			var parentMap:CHashMap;
			var parentMesh:Mesh;
			var parentL3DMesh:L3DMesh;
			var key:String;
			parentMap=new CHashMap();
			for each(var taskVo:CBaseTaskObject3DVO in _doorModel.curTaskVos)
			{
				key=CParamUtil.Instance.getUniqueKey(taskVo);
				if(!parentMap.containsKey(key))
				{
					parentMap.put(key,new Mesh());
				}
			}
			for each(key in  parentMap.keys)
			{
				parentMesh=parentMap.get(key) as Mesh;
				parentMeshVos=new Vector.<CBaseTaskObject3DVO>();
				for each(taskVo in _doorModel.curTaskVos)
				{
					if(CParamUtil.Instance.getUniqueKey(taskVo) != key) continue;
					CParamUtil.Instance.createParamMesh(taskVo,_doorModel.curMesh,_doorModel.curMaterial,parentMesh,parentMeshVos,_doorModel.addTask);
				}
				_l3dModel.Import(parentMesh);
				parentL3DMesh=_l3dModel.Export(_doorModel.stage3d);
				if(parentL3DMesh)
				{
					CParamUtil.Instance.dealClapboardL3DMesh(parentL3DMesh,parentMeshVos,_doorModel.curMesh,_doorModel.curMaterial,_doorModel.curCode,_doorModel.curType);
					if(_renderViewCallback!=null)
						_renderViewCallback.call(null,parentL3DMesh);
				}
			}
			parentMap.clear();
			parentMap=null;
		}
		private function createPreviewMeshHandler():void
		{

		}
		/**
		 * 设置xml计划数据集合 
		 * @param dataMap
		 * 
		 */		
		public function setXmlPlanDatas(dataMap:CHashMap):void
		{
			_doorModel.allPlanDatas||=dataMap;
		}
		public function deserializeXML(xml:XML):void
		{
			_doorModel.deserializeXML(xml,null);
		}
		public function showPreview(planData:Object,loadAllCompleteCallback:Function,renderMeshCallback:Function):Boolean
		{
			if(_doorModel.excutePreviewPlan(planData))
			{
				if(renderMeshCallback!=null)
				{
					_renderViewCallback=renderMeshCallback;
					addEventListener(EventTypeDict.EVENT_LOADCOMPLETE,createMeshHandler);
				}
				if(loadAllCompleteCallback!=null)
				{
					_loadAllCompleteCallback=loadAllCompleteCallback;
					addEventListener(EventTypeDict.EVENT_LOADALLCOMPLETE,loadAllCompleteCallback);
				}
				return true;
			}
			return false;
		}
		public function showView3D(planDatas:CHashMap,loadAllCompleteCallback:Function,renderMeshCallback:Function):Boolean
		{
			setXmlPlanDatas(planDatas);
			if(_doorModel.excuteDataCollection())
			{
				if(renderMeshCallback!=null)
				{
					_renderViewCallback=renderMeshCallback;
					addEventListener(EventTypeDict.EVENT_LOADCOMPLETE,createMeshHandler);
				}
				if(loadAllCompleteCallback!=null)
				{
					_loadAllCompleteCallback=loadAllCompleteCallback;
					addEventListener(EventTypeDict.EVENT_LOADALLCOMPLETE,loadAllCompleteCallback);
				}
				return true;
			}
			return false;
		}
		/**
		 * 关闭3D护墙板模块展示 
		 * 
		 */		
		public function closeView3D():void
		{
			removeEventListener(EventTypeDict.EVENT_LOADCOMPLETE,createMeshHandler);
			removeEventListener(EventTypeDict.EVENT_LOADALLCOMPLETE,_loadAllCompleteCallback);
			_loadAllCompleteCallback=null;
			_renderViewCallback=null;
			_doorModel.invalidPlanRenderData=true;
		}
		/**
		 * 删除参数化门模型数据 
		 * @param taskVo
		 * 
		 */		
		public function removeDecorationMeshData(mesh:L3DMesh):void
		{
			if(!(mesh.userData2[0] is CBaseTaskObject3DVO)) return;
//			_doorModel.removePlanData(mesh.userData2[0] as CParamPartVO);
		}
		public function initDecorationService(stage3d:Stage3D):void
		{
			_doorModel.initLoader(stage3d);
		}
		
		public function addEventListener(type:String, func:Function):void
		{
			_doorModel.addEventListener(type,func);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return _doorModel.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, func:Function):void
		{
			_doorModel.removeEventListener(type,func);
		}
		
		public function excuteDecoration():void
		{
			_doorModel.startLoad();
		}
		
		public function clearModel():void
		{
			_doorModel.clearAll();
		}

		public function start():void
		{
			_isRunning=true;
		}
		
		public function stop():void
		{
			_isRunning=false;
		}
		
		public function updateByFrame(startTime:Number=0, frameTime:Number=0):void
		{
		}
	}
}