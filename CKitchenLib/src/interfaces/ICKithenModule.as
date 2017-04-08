package interfaces 
{
	import flash.geom.Vector3D;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICStatus;

	/**
	 *  厨房模块接口
	 * @author cloud
	 */
	public interface ICKithenModule extends ICStatus
	{
		/**
		 * 是否拥有地面ID 
		 * @param floorID	地面ID
		 * @return Boolean
		 * 
		 */		
		function hasFloorID(floorID:String):Boolean;
		/**
		 * 导入墙的围点3D坐标 
		 * @param poses	3D围点数组
		 * @param floorID	 所围成的地面ID
		 * 
		 */		
		function importWallPosition(poses:Vector.<Vector3D>,floorID:String):void;
		/**
		 * 创建厨房家具可视对象数据 
		 * @param furnitureID	家具唯一id
		 * @param furnitureDirection	家具的方向
		 * @param furnitureType	家具类型
		 * @param furnitureLength	家具的长
		 * @param furnitureWidth	家具的宽
		 * @param furnitureHeight	家具的高
		 * 
		 */
		function createKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void;
		/**
		 * 删除3D家具可视对象数据 
		 * @param furnitureID	家具唯一id
		 * @param furnitureDirection	家具的方向
		 * @param furnitureType	家具类型
		 * 
		 */	
		function deleteKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint):void;
//		/**
//		 * 更新家具的唯一ID 
//		 * @param furnitureID	旧的家具ID
//		 * @param furnitureType	家具类型
//		 * @param uniqueID	新的家具唯一ID
//		 * 
//		 */		
//		function updateFurnitureUniqueID(furnitureID:String,furnitureType:uint,uniqueID:String):void;
		/**
		 * 执行移动处理
		 * @param furnitureDir 家具的方向
		 * @param furnitureType	家具的类型
		 * @param position	家具的最新坐标
		 * @return Boolean	是否中断移动
		 * 
		 */				
		function excuteMove(furnitureDir:int,furnitureType:uint,position:Vector3D):Boolean;
		/**
		 * 执行鼠标按下处理  
		 * @param furnitureID	家具的唯一id
		 * @param furnitureDir		家具的方向
		 * @param furnitureType	家具的类型
		 * @return Boolean
		 * 
		 */
		function excuteMouseDown(furnitureID:String,furnitureDir:int,furnitureType:uint):Boolean;
		/**
		 * 执行鼠标释放处理 
		 * @param furnitureType	家具的类型
		 * @return Vector.<ICData>		反生改变的家具数据集合
		 * 
		 */		
		function excuteMouseUp(furnitureType:uint):Vector.<ICData>;
		/**
		 * 创建挡板  
		 * @param ptl 	左上方墙的顶点坐标
		 * @param ptr	右上方墙的顶点坐标
		 * @param pbl	左下方墙的顶点坐标
		 * @param pbr	右下方墙的顶点坐标
		 * @return IFurnitureSet 家具数据集合,接口的实现是Mesh的扩展
		 * 
		 */			
		function createShelter(ptl:Vector3D,ptr:Vector3D,pbl:Vector3D,pbr:Vector3D):ICFurnitureSet
		/**
		 * 创建台面数据  
		 * @return IFurnitureSet 家具数据集合,接口的实现是Mesh的扩展
		 * 
		 */					
		function createTableBoard():ICFurnitureSet
		/**
		 * 清除
		 * 
		 */		
		function clear():void;
		/**
		 * 报价 
		 * 
		 */		
		function getQuotes():void;
	}
}