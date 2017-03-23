package rl2.extension
{
	import a3d.support.Scene3D;
	
	import robotlegs.bender.extensions.matching.instanceOfType;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;

	/**
	 *  
	 * @author cloud
	 */
	public class KithenModuleExtension implements IExtension
	{
		private var _context:IContext;
		
		public function KithenModuleExtension()
		{
			super();
		}
		
		private function handleCScene3D(scene3D:Scene3D):void
		{
			_context.injector.map(Scene3D).toValue(scene3D);
			_context.injector.getInstance(IModule);
			
		}
		
		public function extend(context:IContext):void
		{
			_context = context;
			_context.addConfigHandler(instanceOfType(Scene3D), handleCScene3D);
			_context.injector.map(IModule).toSingleton(KithenModule);
		}
	}
}