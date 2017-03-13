package model.vo
{
	import flash.geom.Vector3D;
	
	import interfaces.ICFurnitureVO;

	/**
	 *	3D家具基础数据类
	 * @author cloud
	 */
	public class BaseFurnitureVO implements ICFurnitureVO
	{
		protected var _uniqueID:String;
		
		public function get uniqueID():String
		{
			return _uniqueID;
		}
		
		public function set uniqueID(value:String):void
		{
			_uniqueID=value;
		}
		
		protected var _type:uint;

		public function get type():uint
		{
			return _type;
		}

		public function set type(value:uint):void
		{
			_type = value;
		}
		
		protected var _direction:int;
		
		public function get direction():int
		{
			return _direction;
		}
		
		public function set direction(value:int):void
		{
			_direction=value;
		}
		
		protected var _position:Vector3D;
		
		public function get position():Vector3D
		{
			return _position;
		}
		
		public function set position(value:Vector3D):void
		{
			_position = value;
		}
		
		protected var _length:Number;
		
		public function get length():Number
		{
			return _length;
		}
		
		public function set length(value:Number):void
		{
			_length=value;
		}
		
		protected var _width:Number;
		
		public function get width():Number
		{
			return _width; 
		}
		
		public function set width(value:Number):void
		{
			_width=value;
		}
		
		protected var _height:Number;
		
		public function get height():Number
		{
			return _height;
		}
		
		public function set height(value:Number):void
		{
			_height=value;
		}

		public var index:int;
		
		public function BaseFurnitureVO()
		{
			position=new Vector3D();
		}
		
		public function toString():String
		{
			return "uniqueID:"+_uniqueID+" "+"type"+_type+" "+"index:"+index+" "+"position:"+_position+" "+"direction:"+_direction+" "
				+"length:"+_length+" "+"width:"+_width+" "+"height:"+_height+"\n";
		}
		
		public function updateVo(vo:Object):void
		{
			uniqueID=vo.uniqueID;
			type=vo.type;
			index=vo.index;
			position=vo.position;
			direction=vo.direction;
			length=vo.length;
			width=vo.width;
			height=vo.height;
		}
		
		public function clear():void
		{
			
		}
	}
}