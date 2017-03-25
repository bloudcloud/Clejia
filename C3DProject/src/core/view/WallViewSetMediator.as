package core.view
{
	import a3d.support.Scene3D;
	
	import core.model.GlobalModel;
	
	import model.CabinetModel;
	import model.KitchenGlobalModel;
	
	import ns.cloudLib;
	
	import rl2.mvcs.view.BaseMediator;
	
	use namespace cloudLib;
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
			KitchenGlobalModel.instance.leftTopWallPos=wallSet.leftUpPos;
			KitchenGlobalModel.instance.rightTopWallPos=wallSet.rightUpPos;
			KitchenGlobalModel.instance.leftBottomWallPos=wallSet.leftDownPos;
			KitchenGlobalModel.instance.rightBottomWallPos=wallSet.rightDownPos;
			cabinetModel.initKitchen();
		}
	}
}