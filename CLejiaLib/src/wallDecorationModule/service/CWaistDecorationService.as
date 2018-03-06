package wallDecorationModule.service
{
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.utils.CVectorUtil;
	
	import main.dict.EventTypeDict;
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.ITaskVO;
	
	import utils.CMeshUtil;
	
	import wallDecorationModule.interfaces.ICDecorationService;
	import wallDecorationModule.model.CWaistModel;
	import wallDecorationModule.model.vo.CWaistLineVO;
	
	/**
	 * 装修服务类
	 * @author cloud
	 */
	public class CWaistDecorationService implements ICDecorationService
	{
		private var _l3dModel:L3DModel;
		private var _waistModel:CWaistModel;
		private var _isRunning:Boolean;
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
			return _waistModel.invalidPlanRenderData;
		}
		public function set invalidPlanRenderData(value:Boolean):void
		{
			_waistModel.invalidPlanRenderData=value;
		}
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		public function CWaistDecorationService()
		{
			_l3dModel=new L3DModel();
			//任务数据模型
			_waistModel=new CWaistModel();
			_waistModel.loadMode="-";
		}

		/**
		 * 任务数据包括了创建区域，执行此方法 
		 * 
		 */		
		private function createMeshHandler(evt:Event):void
		{
			var parentMesh:Mesh;
			var parentMeshVos:Vector.<CBaseTaskObject3DVO>;
			parentMesh=new Mesh();
			parentMeshVos=new Vector.<CBaseTaskObject3DVO>();
			var dir:CVector=CVector.CreateOneInstance();
			var startPos:CVector=CVector.CreateOneInstance();
			var endPos:CVector=CVector.CreateOneInstance();
			var toward:Vector3D;
			var paths:Vector.<Vector3D>;
			for each(var taskVo:CWaistLineVO in _waistModel.curTaskVos)
			{
//				taskVo.z+=taskVo.height*.5;
				CVector.Copy(dir,taskVo.direction);
				CVector.Scale(dir,taskVo.length*.5);
				CVector.SetTo(endPos,taskVo.x+dir.x,taskVo.y+dir.y,taskVo.z+dir.z);
				CVector.SetTo(startPos,taskVo.x-dir.x,taskVo.y-dir.y,taskVo.z-dir.z);
				paths=new Vector.<Vector3D>();
				paths.push(new Vector3D(taskVo.x-dir.x-dir.x,taskVo.y-dir.y-dir.y,taskVo.z-dir.z-dir.z),
					new Vector3D(taskVo.x-dir.x,taskVo.y-dir.y,taskVo.z-dir.z),
					new Vector3D(taskVo.x+dir.x,taskVo.y+dir.y,taskVo.z+dir.z),
					new Vector3D(taskVo.x+dir.x+dir.x,taskVo.y+dir.y+dir.y,taskVo.z+dir.z+dir.z));
				CVector.Normalize(dir);
				toward=CVectorUtil.Instance.transformToVector3D(dir).crossProduct(Vector3D.Z_AXIS);
				subMesh=CMeshUtil.Instance.createLoftingLineByPaths(_waistModel.curMesh,_waistModel.curMaterial,paths,new Vector3D(-dir.x,-dir.y,-dir.z),toward);
				subMesh.name=taskVo.qName;
				parentMesh.addChild(subMesh);
			}
			dir.back();
			startPos.back();
			endPos.back();
			if(parentMesh.numChildren==0) return ;
			var l3dMesh:L3DMesh;
			var subMesh:Object3D;
			_l3dModel.Import(parentMesh);
			l3dMesh=_l3dModel.Export(_waistModel.stage3d);
			for(var j:int=0 ;j<l3dMesh.numChildren; j++)
			{
				subMesh=l3dMesh.getChildAt(j);
				if(subMesh is L3DMesh)
				{
					if(_waistModel.curMesh)
					{
						(subMesh as L3DMesh).catalog=22;
						(subMesh as L3DMesh).Mode=22;
					}
					(subMesh as L3DMesh).setMaterialToAllSurfaces(_waistModel.curMaterial);
				}
			}
			l3dMesh.catalog=_waistModel.curMesh.catalog;
			l3dMesh.family=_waistModel.curMesh.family;
			l3dMesh.Code=_waistModel.curMesh.Code;
			l3dMesh.ERPCode=_waistModel.curMesh.ERPCode;
			l3dMesh.Mode=_waistModel.curMesh.catalog;
			l3dMesh.isPolyMode=_waistModel.curMesh.isPolyMode;
			if(_renderViewCallback!=null)
				_renderViewCallback.call(null,l3dMesh);
		}
		public function addWaist3DTask(vo:ITaskVO):void
		{
			_waistModel.addTask(vo);
		}
		/**
		 * 展示3D护墙板模块
		 * @param planDatas	护墙板计划数据集合
		 * @param loadAllCompleteCallback		
		 * @param renderMeshCallback
		 * @return Boolean
		 * 
		 */		
		public function showView3D(loadAllCompleteCallback:Function,renderMeshCallback:Function):Boolean
		{
			_loadAllCompleteCallback||=loadAllCompleteCallback;
			_renderViewCallback||=renderMeshCallback;
			if(_waistModel.excuteDataCollection())
			{
				addEventListener(EventTypeDict.EVENT_LOADCOMPLETE,createMeshHandler);
				addEventListener(EventTypeDict.EVENT_LOADALLCOMPLETE,loadAllCompleteCallback);
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
			_waistModel.invalidPlanRenderData=true;
		}
		/**
		 * 执行任务
		 * 
		 */		
		public function excuteDecoration():void
		{
			_waistModel.startLoad();
		}
		public function clearModel():void
		{
			_waistModel.clearAll();
		}
		public function start():void
		{
			_isRunning=true;
		}
		
		public function stop():void
		{
			_isRunning=false;
		}
		/**
		 * 初始化装修 
		 * @param stage3d
		 * 
		 */		
		public function initDecorationService(stage3d:Stage3D):void
		{
			_waistModel.initLoader(stage3d);
		}
		public function addEventListener(type:String,func:Function):void
		{
			_waistModel.addEventListener(type,func);
		}
		public function hasEventListener(type:String):Boolean
		{
			return _waistModel.hasEventListener(type);
		}
		public function removeEventListener(type:String,func:Function):void
		{
			_waistModel.removeEventListener(type,func);
		}
		public function updateByFrame(startTime:Number=0, frameTime:Number=0):void
		{
		}
	}
}