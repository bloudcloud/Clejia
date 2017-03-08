package core
{
	import L3DLibrary.L3DMaterialInformations;
	
	import cloud.rl2.BaseMediator;
	
	import dict.EventTypeDict;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import l3dbuild.geometry.L3DLoadHelper;
	
	import spark.components.Button;
	
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

		private function onClick(evt:MouseEvent):void
		{
			if(evt.target is Button)
			{
				dispatcher.dispatchEvent(new DatasEvent((evt.target as Button).id));
			}
		}
		override protected function addListener():void
		{
			application3D.addEventListener(MouseEvent.CLICK,onClick);
		}
		override protected function removeListener():void
		{
			application3D.removeEventListener(MouseEvent.CLICK,onClick);
		}
	}
}