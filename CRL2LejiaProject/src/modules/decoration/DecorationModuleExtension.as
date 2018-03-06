package modules.decoration
{
	import main.a3d.support.CScene3D;
	
	import rl2.extension.IDecorationModule;
	
	import robotlegs.bender.extensions.matching.instanceOfType;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;
	
	/**
	 * 装修模块扩展
	 * @author cloud
	 */
	public class DecorationModuleExtension implements IExtension
	{
		private var _context:IContext;
		
		public function DecorationModuleExtension()
		{
			
		}
		
		private function handleCScene3D(scene3d:CScene3D):void
		{
			_context.injector.map(CScene3D).toValue(scene3d);
			_context.injector.getInstance(IDecorationModule);
		}
		public function extend(context:IContext):void
		{
			_context = context;
			context.addConfigHandler(instanceOfType(CScene3D), handleCScene3D);
			context.injector.map(IDecorationModule).toSingleton(DecorationModule);
		}
	}
}