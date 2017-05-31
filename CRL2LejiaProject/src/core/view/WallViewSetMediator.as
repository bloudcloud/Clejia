package core.view
{
	import flash.geom.Vector3D;
	
	import mx.utils.UIDUtil;
	
	import cloud.core.singleton.CUtil;
	import cloud.core.singleton.CVector3DUtil;
	
	import core.model.GlobalModel;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
	import main.model.WallDataModel;
	
	import ns.cloudLib;
	
	import rl2.mvcs.view.BaseMediator;
	
	import utils.DatasEvent;
	
	import wallDecorationModule.CClapboardDecorationModuleImp;
	
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
		[Inject]
		public var decorationModule:CClapboardDecorationModuleImp;
		
		public function get wallSet():WallViewSet
		{
			return _view as WallViewSet;
		}
		
		public function WallViewSetMediator()
		{
			super("WallViewSetMediator");
		}
		private function onInitRoomData(evt:DatasEvent):void
		{
			var roundPoints:Array=evt.data as Array;
			var points:Vector.<Vector3D>=CVector3DUtil.instance.transformPointsToVector3Ds(roundPoints);
			var roomID:String=CUtil.instance.createUID();
			wallModel.createRoomVo(roomID);
			wallModel.createWallVOs(global.wallThickness,global.wallHeight,roomID,points);
			wallSet.createWallViews(wallModel.walls);
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