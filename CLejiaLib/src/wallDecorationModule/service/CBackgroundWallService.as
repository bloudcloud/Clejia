package wallDecorationModule.service
{
	import flash.display.Stage3D;
	import flash.events.Event;
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.datas.maps.CHashMap;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import main.dict.CParamDict;
	import main.dict.EventTypeDict;
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParamPartVO;
	
	import utils.CParamUtil;
	
	import wallDecorationModule.interfaces.ICDecorationService;
	import wallDecorationModule.model.CBackgroundWallModel;
	
	/**
	 * 背景墙服务类
	 * @author cloud
	 */
	public class CBackgroundWallService implements ICDecorationService
	{
		private var _isRunning:Boolean;
		private var _l3dModel:L3DModel;
		
		/**
		 * 任务数据模型 
		 */		
		private var _backgroundWallModel:CBackgroundWallModel;
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
			return _backgroundWallModel.invalidPlanRenderData;
		}
		public function set invalidPlanRenderData(value:Boolean):void
		{
			_backgroundWallModel.invalidPlanRenderData=value;
		}
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		public function CBackgroundWallService()
		{
			_l3dModel=new L3DModel();
			_backgroundWallModel=new CBackgroundWallModel();
		}
		
		/**
		 * 创建渲染用模型 
		 * @param evt
		 * 
		 */		
		private function createMeshHandler(evt:Event):void
		{
			//根据任务数据集合，创建装修模型组
			var parentMesh:Mesh;
			var parentMeshVos:Vector.<CBaseTaskObject3DVO>;
			parentMesh=new Mesh();
			parentMeshVos=new Vector.<CBaseTaskObject3DVO>();
			for each(var taskVo:CBaseTaskObject3DVO in _backgroundWallModel.curTaskVos)
			{
				CParamUtil.Instance.createParamMesh(taskVo,_backgroundWallModel.curMesh,_backgroundWallModel.curMaterial,parentMesh,parentMeshVos,_backgroundWallModel.addTask);
			}
			if(parentMesh.numChildren==0) return ;
			var l3dMesh:L3DMesh;
			var subMesh:Object3D;
			_l3dModel.Import(parentMesh);
			l3dMesh=_l3dModel.Export(_backgroundWallModel.stage3d);
			for(var j:int=0 ;j<l3dMesh.numChildren; j++)
			{
				subMesh=l3dMesh.getChildAt(j);
				if(subMesh is L3DMesh)
				{
					if(_backgroundWallModel.curMesh)
					{
						(subMesh as L3DMesh).catalog=22;
						(subMesh as L3DMesh).Mode=22;
					}
					(subMesh as L3DMesh).setMaterialToAllSurfaces(_backgroundWallModel.curMaterial);
				}
			}
			l3dMesh.name=_backgroundWallModel.curType.toString();
			if(parentMeshVos[0] is CParamPartVO)
			{
				l3dMesh.OffGround=(parentMeshVos[0] as CParamPartVO).offGround;
			}
			l3dMesh.userData2=parentMeshVos;
			l3dMesh.userData3=_backgroundWallModel.curMesh;
			l3dMesh.userData4=_backgroundWallModel.curMaterial;
			l3dMesh.userData5=_backgroundWallModel.curCode;
			l3dMesh.userData6=_backgroundWallModel.curType;
			if(_backgroundWallModel.curMesh)
			{
				l3dMesh.catalog=_backgroundWallModel.curMesh.catalog;
				l3dMesh.family=_backgroundWallModel.curMesh.family;
				l3dMesh.Code=_backgroundWallModel.curMesh.Code;
				l3dMesh.ERPCode=_backgroundWallModel.curMesh.ERPCode;
				l3dMesh.Mode=_backgroundWallModel.curMesh.catalog;
				l3dMesh.isPolyMode=_backgroundWallModel.curMesh.isPolyMode;
			}
			else
			{
				l3dMesh.catalog=22;
				l3dMesh.Mode=22;
			}
			if(_renderViewCallback!=null)
				_renderViewCallback.call(null,l3dMesh);
		}
		private function doSetRenderPlanData(roomWalls:Vector.<ICData>,xmlCaches:Array):void
		{
			var source:XML;
			//遍历房间所有的墙
			for (var j:int=0; j<xmlCaches.length; j++)
			{
				if(xmlCaches[j]==null || xmlCaches.length==0) continue;
				source=XML(xmlCaches[j]);
				//解析生成当前区域内的原始方案
				deserializeXML(source,null);
			}
		}
		private function deserializeXML(source:XML,parent:ICObject3D):void
		{
			if(source==null) return;
			var clsName:String;
			var cls:Class;
			var xmlList:XMLList=source.children();
			var len:int=xmlList.length();
			var vo:CBaseObject3DVO;
			var taskVo:CBaseTaskObject3DVO;
			for(var i:int=0; i<len; i++)
			{
				clsName=String(XML(xmlList[i]).name());
				CParamDict.Instance.addTypeDef(String(xmlList[i].@type),clsName);
				cls=CParamDict.Instance.getParamDataTypeCls(clsName);
				vo=new cls(clsName);
				if(parent!=null)
					parent.addChild(vo); 
				vo.deserialize(xmlList[i]);
				
				deserializeXML(xmlList[i],vo);
			}
		}
		private function doAddTask(taskVo:CBaseTaskObject3DVO):void
		{
			if(taskVo.material && taskVo.material.length>0)
				_backgroundWallModel.addTask(taskVo);
		}
		
		/**
		 * 初始化装修 
		 * @param stage3d
		 * 
		 */		
		public function initDecoration(stage3d:Stage3D):void
		{
			_backgroundWallModel.initLoader(stage3d);
		}
		/**
		 * 更新方案数据 
		 * @param sourceXml	源xml数据
		 * @param roomID
		 * @param wallIndex
		 * @param regionIndex
		 * 
		 */		
		public function updatePlanData(sourceXml:XML,roomID:String,wallIndex:int,regionIndex:int):void
		{
			var datas:Array=_backgroundWallModel.allPlanDatas.get(roomID) as Array;
			datas[wallIndex]=sourceXml;
		}
		/**
		 * 设置xml计划数据集合 
		 * @param dataMap
		 * 
		 */		
		public function setXmlPlanDatas(dataMap:CHashMap):void
		{
			_backgroundWallModel.allPlanDatas||=dataMap;
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
			_loadAllCompleteCallback||=loadAllCompleteCallback;
			_renderViewCallback||=renderMeshCallback;
			if(_backgroundWallModel.excuteDataCollection())
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
			_backgroundWallModel.invalidPlanRenderData=true;
		}
		/**
		 * 删除护墙板装修模型数据 
		 * @param taskVo
		 * 
		 */		
		public function removeDecorationMeshData(mesh:L3DMesh):void
		{
			if(!(mesh.userData2[0] is CBaseTaskObject3DVO)) return;
//			_backgroundWallModel.removePlanData(mesh.userData2[0] as CParamPartVO);
		}
		/**
		 * 执行任务
		 * 
		 */		
		public function excuteDecoration():void
		{
			_backgroundWallModel.startLoad();
		}
		public function clearModel():void
		{
			_backgroundWallModel.clearAll();
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
			_backgroundWallModel.initLoader(stage3d);
		}
		public function addEventListener(type:String,func:Function):void
		{
			_backgroundWallModel.addEventListener(type,func);
		}
		public function hasEventListener(type:String):Boolean
		{
			return _backgroundWallModel.hasEventListener(type);
		}
		public function removeEventListener(type:String,func:Function):void
		{
			_backgroundWallModel.removeEventListener(type,func);
		}
		public function updateByFrame(startTime:Number=0, frameTime:Number=0):void
		{
		}
	}
}