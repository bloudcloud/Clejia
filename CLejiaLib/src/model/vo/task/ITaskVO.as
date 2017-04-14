package model.vo.task
{
	/**
	 * 任务数据
	 * @author cloud
	 */
	public interface ITaskVO
	{
		function get url():String;
		function set url(value:String):void;
		function get code():String;
		function set code(value:String):void;
	}
}