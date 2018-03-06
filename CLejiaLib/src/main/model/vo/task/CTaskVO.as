package main.model.vo.task
{
	
	/**
	 * 任务数据
	 * @author cloud
	 */
	public class CTaskVO extends CBaseTaskObject3DVO
	{
		private var _isMaterialTask:Boolean;
		
		public var endCallback:Function;

		public function get isMaterialTask():Boolean
		{
			return _isMaterialTask;
		}
		public function set isMaterialTask(value:Boolean):void
		{
			_isMaterialTask = value;
		}
		
		public function CTaskVO(clsName:String="CTaskVO")
		{
			super(clsName);
		}
		
		override public function clear():void
		{
			super.clear();
			endCallback=null;
		}
	}
}