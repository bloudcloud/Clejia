package wallDecorationModule.model.vo
{
	import main.model.vo.task.CTaskVO;
	
	/**
	 * 装修任务数据
	 * @author cloud
	 */
	public class CDecorationTaskVO extends CTaskVO
	{
		public var regionRoundPoints:Array;
		
		public function CDecorationTaskVO()
		{
			super();
		}
		
		override public function clear():void
		{
			super.clear();
			regionRoundPoints=null;
		}
	}
}