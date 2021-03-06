package modules.decoration
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import alternativa.engine3d.core.View;
	
	import core.view.FloorViewSet;
	import core.view.FloorViewSetMediator;
	import core.view.CScene3DMediator;
	import core.view.WallViewSet;
	import core.view.WallViewSetMediator;
	
	import main.model.WallDataModel;
	
	import modules.decoration.controller.command.DecorationServiceStartCmd;
	import modules.decoration.service.CDecorationRL2Service;
	import modules.main.service.CDownloadRL2Service;
	
	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.framework.api.IConfig;
	import robotlegs.bender.framework.api.IContext;
	
	/**
	 * 装修模块配置类
	 * @author cloud
	 */
	public class DecorationModuleConfig implements IConfig
	{
		[Inject]
		public var context:IContext;
		[Inject]
		public var commandMap:IEventCommandMap;
		[Inject]
		public var mediatorMap:IMediatorMap;
		[Inject]
		public var dispatcher:IEventDispatcher;
		
		public function DecorationModuleConfig()
		{
		}
		
		public function configure():void
		{
			//数据模型
			context.injector.map(WallDataModel).asSingleton();
			//视图
			mediatorMap.map(View).toMediator(CScene3DMediator);
			mediatorMap.map(FloorViewSet).toMediator(FloorViewSetMediator);
			mediatorMap.map(WallViewSet).toMediator(WallViewSetMediator);
			//控制命令
			commandMap.map(Event.INIT).toCommand(DecorationServiceStartCmd);
			//服务
			context.injector.map(CDownloadRL2Service).asSingleton();
			context.injector.map(CDecorationRL2Service).asSingleton();
			dispatcher.dispatchEvent(new Event(Event.INIT));
		}
	}
}