package interfaces
{
	/**
	 *  家具链表结构数据接口
	 * @author cloud
	 */
	public interface ICChainFurnitureVO extends ICFurnitureVO
	{
		/**
		 * 获取下一个节点 
		 * @return ICChainFurnitureVO
		 * 
		 */		
		function get next():ICChainFurnitureVO;
		/**
		 * 设置下一个节点 
		 * @param value
		 * 
		 */		
		function set next(value:ICChainFurnitureVO):void;
	}
}