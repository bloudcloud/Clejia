package modules.decoration.controller.command
{
	import modules.decoration.service.CDecorationRL2Service;
	import modules.main.service.CDownloadRL2Service;
	
	import robotlegs.bender.bundles.mvcs.Command;
	
	/**
	 * 装修服务启动命令
	 * @author cloud
	 */
	public class DecorationServiceStartCmd extends Command
	{
		[Inject]
		public var downloadService:CDownloadRL2Service;
		[Inject]
		public var clapboardService:CDecorationRL2Service;
		
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