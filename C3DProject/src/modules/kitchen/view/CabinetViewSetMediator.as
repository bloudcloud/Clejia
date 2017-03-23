package modules.kitchen.view
{
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import a3d.support.Scene3D;
	
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.primitives.Plane;
	
	import cloud.core.interfaces.IC3DObjectData;
	import cloud.core.utils.Geometry3DUtil;
	import cloud.core.utils.MathUtil;
	import cloud.core.utils.Vector3DUtil;
	
	import core.model.GlobalModel;
	
	import dict.EventTypeDict;
	
	import model.BaseFurnitureSetModel;
	import model.CabinetModel;
	import model.CabinetModel2;
	import model.HangingCabinetModel;
	import model.KitchenGlobalModel;
	import model.KitchenPartModel;
	import model.vo.ShelterVO;
	import model.vo.TableBoardVO;
	
	import ns.cloud_kitchen;
	
	import rl2.mvcs.view.BaseMediator;
	
	import utils.DatasEvent;
	
	import view.CBox;
	import view.CShelterView;
	import view.CTableBoardView;
	
	use namespace cloud_kitchen;
	/**
	 *  单柜可视对象集合中介类
	 * @author cloud
	 */
	public class CabinetViewSetMediator extends BaseMediator
	{
		[Inject]
		public var globalModel:GlobalModel;
		[Inject]
		public var cabinetModel:CabinetModel;
		[Inject]
		public var cabinetModel2:CabinetModel2;
		[Inject]
		public var hangingCabinetModel:HangingCabinetModel;
		[Inject]
		public var kitchenPartModel:KitchenPartModel;
		[Inject]
		public var scene:Scene3D;

		private var _intersectPos:Vector3D;
		private var _tableBoard:CTableBoardView;
		private var _shelter:CShelterView;
		private var _shelterPlanes:Vector.<Plane>;
		
		public function get cabinetSet():CabinetViewSet
		{
			return _view as CabinetViewSet;
		}
		
		public function CabinetViewSetMediator()
		{
			super("CabinetViewSetMediator");
			_intersectPos=new Vector3D();
			_shelterPlanes=new Vector.<Plane>();
		}
		private function getModel():BaseFurnitureSetModel
		{
			switch(cabinetSet.currentMeshType)
			{
				case KitchenGlobalModel.instance.MESHTYPE_CABINET:
					return cabinetModel;
				case KitchenGlobalModel.instance.MESHTYPE_HANGING_CABINET:
					return hangingCabinetModel;
				case KitchenGlobalModel.instance.MESHTYPE_SINK:
					return kitchenPartModel;
				default:
					return null;
			}
		}
		
		private function onMouseDown(evt:MouseEvent3D):void
		{
			scene.view.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			scene.view.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			scene.controller.disable();
			var mesh:L3DMesh=evt.currentTarget as L3DMesh;
			cabinetSet.setSelected(mesh);
			cabinetModel2.excuteMouseDown(mesh.UniqueID,KitchenGlobalModel.instance.DIR_FRONT);
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			scene.calculateMouseRay(Vector3DUtil.RAY_3D,evt.localX,evt.localY);
			Geometry3DUtil.intersectPlaneByRay(Vector3DUtil.RAY_3D,Vector3DUtil.ZERO,Vector3DUtil.AXIS_Z,_intersectPos);
			cabinetSet.fixPos(_intersectPos,globalModel.roomLength,globalModel.roomWidth,globalModel.floorHeight);
//			if(getModel().excuteMove(cabinetSet.currentMeshID,KitchenGlobalModel.instance.DIR_FRONT,_intersectPos))
//			{
//				//发生吸附，停止移动
//				onMouseUp(evt);
//			}
			var vos:Vector.<IC3DObjectData>=cabinetModel2.excuteMove(cabinetSet.currentRotation,_intersectPos)
			if(vos)
			{
				updateMeshPosition(vos);
				onMouseUp(evt);
			}
			else
			{
				cabinetSet.updateCurrent(cabinetSet.currentRotation,_intersectPos);
			}
		}
		private function onMouseUp(evt:MouseEvent):void
		{
			scene.view.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			scene.view.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			scene.controller.enable();
			var vos:Vector.<IC3DObjectData>=cabinetModel2.excuteMouseUp();
			if(vos)
			{
				updateMeshPosition(vos);
			}
		}
		private function updateMeshPosition(vos:Vector.<IC3DObjectData>):void
		{
			for each(var vo:IC3DObjectData in vos)
			{
				for each(var mesh:L3DMesh in cabinetSet.meshes)
				{
					if(mesh && mesh.UniqueID==vo.uniqueID)
					{
						mesh.rotationZ=MathUtil.toRadians(vo.direction);
						mesh.x=vo.position.x;
						mesh.y=vo.position.y;
						mesh.z=vo.position.z;
					}
				}
			}
		}
		/**
		 * 创建单柜 
		 * @param evt
		 * 
		 */		
		private function onCreateCabinet(evt:DatasEvent):void
		{
			var mesh:L3DMesh = evt.data as L3DMesh;
			mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			cabinetSet.createCabinet(mesh);
			cabinetModel.createCabinetVO(mesh.UniqueID,mesh.catalog,mesh.Length,mesh.Width,mesh.Height);
		}
		private function onCreateHangingCabinet(evt:DatasEvent):void
		{
			var mesh:L3DMesh = evt.data as L3DMesh;
			mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			cabinetSet.createHangingCabinet(mesh);
			hangingCabinetModel.createHangingCabinet(mesh.UniqueID,mesh.catalog,mesh.Length,mesh.Width,mesh.Height);
		}
		private function onCreateKitchenPart(evt:DatasEvent):void
		{
//			if(_tableBoard)
//			{
//				var mesh:L3DMesh = evt.data as L3DMesh;
//				mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
//				cabinetSet.addFurnitureView(mesh);
//				kitchenPartModel.createKitchenPart(mesh.UniqueID,mesh.catalog,mesh.Length,mesh.Width,mesh.Height);
//			}
			var mesh:L3DMesh=evt.data as L3DMesh;
			mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			cabinetSet.addFurnitureView(mesh);
			cabinetModel2.createFurnitureVo(mesh.UniqueID,KitchenGlobalModel.instance.DIR_FRONT,mesh.catalog,mesh.Length,mesh.Width,mesh.Height);
		}
		/**
		 * 创建台面 
		 * @param evt
		 * 
		 */		
		private function onCreateTableBoard(evt:DatasEvent):void
		{
			if(cabinetModel.datas.length==0) return;
			if(_tableBoard)
			{
				deleteTableBoard();
			}
			else
			{
				createTableBoard();
			}
		}
		private function deleteTableBoard():void
		{
			cabinetModel.deleteTableBoardVOs(_tableBoard.furnitureVos);
			cabinetSet.removeFurnitureView(_tableBoard);
			_tableBoard.dispose();
			_tableBoard=null;
		}
		private function createTableBoard():void
		{
			_tableBoard=new CTableBoardView();
			var vo:TableBoardVO=cabinetModel.createTableBoardVO(cabinetModel.length,cabinetModel.width,KitchenGlobalModel.instance.TABLEBOARD_HEIGHT,cabinetModel.combinePos);
			_tableBoard.createTableBoardMesh(vo);
			var mesh:CBox=_tableBoard.getChildAt(0) as CBox;
			mesh.scaleX=10;
			mesh.scaleY=10;
			mesh.scaleZ=10;
			cabinetSet.addFurnitureView(_tableBoard);
			
			var l3dmodel:L3DModel=new L3DModel();
			l3dmodel.Import(_tableBoard,false,true);
			var l3dmesh:L3DMesh=l3dmodel.Export(scene.stage3D);
		}
		/**
		 * 创建挡板 
		 * @param evt
		 * 
		 */		
		private function onCreateShelter(evt:DatasEvent):void
		{
			if(cabinetModel.datas.length==0) return;
			if(_shelter)
			{
				deleteShelter();
			}
			else
			{
				createShelter();
			}
		}
		private function deleteShelter():void
		{
			cabinetModel.deleteShelterVOs(_shelter.furnitureVos);
			cabinetSet.removeFurnitureView(_shelter);
			_shelter.dispose();
			_shelter=null;
		}
		private function createShelter():void
		{
			var vos:Vector.<ShelterVO>=cabinetModel.createShelterVOs();
			_shelter=new CShelterView();
			_shelter.createShelter(vos);
			var child:CBox;
			for(var i:int=0; i<_shelter.numChildren; i++)
			{
				child=_shelter.getChildAt(i) as CBox;
				child.scaleX=10;
				child.scaleY=10;
				child.scaleZ=10;
			}
			cabinetSet.addFurnitureView(_shelter);
		}

		override protected function addListener():void
		{
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateCabinet);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_HANGING_CABINET,onCreateHangingCabinet);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_KICHENPART,onCreateKitchenPart);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateCabinet);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_HANGING_CABINET,onCreateHangingCabinet);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_KICHENPART,onCreateKitchenPart);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
	}
}