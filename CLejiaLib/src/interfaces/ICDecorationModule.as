package interfaces
{
	import flash.display.Stage3D;
	
	import cloud.core.interfaces.ICStatus;
	
	import model.vo.task.ITaskVO;
	
	/**
	 *  装修模块接口
	 * @author cloud
	 */
	public interface ICDecorationModule extends ICStatus
	{
//		/**
//		 * 创建腰线
//		 * @param source	样本L3D模型 
//		 * @param position	腰线中心点坐标
//		 * @param direction 腰线的方向
//		 * @param length	腰线的长度
//		 * @return Mesh	返回的腰线模型对象
//		 * 
//		 */			
//		function createWaistline(source:L3DMesh,position:Vector3D,direction:Vector3D,length:Number):Mesh;
		/**
		 * 添加装饰任务 
		 * @param taskVo
		 * @param stage3d
		 * 
		 */		
		function addDecorationTask(taskVo:ITaskVO,stage3d:Stage3D):void;
	}
}