package model.vo.task
{
	import model.vo.CObject3DVO;
	
	/**
	 * 任务数据
	 * @author cloud
	 */
	public class CTaskVO extends CObject3DVO implements ITaskVO
	{
		protected var _url:String;
		protected var _code:String;
		public var endCallback:Function;
		public var mesh:L3DMesh;
		
		public function CTaskVO()
		{
			super();
		}
		
		override public function clear():void
		{
			super.clear();
			endCallback=null;
			mesh=null;
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
	}
}