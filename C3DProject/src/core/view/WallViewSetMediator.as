package core.view
{
	import a3d.support.Scene3D;
	
	import core.model.GlobalModel;
	
	import model.CabinetModel;
	import model.CabinetModel2;
	import model.KitchenGlobalModel;
	
	import ns.cloud_kitchen;
	
	import rl2.mvcs.view.BaseMediator;
	
	use namespace cloud_kitchen;
	/**
	 * 墙体可视对象集合中介类
	 * @author cloud
	 */
	public class WallViewSetMediator extends BaseMediator
	{
		[Inject]
		public var global:GlobalModel;
		[Inject]
		public var scene:Scene3D;
		[Inject]
		public var cabinetModel:CabinetModel;
		[Inject]
		public var cabinetModel2:CabinetModel2;
		
		public function get wallSet():WallViewSet
		{
			return _view as WallViewSet;
		}
		
		public function WallViewSetMediator()
		{
			super("WallViewSetMediator");
		}
		
		override public function initialize():void
		{
			super.initialize();
			wallSet.createWall(global.isThin,global.roomWidth,global.roomLength,global.floorHeight);
//			cabinetModel.topLeftWallPos.copyFrom(wallSet.leftUpPos);
//			cabinetModel.rightUpWallPos.copyFrom(wallSet.rightUpPos);
//			cabinetModel.leftDownWallPos.copyFrom(wallSet.leftDownPos);
//			cabinetModel.bottomRigthWallPos.copyFrom(wallSet.rightDownPos);
			KitchenGlobalModel.instance.leftTopWallPos.copyFrom(wallSet.leftUpPos);
			KitchenGlobalModel.instance.rightTopWallPos.copyFrom(wallSet.rightUpPos);
			KitchenGlobalModel.instance.leftBottomWallPos.copyFrom(wallSet.leftDownPos);
			KitchenGlobalModel.instance.rightBottomWallPos.copyFrom(wallSet.rightDownPos);
		}
	}
}