package kitchenModule.service
{
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.interfaces.ICStatus;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import kitchenModule.model.CabinetModel;
	
	import main.dict.CParamDict;
	import main.dict.EventTypeDict;
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParamPartVO;
	
	import utils.CParamUtil;
	
	/**
	 * 橱柜服务类
	 * @author cloud
	 * @2017-6-29
	 */
	public class CCabinetService implements ICStatus
	{
		private var _isRunning:Boolean;
		
		private var _cabinetModel:CabinetModel;
		private var _l3dModel:L3DModel;
		/**
		 * 渲染回调 
		 */		
		public var renderViewCallback:Function;
		
		public function get isRunning():Boolean
		{
			return false;
		}
		public function CCabinetService()
		{
			_cabinetModel=new CabinetModel();
			_l3dModel=new L3DModel();
			_cabinetModel.addEventListener(EventTypeDict.EVENT_LOADCOMPLETE,onCreateMesh);
		}
		private function onCreateMesh(evt:Event):void
		{
			//根据任务数据集合，创建装修模型组
			var parentMesh:Mesh;
			var parentMeshVos:Vector.<CBaseTaskObject3DVO>;
			parentMesh=new Mesh();
			parentMeshVos=new Vector.<CBaseTaskObject3DVO>();
			for each(var taskVo:CBaseTaskObject3DVO in _cabinetModel.curTaskVos)
			{
				CParamUtil.Instance.createParamMesh(taskVo,_cabinetModel.curMesh,_cabinetModel.curMaterial,parentMesh,parentMeshVos,_cabinetModel.addTask);
			}
			if(parentMesh.numChildren==0) return ;
			var l3dMesh:L3DMesh;
			var subMesh:Object3D;
			_l3dModel.Import(parentMesh);
			l3dMesh=_l3dModel.Export(_cabinetModel.stage3d);
			for(var j:int=0 ;j<l3dMesh.numChildren; j++)
			{
				subMesh=l3dMesh.getChildAt(j);
				if(subMesh is L3DMesh)
				{
					if(_cabinetModel.curMesh)
					{
						(subMesh as L3DMesh).catalog=22;
						(subMesh as L3DMesh).Mode=22;
					}
					if(_cabinetModel.curMaterial!=null)
						(subMesh as L3DMesh).setMaterialToAllSurfaces(_cabinetModel.curMaterial);
				}
			}
			l3dMesh.name=_cabinetModel.curType.toString();
			if(parentMeshVos[0] is CParamPartVO)
			{
				l3dMesh.OffGround=(parentMeshVos[0] as CParamPartVO).offGround;
			}
			l3dMesh.userData2=parentMeshVos;
			l3dMesh.userData3=_cabinetModel.curMesh;
			l3dMesh.userData4=_cabinetModel.curMaterial;
			l3dMesh.userData5=_cabinetModel.curCode;
			l3dMesh.userData6=_cabinetModel.curType;
			if(_cabinetModel.curMesh)
			{
				l3dMesh.catalog=_cabinetModel.curMesh.catalog;
				l3dMesh.family=_cabinetModel.curMesh.family;
				l3dMesh.Code=_cabinetModel.curMesh.Code;
				l3dMesh.ERPCode=_cabinetModel.curMesh.ERPCode;
				l3dMesh.Mode=_cabinetModel.curMesh.catalog;
				l3dMesh.isPolyMode=_cabinetModel.curMesh.isPolyMode;
			}
			else
			{
				l3dMesh.catalog=22;
				l3dMesh.Mode=22;
			}
			if(renderViewCallback!=null)
				renderViewCallback.call(null,l3dMesh);
		}
		
		public function initService(stage3d:Stage3D):void
		{
			_cabinetModel.initLoader(stage3d);
		}
		public function hasFloorID(floorID:String):Boolean
		{
			return _cabinetModel.floorID!=null && _cabinetModel.floorID.length>0;
		}
		public function createFurnitureVo(furnitureID:String,furnitureDirection:int,furnitureType:uint,furnitureLength:Number,furnitureWidth:Number,furnitureHeight:Number):CBaseObject3DVO
		{
			return _cabinetModel.createFurnitureVo(furnitureID,furnitureDirection,furnitureType,furnitureLength,furnitureWidth,furnitureHeight);
		}
		public function deleteFurnitureVo(furnitureID:String):void
		{
			_cabinetModel.deleteFurnitureVo(furnitureID);
		}
		public function excuteMove(furnitureDir:int,position:Vector3D):Boolean
		{
			return _cabinetModel.excuteMove(furnitureDir,position);
		}
		public function excuteMouseDown(furnitureID:String,furnitureDir:int):Boolean
		{
			return _cabinetModel.excuteMouseDown(furnitureID,furnitureDir);
		}
		public function excuteMouseUp():Vector.<ICData>
		{
			return _cabinetModel.excuteMouseUp();
		}
		public function excuteEnd():void
		{
			_cabinetModel.excuteEnd();
		}
		public function deleteTableBoards():void
		{
			_cabinetModel.deleteTableBoards();
		}
		public function deleteShelters():void
		{
			_cabinetModel.deleteShelters();
		}
		public function deleteRoomCorners():void
		{
			_cabinetModel.deleteRoomCorners();
		}
		public function createTableBoards():Vector.<CBaseObject3DVO>
		{
			return _cabinetModel.createTableBoards();
		}
		public function createShelterVos():Vector.<CBaseObject3DVO>
		{
			return _cabinetModel.createShelterVos();
		}
		public function getFurnituresInList():Vector.<CBaseObject3DVO>
		{
			return _cabinetModel.getFurnituresInList();
		}
		
		public function deserializeXML(source:XML,parent:CBaseObject3DVO):void
		{
			if(source==null) return;
			var clsName:String;
			var cls:Class;
			var xmlList:XMLList=source.children();
			var len:int=xmlList.length();
			var vo:CBaseObject3DVO;
			var taskVo:CBaseTaskObject3DVO;
			CVector.Normalize(parent.direction);
			for(var i:int=0; i<len; i++)
			{
				clsName=String(XML(xmlList[i]).name());
				CParamDict.Instance.addTypeDef(String(xmlList[i].@type),clsName);
				cls=CParamDict.Instance.getParamDataTypeCls(clsName);
				vo=new cls();
				if(parent!=null)
					parent.addChild(vo);
				vo.deserialize(xmlList[i]);
				
				if(vo is CBaseTaskObject3DVO)
				{
					taskVo=vo as CBaseTaskObject3DVO;
					_cabinetModel.addTask(taskVo);
					for(var child:ICObject3D=vo.children; child!=null; child=child.next)
					{
						taskVo=child as CBaseTaskObject3DVO;
						if(taskVo==null) continue;
						_cabinetModel.addTask(taskVo);
					}
				}
				deserializeXML(xmlList[i],vo);
			}
		}
		/**
		 * 开始下载 
		 * 
		 */		
		public function excuteTask():void
		{
			//开始处理任务加载
			_cabinetModel.startLoad();
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