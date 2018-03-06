package wallDecorationModule.service
{
	import flash.display.Stage3D;
	import flash.events.Event;
	
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.datas.maps.CHashMap;
	
	import main.dict.EventTypeDict;
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParamPartVO;
	
	import utils.CParamUtil;
	
	import wallDecorationModule.interfaces.ICDecorationService;
	import wallDecorationModule.model.CClapboardModel;
	
	/**
	 * 护墙板装修服务类
	 * @author cloud
	 */
	public class CClapboardDecorationService implements ICDecorationService
	{
		private var _isRunning:Boolean;
		private var _l3dModel:L3DModel;

		/**
		 * 任务数据模型 
		 */		
		protected var _clapboardModel:CClapboardModel;
		/**
		 * 下载全部完成后的回调函数 
		 */		
		private var _loadAllCompleteCallback:Function;
		/**
		 * 渲染模型的回调函数 
		 */		
		private var _renderViewCallback:Function;

		public function get invalidPlanRenderData():Boolean
		{
			return _clapboardModel.invalidPlanRenderData;
		}
		public function set invalidPlanRenderData(value:Boolean):void
		{
			_clapboardModel.invalidPlanRenderData=value;
		}
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		public function CClapboardDecorationService()
		{
			_l3dModel=new L3DModel();
			_clapboardModel=new CClapboardModel();
		}
		/**
		 * 创建渲染用模型 
		 * @param evt
		 * 
		 */		
		private function createMeshHandler(evt:Event):void
		{
			var parentMeshVos:Vector.<CBaseTaskObject3DVO>;
			var parentMap:CHashMap;
			var parentMesh:Mesh;
			var parentL3DMesh:L3DMesh;
			var key:String;
			parentMap=new CHashMap();
			for each(var taskVo:CBaseTaskObject3DVO in _clapboardModel.curTaskVos)
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
				for each(taskVo in _clapboardModel.curTaskVos)
				{
					if(CParamUtil.Instance.getUniqueKey(taskVo) != key) continue;
					CParamUtil.Instance.createParamMesh(taskVo,_clapboardModel.curMesh,_clapboardModel.curMaterial,parentMesh,parentMeshVos,_clapboardModel.addTask);
				}
				_l3dModel.Import(parentMesh);
				parentL3DMesh=_l3dModel.Export(_clapboardModel.stage3d);
				if(parentL3DMesh)
				{
					CParamUtil.Instance.dealClapboardL3DMesh(parentL3DMesh,parentMeshVos,_clapboardModel.curMesh,_clapboardModel.curMaterial,_clapboardModel.curCode,_clapboardModel.curType);
					if(_renderViewCallback!=null)
						_renderViewCallback.call(null,parentL3DMesh);
				}
			}
			parentMap.clear();
			parentMap=null;
		}
		/**
		 * 设置xml计划数据集合 
		 * @param dataMap
		 * 
		 */		
		public function setXmlPlanDatas(dataMap:CHashMap):void
		{
			_clapboardModel.allPlanDatas||=dataMap;
		}
		/**
		 * 展示3D护墙板模块
		 * @param planDatas	护墙板计划数据集合
		 * @param loadAllCompleteCallback		
		 * @param renderMeshCallback
		 * @return Boolean
		 * 
		 */		
		public function showView3D(planDatas:CHashMap,loadAllCompleteCallback:Function,renderMeshCallback:Function):Boolean
		{
			setXmlPlanDatas(planDatas);
			if(_clapboardModel.excuteDataCollection())
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
			if(_loadAllCompleteCallback!=null)
				removeEventListener(EventTypeDict.EVENT_LOADALLCOMPLETE,_loadAllCompleteCallback);
			_loadAllCompleteCallback=null;
			_renderViewCallback=null;
			_clapboardModel.invalidPlanRenderData=true;
		}
		/**
		 * 删除护墙板装修模型数据 
		 * @param taskVo
		 * 
		 */		
		public function removeDecorationMeshData(mesh:L3DMesh):void
		{
			if(!(mesh.userData2[0] is CBaseTaskObject3DVO)) return;
			_clapboardModel.removePlanData(mesh.userData2[0] as CParamPartVO);
		}
		
		public function clearModel():void
		{
			_clapboardModel.clearAll();
		}
		public function excuteDecoration():void
		{
			_clapboardModel.startLoad();
		}
		public function stop():void
		{
			_isRunning=false;
		}
		public function start():void
		{
			_isRunning=true;
		}
		/**
		 * 初始化装修 
		 * @param stage3d
		 * 
		 */		
		public function initDecorationService(stage3d:Stage3D):void
		{
			_clapboardModel.initLoader(stage3d);
		}
		public function addEventListener(type:String,func:Function):void
		{
			_clapboardModel.addEventListener(type,func);
		}
		public function hasEventListener(type:String):Boolean
		{
			return _clapboardModel.hasEventListener(type);
		}
		public function removeEventListener(type:String,func:Function):void
		{
			_clapboardModel.removeEventListener(type,func);
		}
		public function updateByFrame(startTime:Number=0, frameTime:Number=0):void
		{
		}
	}
}