package interfaces
{
	import cloud.core.interfaces.ICStatus;

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
	}
}