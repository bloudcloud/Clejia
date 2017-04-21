package core.view
{
	import mx.utils.UIDUtil;
	
	import a3d.support.Scene3D;
	
	import core.model.GlobalModel;
	
	import kitchenModule.model.CabinetModel;
	import kitchenModule.model.HangingCabinetModel;
	import kitchenModule.model.KitchenGlobalModel;
	
	import main.dict.Object3DDict;
	import main.model.WallDataModel;
	
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
		public var wallModel:WallDataModel;
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
			wallModel.createWalls(wallSet.wallPoses,floorID);
			cabinetModel.rootList=KitchenGlobalModel.instance.initKitchenListByWalls(Object3DDict.OBJECT3D_CABINET,floorID,wallModel.walls);
			hangingModel.rootList=KitchenGlobalModel.instance.initKitchenListByWalls(Object3DDict.OBJECT3D_CABINET,floorID,wallModel.walls);
		}
	}
}