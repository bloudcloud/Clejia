package core
{
	import core.model.GlobalModel;
	
	import flash.events.IEventDispatcher;
	
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.framework.api.IConfig;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.LogLevel;
	
	public class AppConfig implements IConfig
	{
		[Inject]
		public var context:IContext;
		[Inject]
		public var commandMap:IEventCommandMap;
		[Inject]
		public var mediatorMap:IMediatorMap;
		[Inject]
		public var contextView:ContextView;
		[Inject]
		public var eventDispatcher:IEventDispatcher;
		
		public function AppConfig()
		{
			
		}
		
		public function configure():void
		{
			context.logLevel=LogLevel.DEBUG;
			//数据模型
			context.injector.map(GlobalModel).asSingleton();
			//视图
			mediatorMap.map(CApplication3D).toMediator(CApplication3DMediator);
			//控制命令
			
			//服务
//			context.injector.map(GlobalService).asSingleton(true);
//			(context.injector.getInstance(GlobalService) as GlobalService).start();
		}
	}
}