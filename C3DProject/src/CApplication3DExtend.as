package
{
	import core.AppConfig;
	import core.CApplication3D;
	
	import modules.kitchen.KitchenModuleExtension;
	
	import robotlegs.bender.bundles.mvcs.MVCSBundle;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.impl.Context;
	
	/**
	 * 扩展应用
	 * @author cloud
	 * @2017-6-28
	 */
	public class CApplication3DExtend extends CApplication3D
	{
		public function CApplication3DExtend()
		{
			super();
		}
		override protected function initContext():void
		{
			_context = new Context()
				.install(MVCSBundle,KitchenModuleExtension)
				.configure(AppConfig,new ContextView(this),scene);
		}
	}
}