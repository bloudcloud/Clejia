package modules.kitchen.command
{
	/**
	 *	厨房模块服务启动命令类
	 * @author cloud
	 */
	import modules.kitchen.service.CCabinetRL2Service;
	import modules.main.service.CDownloadRL2Service;
	
	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	
	public class KitchenServiceStartCmd implements ICommand
	{
		[Inject]
		public var downloadRL2Service:CDownloadRL2Service;
		[Inject]
		public var cabinetRL2Service:CCabinetRL2Service;
		
		public function KitchenServiceStartCmd()
		{
		}
		
		public function execute():void
		{
			downloadRL2Service.start();
			cabinetRL2Service.start();
		}
	}
}