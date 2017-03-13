package core.view
{
	import a3d.support.Scene3D;
	
	import modules.kitchen.view.CabinetViewSet;
	
	import rl2.mvcs.view.BaseMediator;
	
	/**
	 *  场景中介类
	 * @author cloud
	 */
	public class Scene3DMediator extends BaseMediator
	{
		[Inject]
		public var scene:Scene3D;
		
		private var _floorSet:FloorViewSet;
		private var _wallSet:WallViewSet;
		private var _cabinetSet:CabinetViewSet;
//		private var _createBoard:Box;
//		private var _createShelter:Plane;
		
		public function Scene3DMediator()
		{
			super("Scene3DMediator");
			_floorSet=new FloorViewSet();
			_wallSet=new WallViewSet();
			_cabinetSet=new CabinetViewSet();
		}
		
		override protected function addListener():void
		{
//			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD
		}
		
		override public function initialize():void
		{
			super.initialize();
			scene.addChild(_floorSet);
			scene.addChild(_wallSet);
			scene.addChild(_cabinetSet);
		}
	}
}