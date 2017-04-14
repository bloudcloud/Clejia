package main
{
	import mx.core.UIComponent;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.model.BaseDataModel;
	
	import interfaces.ICDecorationModule;
	import interfaces.ICKitchenModule;
	import interfaces.ICLejiaApplication;
	
	/**
	 *  厨房功能应用类
	 * @author cloud
	 */
	public class CKitchenApplication extends UIComponent implements ICLejiaApplication
	{
		private var _kithenModule:CKitchenModuleImp;
		private var _decorationModule:CDecorationModuleImp;
		private var _dataModel:BaseDataModel;
		
		public function CKitchenApplication()
		{
			super();
		}

		public function getKitchenModuleImp():ICKitchenModule
		{
			return _kithenModule ||= new CKitchenModuleImp();
		}
		public function getDecorationModuleImp():ICDecorationModule
		{
			return _decorationModule ||= new CDecorationModuleImp();
		}
		
		public function initData(data:ICData):void
		{
			_dataModel.addData(data);
		}
		
		public function start():void
		{
			_dataModel=new BaseDataModel();
			_kithenModule.start();
			_decorationModule.start();
		}
		public function stop():void
		{
			_dataModel=null;
			_kithenModule.stop();
			_decorationModule.stop();
		}
	}
}