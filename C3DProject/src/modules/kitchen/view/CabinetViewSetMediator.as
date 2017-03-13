package modules.kitchen.view
{
	import a3d.support.Scene3D;
	
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.utils.Utils;
	
	import cloud.geometry.threed.Geometry3DUtil;
	import cloud.geometry.threed.Ray;
	import cloud.geometry.threed.Vector3DUtil;
	
	import core.model.GlobalModel;
	
	import dic.KitchenGlobalDic;
	
	import dict.EventTypeDict;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import interfaces.ICFurnitureVO;
	
	import model.CabinetModel;
	import model.HangingCabinetModel;
	import model.vo.ShelterVO;
	import model.vo.TableBoardVO;
	
	import rl2.mvcs.view.BaseMediator;
	
	import utils.DatasEvent;
	
	import view.CShelterView;
	import view.CTableBoardView;
	
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
		public var hangingCabinetModel:HangingCabinetModel;
		[Inject]
		public var scene:Scene3D;
		
		private var _ray:Ray;
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
			_ray=new Ray();
			_intersectPos=new Vector3D();
			_shelterPlanes=new Vector.<Plane>();
		}
		
		private function onMouseDown(evt:MouseEvent3D):void
		{
			scene.view.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			scene.view.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			scene.controller.disable();
			cabinetSet.setSelected(evt.currentTarget as L3DMesh);
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			scene.calculateMouseRay(_ray,evt.localX,evt.localY);
			Geometry3DUtil.intersectPlaneByRay(_ray,Vector3DUtil.ZERO,Vector3DUtil.Z,_intersectPos);
			cabinetSet.fixPos(_intersectPos,globalModel.roomLength,globalModel.roomWidth,globalModel.floorHeight);
			if(cabinetModel.excuteMove(cabinetSet.getCurrentMeshID(),KitchenGlobalDic.DIR_FRONT,_intersectPos))
			{
				//发生吸附，停止移动
				onMouseUp(evt);
			}
			cabinetSet.updateCurrentPos(_intersectPos);
		}
		private function onMouseUp(evt:MouseEvent):void
		{
			scene.view.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			scene.view.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			scene.controller.enable();
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
			cabinetModel.deleteTableBoardVO(_tableBoard.getTableBoardID());
			cabinetSet.removeFurnitureView(_tableBoard);
			_tableBoard=null;
		}
		private function createTableBoard():void
		{
			_tableBoard=new CTableBoardView();
			var vo:TableBoardVO=cabinetModel.createTableBoardVO(cabinetModel.length,cabinetModel.width,KitchenGlobalDic.TABLEBOARD_HEIGHT,cabinetModel.combinePos);
			_tableBoard.createTableBoard(vo);
			cabinetSet.addFurnitureView(_tableBoard);
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
			var ids:Vector.<String>=_shelter.getShelterIDs();
			cabinetModel.deleteShelterVOs(ids);
			cabinetSet.removeFurnitureView(_shelter);
			_shelter=null;
		}
		private function createShelter():void
		{
			_shelter=new CShelterView();
			var vos:Vector.<ShelterVO>=cabinetModel.createShelterVOs();
			_shelter.createShelter(vos);
			cabinetSet.addFurnitureView(_shelter);
		}

		override protected function addListener():void
		{
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateCabinet);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_HANGING_CABINET,onCreateHangingCabinet);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateCabinet);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_HANGING_CABINET,onCreateHangingCabinet);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
	}
}