package wallDecorationModule.interfaces
{
	import flash.display.Stage3D;
	
	import cloud.core.interfaces.ICDataModule;
	import cloud.core.interfaces.ICStatus;
	
	/**
	 *  装修模块接口
	 * @author cloud
	 */
	public interface ICDecorationModule extends ICStatus,ICDataModule
	{
		/**
		 * 初始化装修模块 
		 * @param stage3d	装修3D舞台对象
		 * 
		 */		
		function initDecorationModule(stage3d:Stage3D):void
		/**
		 * 执行任务 
		 * 
		 */		
		function excuteTask():Boolean;
	}
}