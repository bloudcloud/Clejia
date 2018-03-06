package main.model.vo.configs
{
	import cloud.core.interfaces.ICSerialization;
	
	public class BaseProperties implements ICSerialization
	{
		protected var _className:String;
		
		public function get className():String
		{
			return _className;
		}
		
		public function BaseProperties()
		{
		}
		
		public function deserialize(source:*):void
		{
		}
		
		public function serialize(formate:String):*
		{
			return null;
		}
	}
}