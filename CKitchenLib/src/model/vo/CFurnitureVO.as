package model.vo
{
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	
	import model.KitchenErrorModel;
	import model.KitchenGlobalModel;
	
	import ns.cloudLib;
	
	use namespace cloudLib;
	/**
	 *	3D家具基础数据类
	 * @author cloud
	 */
	public class CFurnitureVO implements ICObject3DData
	{
		protected var _uniqueID:String;
		protected var _type:uint;
		protected var _direction:int;
		protected var _position:Vector3D;
		protected var _length:Number;
		protected var _width:Number;
		protected var _height:Number;
		
		public var index:int;
		public var mark:String;
		public var isSorpted:Boolean;
		
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
			_type = value;
		}

		public function get direction():int
		{
			return _direction;
		}
		
		public function set direction(value:int):void
		{
			_direction=value;
		}

		public function get position():Vector3D
		{
			return _position;
		}
		
		public function set position(value:Vector3D):void
		{
			_position = value;
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
		
		public function CFurnitureVO()
		{
			position=new Vector3D();
		}

		public function clone():ICObject3DData
		{
			var vo:CFurnitureVO=new CFurnitureVO();
			vo.uniqueID=this.uniqueID;
			vo.type=this.type;
			vo.mark=this.mark;
			vo.position=this.position.clone();
			vo.direction=this.direction;
			vo.length=this.length;
			vo.width=this.width;
			vo.height=this.height;
			return vo;
		}
		
		public function toString():String
		{
			return "uniqueID:"+_uniqueID+" "+"type"+_type+" "+"index:"+mark+" "+"position:"+_position+" "+"direction:"+_direction+" "
				+"length:"+_length+" "+"width:"+_width+" "+"height:"+_height+"\n";
		}
		
		public function update(vo:*):void
		{
			uniqueID=vo.uniqueID;
			type=vo.type;
			position=vo.position;
			direction=vo.direction;
			length=vo.length;
			width=vo.width;
			height=vo.height;
			index=vo.index;
			mark=vo.mark;
			isSorpted=vo.isSorpted;
		}

		public function clear():void
		{
			_position=null;
		}
		
		public function compare(source:ICData):Number
		{
			var value:Number;
			var vo:CFurnitureVO=source as CFurnitureVO;
			if(vo)
			{
				value=KitchenGlobalModel.instance.compareFurnitureVo(this,vo);
			}
			else
				KitchenErrorModel.instance.throwErrorByMessage("FurnitureVO","compare"," vo",String(getQualifiedClassName(vo)+" 参数不是家具数据类型！"));
			return value;
		}
	}
}