package model
{
	import cloud.core.utils.CDebug;
	
	import ns.cloudLib;
	
	/**
	 *  
	 * @author cloud
	 */
	public class KitchenErrorModel
	{
		private static var _instance:KitchenErrorModel;
		
		cloudLib static function get instance():KitchenErrorModel
		{
			return _instance ||= new KitchenErrorModel(new SingleEnforce());
		}
		
		public function KitchenErrorModel(enforcer:SingleEnforce)
		{
		}
		/**
		 * 抛出空对象错误 
		 * @param className
		 * @param functionName
		 * @param varName
		 * 
		 */		
		public function throwErrorForNull(className:String,functionName:String,varName:String):void
		{
			CDebug.instance.throwError(className,functionName,varName,"为空！");
			
		}
		/**
		 * 根据信息 抛出错误 
		 * @param className
		 * @param functionName
		 * @param varName
		 * @param message
		 * 
		 */		
		public function throwErrorByMessage(className:String,functionName:String,varName:String,message:String):void
		{
			CDebug.instance.throwError(className,functionName,varName,message);
		}
	}
}
class SingleEnforce{}