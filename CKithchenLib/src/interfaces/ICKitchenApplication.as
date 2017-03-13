package interfaces
{
	import L3DLibrary.L3DMaterialInformations;

	/**
	 *  应用接口
	 * @author cloud
	 */
	public interface ICKitchenApplication
	{
		/**
		 * 获取厨房功能模块的实例 
		 * @return ICKithenModule
		 */		
		function getKitchenModuleImp():ICKithenModule;
		/**
		 * 启动厨房功能应用 
		 * 
		 */		
		function start():void;
		/**
		 * 停止厨房功能应用 
		 * 
		 */		
		function stop():void;
	}
}