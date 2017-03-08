package modules.kitchen.service
{
	import L3DLibrary.L3DMaterialInformations;
	
	import a3d.support.Scene3D;
	
	import core.service.BaseService;
	
	import dict.EventTypeDict;
	
	import flash.events.Event;
	
	import l3dbuild.geometry.L3DLoadHelper;
	
	import robotlegs.bender.framework.api.IContext;
	
	import utils.DatasEvent;
	
	/**
	 *  2D命令服务类
	 * @author cloud
	 */
	public class Command2DService extends BaseService
	{
		[Inject]
		public var context:IContext;
		[Inject]
		public var scene:Scene3D;
		
		private var _loader:L3DLoadHelper;
		
		public function Command2DService()
		{
			super("Command2DService");
		}
		
		private function onLoadMesh(evt:DatasEvent):void
		{
			_loader.Load(evt.data as L3DMaterialInformations);
		}
		private function onLoadComplete(evt:Event):void
		{
			switch(_loader.mesh.family)
			{
				case "单柜":
					dispatcher.dispatchEvent(new DatasEvent(EventTypeDict.CMD_CREATE_CABINET,_loader.mesh));
					break;
				default:
					throw new Error(String("未知类型，无法识别！"+_loader.mesh.family));
					break;
			}
			
		}
		override protected function addListener():void
		{
			_loader.addEventListener(Event.COMPLETE,onLoadComplete);
			context.addEventListener(EventTypeDict.CMD_GET_MATERIAL_INFO,onLoadMesh);
		}
		override protected function removeListener():void
		{
			_loader.removeEventListener(Event.COMPLETE,onLoadComplete);
			context.removeEventListener(EventTypeDict.CMD_GET_MATERIAL_INFO,onLoadMesh);
		}
		override public function start():void
		{
			_loader ||=new L3DLoadHelper(scene.stage3D);
			super.start();
		}
	}
}