package kitchenModule.interfaces
{
	import cloud.core.interfaces.ICObject3DData;

	/**
	 *  家具集合接口
	 * @author cloud
	 */
	public interface ICFurnitureSet
	{
		/**
		 * 获取数据对象集合 
		 * @return Vector.<ICFurnitureVO>
		 * 
		 */		
		function get furnitureVos():Vector.<ICObject3DData>;
		/**
		 * 销毁家具集合对象
		 * 
		 */		
		function dispose():void
	}
}