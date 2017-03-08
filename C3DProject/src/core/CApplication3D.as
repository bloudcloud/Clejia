package core
{
	import L3DLibrary.L3DMaterialInformations;
	
	import a3d.support.Scene3D;
	
	import core.test.ButtonPanel;
	
	import dict.EventTypeDict;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import rl2.extension.KithenModuleExtension;
	
	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;
	
	import utils.DatasEvent;
	
	public class CApplication3D extends UIComponent
	{
		protected var _context: IContext;
		
		public var scene:Scene3D;

		public function CApplication3D()
		{
			super();

			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		private function initPanel():void
		{
			var panel:ButtonPanel=new ButtonPanel();
//			panel.createTableBoard.addEventListener(MouseEvent.CLICK,onCreateTableBoard);
//			panel.createShelter.addEventListener(MouseEvent.CLICK,onCreateShelter);
			this.addChild(panel);
		}
		private function initScene3D():void
		{
			scene=new Scene3D(this,stage);
			scene.controller.setObjectPosXYZ(0,-2500,1000);
			scene.controller.lookAtXYZ(0,0,0);
			scene.ground.visible=false;
		}
		
		private function onAddToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddToStage);
			
			initPanel();
			initScene3D();
			
//			this.addEventListener(EventType.CMD_CREATE_TABLE_BOARD,onTransformEvent);
//			this.addEventListener(EventType.CMD_CREATE_SHELTER,onTransformEvent);
			
			_context = new Context()
				.install(MVCSBundle,KithenModuleExtension)
				.configure(AppConfig,new ContextView(this),scene);
		}
		private function onTransformEvent(event:Event):void
		{
			_context.dispatchEvent(new DatasEvent(event.type));
		}
		
		public function getMaterialInfo(info:L3DMaterialInformations):void
		{
			_context.dispatchEvent(new DatasEvent(EventTypeDict.CMD_GET_MATERIAL_INFO,info));
		}
	}
}