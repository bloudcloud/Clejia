package modules.kitchen.command
{
	import a3d.support.Scene3D;
	
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
		public var scene:Scene3D;
		
		public function CreateViewSetCmd()
		{
			super();
		}
		override public function execute():void
		{
			
		}
	}
}