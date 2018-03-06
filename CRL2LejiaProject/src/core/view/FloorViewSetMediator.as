package core.view
{
	import cloud.core.events.CDataEvent;
	
	import core.model.GlobalModel;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
	
	import rl2.mvcs.view.BaseMediator;
	
	/**
	 *  地面可视对象集合中介类
	 * @author cloud
	 */
	public class FloorViewSetMediator extends BaseMediator
	{
		[Inject]
		public var global:GlobalModel;
		[Inject]
		public var scene:CScene3D;
		
		public function get floorSet():FloorViewSet
		{
			return _view as FloorViewSet;
		}
		
		public function FloorViewSetMediator()
		{
			super("FloorViewSetMediator");
		}
		private function onInitFloorData(evt:CDataEvent):void
		{
			var arr:Array = evt.data as Array;
			floorSet.createFloor(arr,global.floorThickness);
		}
		override protected function addListener():void
		{
			dispatcher.addEventListener(CommandTypeDict.CMD_INIT_ROOMDATA,onInitFloorData);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(CommandTypeDict.CMD_INIT_ROOMDATA,onInitFloorData);
		}
	}
}