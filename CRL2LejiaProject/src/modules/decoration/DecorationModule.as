package modules.decoration
{
	import flash.events.IEventDispatcher;
	
	import alternativa.engine3d.core.events.Event3D;
	
	import core.view.BaseFurnitureViewSet;
	
	import main.a3d.support.CScene3D;
	
	import rl2.extension.IRL2Module;
	
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.ILogger;
	
	/**
	 * 
	 * @author cloud
	 */
	public class DecorationModule implements IRL2Module
	{
		[Inject]
		public var logger:ILogger;
		[Inject]
		public var dispatcher:IEventDispatcher;
		[Inject]
		public var context:IContext;
		[Inject]
		public var mediatorMap:IMediatorMap;
		[Inject]
		public var scene3d:CScene3D;
		
		public function DecorationModule()
		{
		}
		
		private function validateView(view:Object):Boolean
		{
			if(view is CScene3D || view is BaseFurnitureViewSet ){
				return true;
			}else
				return false;
		}
		
		protected function onAddView(evt:Event3D):void
		{
			addView(evt.target);
			logger.info("DecorationModule->onAddView(evt:CEvent)");
		}
		
		protected function onRemoveView(evt:Event3D):void
		{
			removeView(evt.target);
			logger.info("DecorationModule->onRemoveView(evt:CEvent)");
		}
		
		[PostConstruct]
		public function init() : void
		{
			scene3d.addEventListener(Event3D.ADDED,onAddView);
			scene3d.addEventListener(Event3D.REMOVED,onRemoveView);
			
			context.configure(DecorationModuleConfig);
			
			addView(scene3d.view);
			logger.info("DecorationModule->init()");
		}
		
		public function addView(entity:Object):void
		{
			if(validateView(entity))
				mediatorMap.mediate(entity);
			//			else
			//				throw new Error("Not sure what to do with this view type..");
		}
		public function removeView(entity:Object):void
		{
			mediatorMap.unmediate(entity);
		}
	}
}