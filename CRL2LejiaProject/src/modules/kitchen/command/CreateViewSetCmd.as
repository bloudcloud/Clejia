package modules.kitchen.command
{
	import main.a3d.support.CScene3D;
	
	import robotlegs.bender.bundles.mvcs.Command;
	
	import utils.DatasEvent;
	
	/**
	 *  创建可视对象集合命令
	 * @author cloud
	 */
	public class CreateViewSetCmd extends Command
	{
		[Inject]
		public var evt:DatasEvent;
		[Inject]
		public var scene:CScene3D;
		
		public function CreateViewSetCmd()
		{
			super();
		}
		override public function execute():void
		{
			
		}
	}
}