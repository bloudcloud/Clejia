package main
{
	import mx.core.UIComponent;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.model.BaseDataModel;
	
	import kitchenModule.CKitchenModuleImp;
	import kitchenModule.interfaces.ICKitchenModule;
	
	import wallDecorationModule.CDecorationModuleImp;
	import wallDecorationModule.interfaces.ICDecorationModule;
	
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
		/**
		 * 初始化数据 
		 * @param data
		 * 
		 */		
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