package main.model.vo.task
{
	import main.model.vo.CObject3DVO;
	
	/**
	 * 任务数据
	 * @author cloud
	 */
	public class CTaskVO extends CObject3DVO implements ITaskVO
	{
		protected var _url:String;
		protected var _code:String;
		protected var _material:String;
		
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
		
		public function CTaskVO()
		{
			super();
		}
		
		override public function clear():void
		{
			super.clear();
			endCallback=null;
		}
		public function get url():String
		{
			return _url;
		}
		
		public function set url(value:String):void
		{
			_url=value;
		}
		
		public function get code():String
		{
			return _code;
		}
		
		public function set code(value:String):void
		{
			_code=value;
		}
		
		public function get material():String
		{
			return _material;
		}
		
		public function set material(value:String):void
		{
			_material=value;
		}
	}
}