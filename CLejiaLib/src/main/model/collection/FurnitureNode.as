package main.model.collection
{
	import cloud.core.collections.DoubleNode;
	import cloud.core.interfaces.ICData;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
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
		
		final public function get furnitureVo():CBaseObject3DVO
		{
			return nodeData as CBaseObject3DVO;
		}
		
		public function FurnitureNode(source:ICData)
		{
			super(source);
		}
	}
}