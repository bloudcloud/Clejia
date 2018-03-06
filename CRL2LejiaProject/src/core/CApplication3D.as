package core
{
	import flash.display.Stage;
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import L3DLibrary.L3DMaterialInformations;
	
	import cloud.core.events.CDataEvent;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
	import main.dict.EventTypeDict;
	
	import modules.decoration.DecorationModuleExtension;
	
	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.impl.Context;
	
	public class CApplication3D extends UIComponent
	{
		protected var _context: IContext;
		
		public var scene:CScene3D;
		
		public var init3DCompleteCallback:Function;
		
		public function CApplication3D()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		protected function initScene3D(stage:Stage):void
		{
			scene=new CScene3D(this,stage);
//			scene.controller.setObjectPosXYZ(-3000,-3000,4000);
//			scene.controller.lookAtXYZ(0,0,0);
//			scene.ground.visible=false;
//			setView3DVisible(false);
		}
		
		private function onAddToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddToStage);

			initApplication3D(stage);
		}
		protected function initContext():void
		{
			_context = new Context()
				.install(MVCSBundle,DecorationModuleExtension)
				.configure(AppConfig,new ContextView(this),scene);
			_context.addEventListener(EventTypeDict.EVENT_INITCOMPLETE,function(evt:CDataEvent):void
			{
				evt.currentTarget.removeEventListener(evt.type,arguments.callee);
				if(init3DCompleteCallback!=null)
					init3DCompleteCallback();
			});
		}
		private function onTransformEvent(event:Event):void
		{
			_context.dispatchEvent(new CDataEvent(event.type));
		}
		public function initApplication3D(stage:Stage):void
		{
			initScene3D(stage);
			initContext();
		}
		
		public function getMaterialInfo(info:L3DMaterialInformations):void
		{
			_context.dispatchEvent(new CDataEvent(CommandTypeDict.CMD_GET_MATERIAL_INFO,info));
		}
		/**
		 * 设置3D界面是否可见 
		 * @param value
		 * 
		 */		
		public function setView3DVisible(value:Boolean):void
		{
			scene.stage3D.visible=value;
			if(value)
			{
				this.visible=true;
				scene.diagram.x=this.width-scene.diagram.width;
				scene.diagram.visible=true;
				scene.controller.enable();
			}
			else
			{
				this.visible=false;
				scene.diagram.visible=false;
				scene.controller.disable();
			}
		}
	}
}