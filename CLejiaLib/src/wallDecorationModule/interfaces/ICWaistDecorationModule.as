package wallDecorationModule.interfaces
{
	import main.model.vo.task.ITaskVO;
	
	public interface ICWaistDecorationModule extends ICDecorationModule
	{
		/**
		 * 添加装饰任务 
		 * @param taskVo		
		 * @param stage3d
		 * 
		 */		
		function addDecorationTask(taskVo:ITaskVO):void;
	}
}