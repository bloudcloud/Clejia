package main.model.vo
{
	import cloud.core.interfaces.ICData;
	
	public class CRoom3DVO implements ICData
	{
		private var _uniqueID:String;
		private var _parentID:String;
		private var _type:uint;
		private var _refCount:int;
		
		public var roomHeight:uint=2800;
		
		public function CRoom3DVO()
		{
		}
		
		public function get uniqueID():String
		{
			return _uniqueID;
		}
		
		public function set uniqueID(value:String):void
		{
			_uniqueID=value;
		}
		
		public function get parentID():String
		{
			return _parentID;
		}
		
		public function set parentID(value:String):void
		{
			_parentID=value;
		}
		
		public function get type():uint
		{
			return _type;
		}
		
		public function set type(value:uint):void
		{
			_type=value;
		}
		
		public function compare(source:ICData):Number
		{
			return 0;
		}
		
		public function toString():String
		{
			return "CRoom3D: "+"uniqueID:"+_uniqueID+" "+"type:"+_type+" "+"parentID:"+_parentID+"\n";;
		}
		
		public function get refCount():uint
		{
			return _refCount;
		}
		
		public function set refCount(value:uint):void
		{
			_refCount=value;
		}
		
		public function clear():void
		{
		}
	}
}