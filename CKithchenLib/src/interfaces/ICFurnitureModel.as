package interfaces
{
	/**
	 *  3D可视对象数据模型接口
	 * @author cloud
	 */
	public interface ICFurnitureModel
	{
		/**
		 * 添加可视对象数据 
		 * @param vo
		 * 
		 */		
		function addFurnitureVO(vo:ICFurnitureVO):void;
		/**
		 * 移除可视对象数据 
		 * @param vo
		 * 
		 */		
		function removeFurnitureVO(vo:ICFurnitureVO):void;
		/**
		 * 更新可视对象数据 
		 * @param vo
		 * 
		 */		
		function updateFurnitureVO(vo:Object):void;
		/**
		 * 通过唯一id获取可视对象数据 
		 * @param type
		 * @return ICMeshViewVO
		 * 
		 */		
		function getFurnitureVOByID(type:String):ICFurnitureVO;
		/**
		 * 清空数据 
		 * 
		 */		
		function clear():void;
	}
}