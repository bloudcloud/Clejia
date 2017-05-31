package 
{
	import kitchenModule.interfaces.ICKitchenModule;
	
	import wallDecorationModule.interfaces.ICClapboardDecorationModule;
	import wallDecorationModule.interfaces.ICWaistDecorationModule;
	
	/**
	 *  应用接口
	 * @author cloud
	 */
	public interface ICLejiaModules
	{
		/**
		 * 获取厨房功能模块的实例 
		 * @return ICKithenModule
		 */		
		function get kitchenModule():ICKitchenModule;		
		/**
		 * 获取装修模块的实例 
		 * @return ICDecorationModule
		 * 
		 */		
		function get waistDecorationModule():ICWaistDecorationModule;
		/**
		 * 获取护墙板模块的实例 
		 * @return ICClapboardDecorationModule
		 * 
		 */		
		function get clapboardDecorationModule():ICClapboardDecorationModule;
	}
}