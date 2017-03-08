package modules.kitchen.view
{
	import a3d.support.Scene3D;
	
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.rl2.BaseMediator;
	
	import core.model.GlobalModel;
	
	import dic.KitchenGlobalDic;
	
	import dict.EventTypeDict;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import geometry.threed.Geometry3DUtil;
	import geometry.threed.Ray;
	import geometry.threed.Vector3DUtil;
	
	import main.FurnitureOutputData;
	
	import model.CabinetModel;
	
	import utils.DatasEvent;
	
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
		
		private var _ray:Ray;
		private var _intersectPos:Vector3D;
		
		public function get cabinetSet():CabinetViewSet
		{
			return _view as CabinetViewSet;
		}
		
		public function CabinetViewSetMediator()
		{
			super("CabinetViewSetMediator");
			_ray=new Ray();
			_intersectPos=new Vector3D();
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
			cabinetSet.fixPos(_intersectPos,globalModel.roomLength,globalModel.roomWidth,globalModel.roomHeight);
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
		
		private function onCreateCabinet(evt:DatasEvent):void
		{
			var mesh:L3DMesh = evt.data as L3DMesh;
			mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			cabinetSet.createCabinet(mesh);
			cabinetModel.createFurnitureVO(mesh.UniqueID,mesh.family,mesh.Length,mesh.Width,mesh.Height);
		}
		override protected function addListener():void
		{
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateCabinet);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateCabinet);
		}
	}
}