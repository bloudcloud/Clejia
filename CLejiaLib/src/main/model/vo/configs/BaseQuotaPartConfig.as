package main.model.vo.configs
{
	import cloud.core.dict.CConst;
	import cloud.core.interfaces.ICSerialization;
	
	import main.dict.CParamDict;

	/**
	 * 基础报价部件配置数据类 
	 * @author cloud
	 * 
	 */	
	public class BaseQuotaPartConfig implements ICSerialization
	{
		protected var _className:String;
		
		public var code:String;
		public var name:String;
		public var type:String;
		public var properties:Vector.<ConfigProperties>;
		
		public function get className():String
		{
			return _className;
		}
		public function BaseQuotaPartConfig()
		{
		}

		public function deserialize(source:*):void
		{
			if(source is XML)
			{
				_className=source.name();
				type=source.@type;
				code=source.@code;
				name=source.@name;
				var children:XMLList=source.children();
				var len:int=children.length();
				if(len>0)
				{
					var property:ConfigProperties;
					var propertyCls:Class;
					properties=new Vector.<ConfigProperties>(len);
					for(var i:int=0; i<len; i++)
					{
						propertyCls=CParamDict.Instance.getParamDataTypeCls(String(XML("Config"+children[i].name())));
						property=new propertyCls();
						property.deserialize(children[i]);
						properties[i]=property;
					}
				}
			}
		}
		
		public function serialize(formate:String):*
		{
			if(formate==CConst.SERIALIZATION_FORMATE_XML)
			{
				var xml:XML = <{_className}></{_className}>;
				var propertyXml:XML;
				for(var i:int=0; i<properties.length; i++)
				{
					propertyXml=XML(properties[i].serialize(formate));
					xml.appendChild(propertyXml);
				}
				return xml;
			}
			return null;
		}
	}
}