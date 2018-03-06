package 
{
	import kitchenModule.interfaces.ICKitchenModule;
	
	import wallDecorationModule.interfaces.ICDecorationModule;
	
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
		function get waistDecorationModule():ICDecorationModule;
		/**
		 * 获取护墙板模块的实例 
		 * @return ICDecorationModule
		 * 
		 */		
		function get clapboardDecorationModule():ICDecorationModule;
		/**
		 * 获取背景墙功能模块的实例 
		 * @return ICDecorationModule
		 * 
		 */		
		function get backgroundWallModule():ICDecorationModule;
		/**
		 * 获取参数化门功能模块的实例 
		 * @return ICDecorationModule
		 * 
		 */		
		function get doorModule():ICDecorationModule;
	}
}