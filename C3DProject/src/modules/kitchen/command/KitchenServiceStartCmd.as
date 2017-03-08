package modules.kitchen.command
{
	/**
	 *	厨房模块服务启动命令类
	 * @author cloud
	 */
	import a3d.support.Scene3D;
	
	import core.view.FloorViewSet;
	import core.view.WallViewSet;
	
	import modules.kitchen.service.Command2DService;
	import modules.kitchen.view.CabinetViewSet;
	
	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	
	public class KitchenServiceStartCmd implements ICommand
	{
		[Inject]
		public var scene:Scene3D;
		[Inject]
		public var command2DService:Command2DService;
		
		public function KitchenServiceStartCmd()
		{
		}
		
		public function execute():void
		{
			command2DService.start();
			
			scene.addChild(new FloorViewSet());
			scene.addChild(new WallViewSet());
			scene.addChild(new CabinetViewSet());
		}
	}
}