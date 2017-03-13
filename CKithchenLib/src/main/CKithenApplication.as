package main
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import interfaces.ICKitchenApplication;
	import interfaces.ICKithenModule;
	
	import utils.DatasEvent;
	
	/**
	 *  厨房功能应用类
	 * @author cloud
	 */
	public class CKithenApplication extends UIComponent implements ICKitchenApplication
	{
		private var _kithenModule:CKithenModuleImp;
		
		public function CKithenApplication()
		{
			super();
		}
		
		private function onDeleteCabinet(evt:DatasEvent):void
		{
			var inputData:FurnitureInputData=evt.data as  FurnitureInputData;
			_kithenModule.deleteCabinet(inputData.furnitureID,inputData.furnitureType);
		}
		public function getKitchenModuleImp():ICKithenModule
		{
			return _kithenModule ||= new CKithenModuleImp();
		}
		public function start():void
		{
			_kithenModule.start();
		}
		public function stop():void
		{
			_kithenModule.stop();
		}
	}
}