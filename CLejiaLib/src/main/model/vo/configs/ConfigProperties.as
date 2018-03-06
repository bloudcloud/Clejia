package main.model.vo.configs
{
	import cloud.core.dict.CConst;
	

	public class ConfigProperties extends BaseProperties
	{
		public var code:String;
		public var name:String;
		public var price:Number;
		
		protected var _formate:String;
		protected var _length:Number;
		protected var _width:Number;
		protected var _height:Number;
		
		public function get formate():String
		{
			return _formate;
		}
		public function set formate(value:String):void
		{
			if(value.length>0 && _formate!=value)
			{
				updateFormate(value);
			}
			_formate=value;
		}
		public function get length():Number
		{
			return _length;
		}
		public function set length(value:Number):void
		{
			_length=value;
		}
		public function get width():Number
		{
			return _width;
		}
		public function set width(value:Number):void
		{
			_width=value;
		}
		public function get height():Number
		{
			return _height;
		}
		public function set height(value:Number):void
		{
			_height=value;
		}
		
		public function ConfigProperties()
		{
		}
		private function updateFormate(newFormate:String):void
		{
			var arr:Array=newFormate.split("*");
			length=arr[0];
			width=arr[2];
			height=arr[1];
		}
		private function doDeserializeXML(xml:XML):void
		{
			code=xml.@code;
			name=xml.@name;
			formate=xml.@formate;
			price=Number(xml.@price);
		}
		override public function deserialize(source:*):void
		{
			if(source is XML)
			{
				doDeserializeXML(source as XML);
			}
		}
		override public function serialize(formate:String):*
		{
			if(formate==CConst.SERIALIZATION_FORMATE_XML)
			{
				return <Properties code={code} name={name} format={formate} price={price}></Properties>
			}
			return null;
		}
	}
}