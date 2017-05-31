package modules.decoration.controller.command
{
	import modules.decoration.service.ClapBoardDecorationRL2Service;
	import modules.decoration.service.CDecorationDownLoadRL2Service;
	
	import robotlegs.bender.bundles.mvcs.Command;
	
	/**
	 * 装修服务启动命令
	 * @author cloud
	 */
	public class DecorationServiceStartCmd extends Command
	{
		[Inject]
		public var downloadService:CDecorationDownLoadRL2Service;
		[Inject]
		public var clapboardService:ClapBoardDecorationRL2Service;
		
		public function DecorationServiceStartCmd()
		{
			super();
		}
		override public function execute():void
		{
			downloadService.start();
			clapboardService.start();
		}
	}
}