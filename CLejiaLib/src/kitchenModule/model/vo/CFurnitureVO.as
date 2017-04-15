package kitchenModule.model.vo
{
	import main.model.vo.CObject3DVO;

	/**
	 * 家具数据
	 * @author cloud
	 */
	public class CFurnitureVO extends CObject3DVO
	{
		public var index:int;

		public function CFurnitureVO()
		{
			super();
		}
		
		override public function update(vo:*):void
		{
			super.update(vo);
			index=vo.index;
		}
		
		override public function toString():String
		{
			return "index:"+index+" "+ super.toString();
		}
	}
}