package core.view
{
	import cloud.core.datas.containers.CVectorContainer;
	import cloud.core.events.CDataEvent;
	import cloud.core.utils.CVectorUtil;
	
	import core.model.GlobalModel;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
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
		public var scene:CScene3D;
		[Inject]
		public var wallModel:WallDataModel;
		
		public function get wallSet():WallViewSet
		{
			return _view as WallViewSet;
		}
		
		public function WallViewSetMediator()
		{
			super("WallViewSetMediator");
		}
		private function onInitRoomData(evt:CDataEvent):void
		{
			var roundPoints:Array=evt.data.points;
			var pointContainer:CVectorContainer=CVectorUtil.Instance.transformPointsToVector3Ds(roundPoints);
			var roomID:String=evt.data.roomID;
			wallModel.createRoomVo(roomID);
			wallModel.createWallVOs(global.wallThickness,global.wallHeight,roomID,pointContainer);
			wallSet.createWallViews(wallModel.walls);
			pointContainer.back();
			dispatchDatasEvent(CommandTypeDict.CMD_INIT_DOUBLELIST);
		}
		override protected function addListener():void
		{
			dispatcher.addEventListener(CommandTypeDict.CMD_INIT_ROOMDATA,onInitRoomData);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(CommandTypeDict.CMD_INIT_ROOMDATA,onInitRoomData);
		}
	}
}