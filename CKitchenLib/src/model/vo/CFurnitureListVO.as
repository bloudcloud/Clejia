package model.vo
{
	import flash.geom.Vector3D;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DListData;
	
	/**
	 *  家具链表数据类
	 * @author cloud
	 */
	public class CFurnitureListVO implements ICObject3DListData
	{
		protected var _uniqueID:String;
		protected var _type:uint;
		protected var _direction:int;
		protected var _length:Number=0;
		protected var _width:Number=0;
		protected var _height:Number=0;
		
		protected var _headPos:Vector3D;
		protected var _endPos:Vector3D;
		
		public function CFurnitureListVO()
		{
			_headPos=new Vector3D();
			_endPos=new Vector3D();
		}
		
		public function get endPos():Vector3D
		{
			return _endPos;
		}
		
		public function set endPos(value:Vector3D):void
		{
			_endPos=value;
		}
		
		public function get headPos():Vector3D
		{
			return _headPos;
		}
		
		public function set headPos(value:Vector3D):void
		{
			_headPos=value;
		}
		
		public function get direction():int
		{
			return _direction;
		}
		
		public function set direction(value:int):void
		{
			_direction = value;
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
		
		public function get uniqueID():String
		{
			return _uniqueID;
		}
		
		public function set uniqueID(value:String):void
		{
			_uniqueID=value;
		}
		
		public function get type():uint
		{
			return _type;
		}
		
		public function set type(value:uint):void
		{
			_type=value;
		}
		
		public function update(value:*):void
		{
			uniqueID=value.uniqueID;
			type=value.type;
			direction=value.direction;
			length=value.length;
			width=value.width;
			height=value.height;
			headPos=value.headPos;
			endPos=value.endPos;
		}
		
		public function compare(source:ICData):Number
		{
			return 0;
		}
		
		public function toString():String
		{
			return "uniqueID:"+_uniqueID+" "+"type"+_type+" "+"direction:"+_direction+" " +
				"length:"+_length+" "+"width:"+_width+" "+"height:"+_height+" "+
				"headPos:"+_headPos+" "+"endPos:"+_endPos+"\n";
		}
		
		public function clear():void
		{
			_headPos=null;
			_endPos=null;
		}
	}
}