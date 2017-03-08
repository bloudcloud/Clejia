package core.service
{
	/**
	 *	
	 * @author cloud
	 */
	import flash.events.IEventDispatcher;
	
	import cloud.core.mvcs.service.IService;
	
	import robotlegs.bender.framework.api.ILogger;
	
	public class BaseService implements IService
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
				
		public function BaseService(type:String="")
		{
			_type=type
		}
		
		protected function addListener():void
		{
			
		}
		
		protected function removeListener():void
		{
			
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