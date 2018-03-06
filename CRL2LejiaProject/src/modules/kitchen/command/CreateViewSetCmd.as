package modules.kitchen.command
{
	import cloud.core.events.CDataEvent;
	
	import main.a3d.support.CScene3D;
	
	import robotlegs.bender.bundles.mvcs.Command;
	
	/**
	 *  创建可视对象集合命令
	 * @author cloud
	 */
	public class CreateViewSetCmd extends Command
	{
		[Inject]
		public var evt:CDataEvent;
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