package model.vo
{
	import interfaces.ICChainFurnitureVO;

	/**
	 *  基础家具链表结构数据类
	 * @author cloud
	 */
	public class BaseChainFurnitureVO extends BaseFurnitureVO implements ICChainFurnitureVO
	{
		protected var _next:ICChainFurnitureVO;
		
		public function get next():ICChainFurnitureVO
		{
			return _next;
		}
		public function set next(node:ICChainFurnitureVO):void
		{
			_next = node;
		}
		
		public var isInChain:Boolean;
		
		public function BaseChainFurnitureVO()
		{
			super();
		}
		
		override public function updateVo(vo:Object):void
		{
			super.updateVo(vo);
			if(vo is ICChainFurnitureVO)
			{
				var cabinetVo:BaseChainFurnitureVO=vo as BaseChainFurnitureVO;
				this.next=cabinetVo.next;
			}
		}
		override public function toString():String
		{
			return super.toString()+"next:"+next+"\n";
		}
		override public function clear():void
		{
			super.clear();
			_next=null;
		}
	}
}