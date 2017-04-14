package collection
{
	import cloud.core.collections.DoubleNode;
	import cloud.core.interfaces.ICData;
	
	import model.vo.CFurnitureVO;
	
	/**
	 *  家具节点
	 * @author cloud
	 */
	public class FurnitureNode extends DoubleNode
	{
		public function get endNode():FurnitureNode
		{
			return _next as FurnitureNode;
		}
		
		public function get headNode():FurnitureNode
		{
			return _prev as FurnitureNode;
		}
		
		final public function get furnitureVo():CFurnitureVO
		{
			return nodeData as CFurnitureVO;
		}
		
		public function FurnitureNode(source:ICData)
		{
			super(source);
		}
	}
}