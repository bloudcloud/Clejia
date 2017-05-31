package wallDecorationModule.model.vo
{
	import main.model.vo.CObject3DVO;
	/**
	 *  区域数据类
	 * @author cloud
	 * 
	 */	
	public class CRegionVO extends CObject3DVO
	{
		/**
		 * 所在房间中的墙的索引 
		 */		
		public var indexInRoom:int;
		/**
		 *  所在墙中的区域的索引
		 */		
		public var indexInWall:int;
		
		public function CRegionVO()
		{
			super();
		}
		override public function clear():void
		{
			super.clear();
		}
	}
}