package interfaces
{
	import flash.geom.Vector3D;
	
	import cloud.core.interfaces.ICData;

	/**
	 *  家具数据模型接口
	 * @author cloud
	 */
	public interface ICFurnitureModel
	{
		/**
		 * 创建家具数据 
		 * @param furnitureID
		 * @param furnitureDirection
		 * @param furnitureType
		 * @param length
		 * @param width
		 * @param height
		 * 
		 */	
		function createFurnitureVo(furnitureID:String,furnitureDirection:int,furnitureType:uint,length:uint,width:uint,height:uint):void;
		/**
		 * 删除家具数据 
		 * @param furnitureID
		 * @param furnitureDirection
		 * 
		 */
		function deleteFurnitureVo(furnitureID:String,furnitureDirection:int):void;
		/**
		 * 执行移动处理
		 * @param furnitureDir 家具的方向
		 * @param position	家具的最新坐标
		 * @return Vector.<ICData>
		 * 
		 */
		function excuteMove(furnitureDir:int,position:Vector3D):Vector.<ICData>;
		/**
		 * 执行鼠标按下处理  
		 * @param furnitureID
		 * @param furnitureDir
		 * @return Boolean
		 * 
		 */
		function excuteMouseDown(furnitureID:String,furnitureDir:int):Boolean;
		/**
		 * 执行鼠标释放处理 
		 * @return Vector.<ICData>
		 * 
		 */
		function excuteMouseUp():Vector.<ICData>;
	}
}