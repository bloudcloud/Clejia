package core.view
{
	import a3d.support.Scene3D;
	
	import core.model.GlobalModel;
	
	import model.CabinetModel;
	
	import rl2.mvcs.view.BaseMediator;
	
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
			cabinetModel.leftUpWallPos.copyFrom(wallSet.leftUpPos);
			cabinetModel.rightUpWallPos.copyFrom(wallSet.rightUpPos);
			cabinetModel.leftDownWallPos.copyFrom(wallSet.leftDownPos);
			cabinetModel.rightDownWallPos.copyFrom(wallSet.rightDownPos);
		}
	}
}