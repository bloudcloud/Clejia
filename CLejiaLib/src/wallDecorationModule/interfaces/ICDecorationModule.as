package wallDecorationModule.interfaces
{
	import flash.display.Stage3D;
	
	import cloud.core.interfaces.ICDataModule;
	import cloud.core.interfaces.ICStatus;
	
	import main.model.vo.task.ITaskVO;
	
	/**
	 *  装修模块接口
	 * @author cloud
	 */
	public interface ICDecorationModule extends ICStatus,ICDataModule
	{
		/**
		 * 添加装饰任务 
		 * @param taskVo
		 * @param stage3d
		 * 
		 */		
		function addDecorationTask(taskVo:ITaskVO,stage3d:Stage3D):void;
	}
}