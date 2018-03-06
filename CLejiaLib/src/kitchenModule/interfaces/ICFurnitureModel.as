package kitchenModule.interfaces
{

	import flash.geom.Vector3D;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;

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
		function createFurnitureVo(furnitureID:String,furnitureDirection:int,furnitureType:uint,length:uint,width:uint,height:uint):CBaseObject3DVO;
		/**
		 * 删除家具数据 
		 * @param furnitureID
		 * @param furnitureDirection
		 * 
		 */
		function deleteFurnitureVo(furnitureID:String):void;
		/**
		 * 执行移动处理
		 * @param furnitureDir 家具的方向
		 * @param position	家具的最新坐标
		 * @return Boolean
		 * 
		 */
		function excuteMove(furnitureDir:int,position:Vector3D):Boolean;
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
		/**
		 * 执行结束 
		 * 
		 */		
		function excuteEnd():void;
		/**
		 * 清理数据 
		 * 
		 */		
		function clear():void;
	}
}