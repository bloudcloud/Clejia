package core.service
{
	/**
	 *	基础服务类
	 * @author cloud
	 */
	import flash.events.IEventDispatcher;
	
	import cloud.core.events.CDataEvent;
	
	import rl2.mvcs.service.ICService;
	
	import robotlegs.bender.framework.api.ILogger;
	
	public class BaseRL2Service implements ICService
	{
		[Inject]
		public var logger:ILogger;
		[Inject]
		public var dispatcher:IEventDispatcher;
		
		protected var _className:String;

		public function get className():String
		{
			return _className;
		}
				
		public function BaseRL2Service(clsName:String="BaseRL2Service")
		{
			_className=clsName;
		}
		
		protected function addListener():void
		{
			
		}
		
		protected function removeListener():void
		{
			
		}
		
		protected function dispatchDataEvent(type:String,data:*=null):void
		{
			if(dispatcher.hasEventListener(type))
				dispatcher.dispatchEvent(new CDataEvent(type,data));
		}
		public function start():void
		{
			addListener();
			logger.info((_className+"->start()"));
		}
		
		public function stop():void
		{
			removeListener();
			logger.info((_className+"->stop()"));
		}
	}
}