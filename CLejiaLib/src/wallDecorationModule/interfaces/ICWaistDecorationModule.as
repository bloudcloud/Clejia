package wallDecorationModule.interfaces
{
	import main.model.vo.task.ITaskVO;

	public interface ICWaistDecorationModule
	{
		/**
		 * 添加3D腰线任务数据 
		 * @param vo
		 * 
		 */		
		function addWaist3DTask(vo:ITaskVO):void
	}
}