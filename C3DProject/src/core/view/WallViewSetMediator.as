package core.view
{
	import flash.geom.Vector3D;
	
	import mx.utils.UIDUtil;
	
	import a3d.support.Scene3D;
	
	import cloud.core.utils.CDebug;
	
	import core.model.GlobalModel;
	
	import model.CabinetModel;
	import model.HangingCabinetModel;
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
		[Inject]
		public var hangingModel:HangingCabinetModel;
		
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
			var floorID:String=UIDUtil.createUID();
			KitchenGlobalModel.instance.parseWalls(wallSet.wallPoses,floorID);
			cabinetModel.initModel(floorID);
			hangingModel.initModel(floorID);
		}
	}
}