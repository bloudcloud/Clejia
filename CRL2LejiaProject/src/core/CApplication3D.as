package core
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import L3DLibrary.L3DMaterialInformations;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
	
	import modules.decoration.DecorationModuleExtension;
	
	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;
	
	import utils.DatasEvent;
	
	public class CApplication3D extends UIComponent
	{
		protected var _context: IContext;
		
		public var scene:CScene3D;

		public function CApplication3D()
		{
			super();

			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		private function initScene3D():void
		{
			scene=new CScene3D(this,stage);
//			scene.controller.setObjectPosXYZ(-3000,-3000,4000);
//			scene.controller.lookAtXYZ(0,0,0);
			scene.ground.visible=false;
			setView3DVisible(false);
		}
		
		private function onAddToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddToStage);

			initScene3D();
			
			_context = new Context()
//				.install(MVCSBundle,KitchenModuleExtension)
				.install(MVCSBundle,DecorationModuleExtension)
				.configure(AppConfig,new ContextView(this),scene);
		}
		private function onTransformEvent(event:Event):void
		{
			_context.dispatchEvent(new DatasEvent(event.type));
		}
		
		public function getMaterialInfo(info:L3DMaterialInformations):void
		{
			_context.dispatchEvent(new DatasEvent(CommandTypeDict.CMD_GET_MATERIAL_INFO,info));
		}
		
		public function setView3DVisible(value:Boolean):void
		{
			scene.stage3D.visible=value;
			if(value)
			{
				scene.stage3D.visible=true;
				scene.controller.enable();
			}
			else
			{
				scene.stage3D.visible=false;
				scene.controller.disable();
			}
		}
	}
}