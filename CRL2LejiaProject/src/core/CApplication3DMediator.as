package core
{
	import dict.CommandTypeDict;
	
	import rl2.mvcs.view.BaseMediator;
	
	import utils.DatasEvent;
	
	/**
	 *	
	 * @author cloud
	 */
	public class CApplication3DMediator extends BaseMediator
	{
		private function get application3D():CApplication3D
		{
			return _view as CApplication3D;
		}
		public function CApplication3DMediator()
		{
			super("CApplication3DMediator");
		}
		private function onDatasEventHandler(evt:DatasEvent):void
		{
			dispatchDatasEvent(evt.type,evt.data);
		}
		override protected function addListener():void
		{
			application3D.addEventListener(CommandTypeDict.CMD_INIT_ROOMDATA,onDatasEventHandler);
			application3D.addEventListener(CommandTypeDict.CMD_CREATE_TABLE_BOARD,onDatasEventHandler);
			application3D.addEventListener(CommandTypeDict.CMD_CREATE_SHELTER,onDatasEventHandler);
			//DecorationModule
			application3D.addEventListener(CommandTypeDict.CMD_SET_XMLPLAN_DATAS,onDatasEventHandler);
			application3D.addEventListener(CommandTypeDict.CMD_START_LOADPLAN,onDatasEventHandler);
			application3D.addEventListener(CommandTypeDict.CMD_START_LOADMATERIAL,onDatasEventHandler);
			application3D.addEventListener(CommandTypeDict.CMD_START_LOADMESH,onDatasEventHandler);
			application3D.addEventListener(CommandTypeDict.CMD_DECORATION_SELECTWALL,onDatasEventHandler);
			application3D.addEventListener(CommandTypeDict.CMD_USE_DECORATIONPLAN,onDatasEventHandler);
			application3D.addEventListener(CommandTypeDict.CMD_OPEN_SCENE3D,onDatasEventHandler);
			application3D.addEventListener(CommandTypeDict.CMD_CLOSE_SCENE3D,onDatasEventHandler);
		}
		override protected function removeListener():void
		{
			application3D.removeEventListener(CommandTypeDict.CMD_INIT_ROOMDATA,onDatasEventHandler);
			application3D.removeEventListener(CommandTypeDict.CMD_CREATE_TABLE_BOARD,onDatasEventHandler);
			application3D.removeEventListener(CommandTypeDict.CMD_CREATE_SHELTER,onDatasEventHandler);
			//DecorationModule
			application3D.removeEventListener(CommandTypeDict.CMD_SET_XMLPLAN_DATAS,onDatasEventHandler);
			application3D.removeEventListener(CommandTypeDict.CMD_START_LOADPLAN,onDatasEventHandler);
			application3D.removeEventListener(CommandTypeDict.CMD_START_LOADMATERIAL,onDatasEventHandler);
			application3D.removeEventListener(CommandTypeDict.CMD_START_LOADMESH,onDatasEventHandler);
			application3D.removeEventListener(CommandTypeDict.CMD_DECORATION_SELECTWALL,onDatasEventHandler);
			application3D.removeEventListener(CommandTypeDict.CMD_USE_DECORATIONPLAN,onDatasEventHandler);
			application3D.removeEventListener(CommandTypeDict.CMD_OPEN_SCENE3D,onDatasEventHandler);
			application3D.removeEventListener(CommandTypeDict.CMD_CLOSE_SCENE3D,onDatasEventHandler);
		}
	}
}