package core
{
	import dict.EventTypeDict;
	
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

		private function onCreateFurniture(evt:DatasEvent):void
		{
			dispatcher.dispatchEvent(new DatasEvent(evt.type));
		}
		
		override protected function addListener():void
		{
			application3D.addEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateFurniture);
			application3D.addEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateFurniture);
		}
		override protected function removeListener():void
		{
			application3D.removeEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateFurniture);
			application3D.removeEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateFurniture);
		}
	}
}