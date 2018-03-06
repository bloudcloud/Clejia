package main.dict
{
	/**
	 * 事件类型定义类
	 * @author cloud
	 */
	public class EventTypeDict
	{
		public static const EVENT_INITCOMPLETE:String = "initComplete";
		public static const EVENT_LOADCOMPLETE:String = "loadComplete";
		public static const EVENT_LOADALLCOMPLETE:String = "loadAllComplete";
		/**
		 *  加载失败 
		 */		
		public static const EVENT_LOADERROR:String = "loadError";
		
		public function EventTypeDict()
		{
		}
	}
}