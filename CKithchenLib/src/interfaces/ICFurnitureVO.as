package interfaces
{
	/**
	 *  3D家具数据接口
	 * @author cloud
	 */
	public interface ICFurnitureVO extends IFurnitureProperty
	{
		/**
		 * 更新数据 
		 * @param vo
		 * 
		 */		
		function updateVo(vo:Object):void;
		/**
		 * 数据字段转换成字符串
		 * @return String
		 * 
		 */		
		function toString():String;
		/**
		 * 清空数据 
		 * 
		 */		
		function clear():void;
	}
}