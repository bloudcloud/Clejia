package core.view
{
	import a3d.support.Scene3D;
	
	import cloud.rl2.BaseMediator;
	
	import core.model.GlobalModel;
	
	/**
	 *  地面可视对象集合中介类
	 * @author cloud
	 */
	public class FloorViewSetMediator extends BaseMediator
	{
		[Inject]
		public var global:GlobalModel;
		[Inject]
		public var scene:Scene3D;
		
		public function get floorSet():FloorViewSet
		{
			return _view as FloorViewSet;
		}
		
		public function FloorViewSetMediator()
		{
			super("FloorViewSetMediator");
		}
		override public function initialize():void
		{
			super.initialize();
			floorSet.createFloor(global.isThin,global.roomWidth,global.roomLength,global.roomHeight);
		}
	}
}