package main
{
	import mx.core.UIComponent;
	
	import interfaces.ICKitchenApplication;
	import interfaces.ICKithenModule;
	
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