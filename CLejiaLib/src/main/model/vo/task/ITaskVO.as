package main.model.vo.task
{
	import cloud.core.interfaces.ICData;

	/**
	 * 任务数据
	 * @author cloud
	 */
	public interface ITaskVO extends ICData
	{
		function get url():String;
		function set url(value:String):void;
		function get code():String;
		function set code(value:String):void;
		function get material():String;
		function set material(value:String):void;
	}
}