package main
{
	import wallDecorationModule.interfaces.ICDecorationModule;
	import kitchenModule.interfaces.ICKitchenModule;
	
	/**
	 *  应用接口
	 * @author cloud
	 */
	public interface ICLejiaApplication
	{
		/**
		 * 获取厨房功能模块的实例 
		 * @return ICKithenModule
		 */		
		function getKitchenModuleImp():ICKitchenModule;		
		/**
		 * 获取装修模块的实例 
		 * @return ICDecorationModule
		 * 
		 */		
		function getDecorationModuleImp():ICDecorationModule;
	}
}