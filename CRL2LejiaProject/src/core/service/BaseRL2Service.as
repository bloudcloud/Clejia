package core.service
{
	/**
	 *	
	 * @author cloud
	 */
	import flash.events.IEventDispatcher;
	
	import rl2.mvcs.service.ICService;
	
	import robotlegs.bender.framework.api.ILogger;
	
	import utils.DatasEvent;
	
	public class BaseRL2Service implements ICService
	{
		[Inject]
		public var logger:ILogger;
		[Inject]
		public var dispatcher:IEventDispatcher;
		
		protected var _type:String;

		public function get type():String
		{
			return _type;
		}
				
		public function BaseRL2Service(type:String="")
		{
			_type=type
		}
		
		protected function addListener():void
		{
			
		}
		
		protected function removeListener():void
		{
			
		}
		
		protected function dispatchDatasEvent(type:String,data:*=null):void
		{
			if(dispatcher.hasEventListener(type))
				dispatcher.dispatchEvent(new DatasEvent(type,data));
		}
		public function start():void
		{
			addListener();
			logger.info((_type+"->start()"));
		}
		
		public function stop():void
		{
			removeListener();
			logger.info((_type+"->stop()"));
		}
	}
}