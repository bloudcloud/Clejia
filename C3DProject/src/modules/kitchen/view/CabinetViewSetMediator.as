package modules.kitchen.view
{
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import a3d.support.Scene3D;
	
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.primitives.Plane;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.utils.Geometry3DUtil;
	import cloud.core.utils.MathUtil;
	import cloud.core.utils.Vector3DUtil;
	
	import core.model.GlobalModel;
	
	import dict.EventTypeDict;
	
	import interfaces.ICFurnitureModel;
	
	import model.CabinetModel;
	import model.KitchenGlobalModel;
	
	import ns.cloudLib;
	
	import rl2.mvcs.view.BaseMediator;
	
	import utils.DatasEvent;
	
	import view.CShelterView;
	import view.CTableBoardView;
	
	use namespace cloudLib;
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
		private function getModel():ICFurnitureModel
		{
			switch(cabinetSet.currentMeshType)
			{
				case KitchenGlobalModel.instance.MESHTYPE_CABINET:
				case KitchenGlobalModel.instance.MESHTYPE_HANGING_CABINET:
				case KitchenGlobalModel.instance.MESHTYPE_SINK:
					return cabinetModel;
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
			cabinetModel.excuteMouseDown(mesh.UniqueID,KitchenGlobalModel.instance.DIR_FRONT);
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			scene.calculateMouseRay(Vector3DUtil.RAY_3D,evt.localX,evt.localY);
			Geometry3DUtil.intersectPlaneByRay(Vector3DUtil.RAY_3D,Vector3DUtil.ZERO,Vector3DUtil.AXIS_Z,_intersectPos);
			cabinetSet.fixPos(_intersectPos,globalModel.roomLength,globalModel.roomWidth,globalModel.floorHeight);
			var vos:Vector.<ICData>=cabinetModel.excuteMove(cabinetSet.currentRotation,_intersectPos)
			if(vos)
			{
				updateMeshPosition(vos);
				scene.view.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				scene.view.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				scene.controller.enable();
				cabinetModel.excuteEnd();
//				onMouseUp(evt);
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
			var vos:Vector.<ICData>=cabinetModel.excuteMouseUp();
			if(vos)
			{
				updateMeshPosition(vos);
				cabinetModel.excuteEnd();
			}
		}
		private function updateMeshPosition(vos:Vector.<ICData>):void
		{
			var mesh:L3DMesh;
			var meshes:Array;
			for each(var vo:ICObject3DData in vos)
			{
				for (var i:int=0; i<cabinetSet.meshes.length; i++)
				{
					mesh=cabinetSet.meshes[i] as L3DMesh;
					if(mesh && mesh.UniqueID==vo.uniqueID)
					{
						if(vo.isLife)
						{
							mesh.rotationZ=MathUtil.toRadians(vo.direction);
							mesh.x=vo.position.x;
							mesh.y=vo.position.y;
							mesh.z=vo.position.z;
						}
						else
						{
							meshes ||=new Array();
							meshes.push(mesh);
						}
					}
				}
			}
			if(meshes)
			{
				for(i=0;i<meshes.length;i++)
				{
					mesh=meshes[i];
					cabinetModel.deleteFurnitureVo(mesh.UniqueID,MathUtil.toDegrees(mesh.rotationZ));
					cabinetSet.removeFurnitureView(mesh);
//					mesh.Dispose(false);
				}
			}
			
		}
		/**
		 * 创建单柜 
		 * @param evt
		 * 
		 */		
		private function onCreateKitchenFurniture(evt:DatasEvent):void
		{
			var mesh:L3DMesh = evt.data as L3DMesh;
			mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			cabinetSet.createCabinet(mesh);
			cabinetModel.createFurnitureVo(mesh.UniqueID,MathUtil.toDegrees(mesh.rotationZ),mesh.catalog,mesh.Length,mesh.Width,mesh.Height);
		}
		
		/**
		 * 创建台面 
		 * @param evt
		 * 
		 */		
		private function onCreateTableBoard(evt:DatasEvent):void
		{
//			if(cabinetModel.datas.length==0) return;
//			if(_tableBoard)
//			{
//				deleteTableBoard();
//			}
//			else
//			{
//				createTableBoard();
//			}
		}
		private function deleteTableBoard():void
		{
//			cabinetModel.deleteTableBoardVOs(_tableBoard.furnitureVos);
//			cabinetSet.removeFurnitureView(_tableBoard);
//			_tableBoard.dispose();
//			_tableBoard=null;
		}
		private function createTableBoard():void
		{
//			_tableBoard=new CTableBoardView();
//			var vo:TableBoardVO=cabinetModel.createTableBoardVO(cabinetModel.length,cabinetModel.width,KitchenGlobalModel.instance.TABLEBOARD_HEIGHT,cabinetModel.combinePos);
//			_tableBoard.createTableBoardMesh(vo);
//			var mesh:CBox=_tableBoard.getChildAt(0) as CBox;
//			mesh.scaleX=10;
//			mesh.scaleY=10;
//			mesh.scaleZ=10;
//			cabinetSet.addFurnitureView(_tableBoard);
//			
//			var l3dmodel:L3DModel=new L3DModel();
//			l3dmodel.Import(_tableBoard,false,true);
//			var l3dmesh:L3DMesh=l3dmodel.Export(scene.stage3D);
		}
		/**
		 * 创建挡板 
		 * @param evt
		 * 
		 */		
		private function onCreateShelter(evt:DatasEvent):void
		{
//			if(cabinetModel.datas.length==0) return;
//			if(_shelter)
//			{
//				deleteShelter();
//			}
//			else
//			{
//				createShelter();
//			}
		}
		private function deleteShelter():void
		{
//			cabinetModel.deleteShelterVOs(_shelter.furnitureVos);
//			cabinetSet.removeFurnitureView(_shelter);
//			_shelter.dispose();
//			_shelter=null;
		}
		private function createShelter():void
		{
//			var vos:Vector.<ShelterVO>=cabinetModel.createShelterVOs();
//			_shelter=new CShelterView();
//			_shelter.createShelter(vos);
//			var child:CBox;
//			for(var i:int=0; i<_shelter.numChildren; i++)
//			{
//				child=_shelter.getChildAt(i) as CBox;
//				child.scaleX=10;
//				child.scaleY=10;
//				child.scaleZ=10;
//			}
//			cabinetSet.addFurnitureView(_shelter);
		}

		override protected function addListener():void
		{
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateKitchenFurniture);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_HANGING_CABINET,onCreateKitchenFurniture);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_KICHENPART,onCreateKitchenFurniture);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateKitchenFurniture);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_HANGING_CABINET,onCreateKitchenFurniture);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_KICHENPART,onCreateKitchenFurniture);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
	}
}