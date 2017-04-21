package 
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
	public class CLejiaModules extends UIComponent implements ICLejiaModules
	{
		private var _kithenModule:CKitchenModuleImp;
		private var _decorationModule:CDecorationModuleImp;
		private var _dataModel:BaseDataModel;
		
		public function CLejiaModules()
		{
			super();
		}
		/**
		 * 初始化数据 
		 * @param data
		 * 
		 */		
		public function initData(data:ICData):void
		{
			_dataModel.addCacheData(data);
		}
		/**
		 * 启动应用 
		 * 
		 */		
		public function start():void
		{
			_dataModel=new BaseDataModel();
			_kithenModule.start();
			_decorationModule.start();
		}
		/**
		 * 停止应用 
		 * 
		 */		
		public function stop():void
		{
			_dataModel=null;
			_kithenModule.stop();
			_decorationModule.stop();
		}
		public function get kitchenModule():ICKitchenModule
		{
			return _kithenModule ||= new CKitchenModuleImp();
		}
		public function get decorationModule():ICDecorationModule
		{
			return _decorationModule ||= new CDecorationModuleImp();
		}
	}
}