package modules.kitchen
{
	import main.a3d.support.CScene3D;
	
	import robotlegs.bender.extensions.matching.instanceOfType;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;
	import rl2.extension.IRL2Module;

	/**
	 *  
	 * @author cloud
	 */
	public class KitchenModuleExtension implements IExtension
	{
		private var _context:IContext;
		
		public function KitchenModuleExtension()
		{
			super();
		}
		
		private function handleCScene3D(scene3D:CScene3D):void
		{
			_context.injector.map(CScene3D).toValue(scene3D);
			_context.injector.getInstance(IRL2Module);
			
		}
		
		public function extend(context:IContext):void
		{
			_context = context;
			_context.addConfigHandler(instanceOfType(CScene3D), handleCScene3D);
//			_context.injector.map(KithenModule).asSingleton();
			_context.injector.map(IRL2Module).toSingleton(KitchenModule);
		}
	}
}