package main.model.vo
{
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	
	import cloud.core.dataStruct.CTransform3D;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.singleton.CVector3DUtil;
	import cloud.core.utils.MathUtil;
	
	import kitchenModule.model.KitchenErrorModel;
	
	import ns.cloudLib;
	
	use namespace cloudLib;
	/**
	 *	3D家具基础数据类
	 * @author cloud
	 */
	public class CObject3DVO implements ICObject3D,ICData
	{
		private var _refCount:uint;
		
		protected var _uniqueID:String;
		protected var _parentID:String;
		protected var _type:uint;
		protected var _length:Number;
		protected var _width:Number;
		protected var _height:Number;
		protected var _direction:Vector3D;
		protected var _isLife:Boolean;
		
		private var _invalidPosition:Boolean;
		private var _invalidTransform:Boolean;
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		private var _rotation:int;
		private var _position:Vector3D;
		private var _transform:CTransform3D;
		private var _inverseTransform:CTransform3D;

		public function get refCount():uint
		{
			return _refCount;
		}
		public function set refCount(value:uint):void
		{
			_refCount=value;
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
			_type = value;
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
		
		public function get isLife():Boolean
		{
			return _isLife;
		}
		
		public function set isLife(value:Boolean):void
		{
			_isLife=value;
		}
		
		public function get direction():Vector3D
		{
			return _direction;
		}
		
		public function set direction(value:Vector3D):void
		{
			if(value!=null)
				_direction.copyFrom(value);
			else
				_direction.copyFrom(CVector3DUtil.ZERO);
		}
		
		public function get x():Number
		{
			return _x;
		}
		public function set x(value:Number):void
		{
			if(_x!=value)
			{
				_invalidPosition=true;
				_invalidTransform=true;
				_x=value;
			}
		}
		public function get y():Number
		{
			return _y;
		}
		public function set y(value:Number):void
		{
			if(_y!=value)
			{
				_invalidPosition=true;
				_invalidTransform=true;
				_y=value;
			}
		}
		public function get z():Number
		{
			return _z;
		}
		public function set z(value:Number):void
		{
			if(_z!=value)
			{
				_invalidPosition=true;
				_invalidTransform=true;
				_z=value;
			}
		}
		
		public function get rotation():int
		{
			return _rotation;
		}
		
		public function set rotation(value:int):void
		{
			if(_rotation!=value)
			{
				_invalidTransform=true;
				_rotation=value;
			}
		}

		public function get position():Vector3D
		{
			if(_invalidPosition)
				updatePosition();
			return _position;
		}
		
		public function get transform():CTransform3D
		{
			if(_invalidTransform)
				updateTransform();
			return _transform;
		}
		
		public function get inverseTransform():CTransform3D
		{
			if(_invalidTransform)
				updateTransform();
			return _inverseTransform;
		}
		
		public function get invalidPosition():Boolean
		{
			return _invalidPosition;
		}
		
		public function CObject3DVO()
		{
			_position=new Vector3D();
			_direction=new Vector3D();
			_transform=new CTransform3D();
			_inverseTransform=new CTransform3D();
			_length=_width=_height=_rotation=_x=_y=_z=0;
			_isLife=true;
		}
		
		protected function updatePosition():void
		{
			_invalidPosition=false;
			_position.setTo(x,y,z);
		}
		
		protected function updateTransform():void
		{
			_invalidTransform=false;
			var cosX:Number = 1;
			var sinX:Number = 0;
			var cosY:Number = 1;
			var sinY:Number = 0;
			var cosZ:Number = Math.cos(MathUtil.instance.toRadians(rotation));
			var sinZ:Number = Math.sin(MathUtil.instance.toRadians(rotation));
			var cosZsinY:Number = cosZ*sinY;
			var sinZsinY:Number = sinZ*sinY;
			var cosYscaleX:Number = cosY;
			var sinXscaleY:Number = sinX;
			var cosXscaleY:Number = cosX;
			var cosXscaleZ:Number = cosX;
			var sinXscaleZ:Number = sinX;
			transform.a = cosZ*cosYscaleX;
			transform.b = cosZsinY*sinXscaleY - sinZ*cosXscaleY;
			transform.c = cosZsinY*cosXscaleZ + sinZ*sinXscaleZ;
			transform.d = _x;
			transform.e = sinZ*cosYscaleX;
			transform.f = sinZsinY*sinXscaleY + cosZ*cosXscaleY;
			transform.g = sinZsinY*cosXscaleZ - cosZ*sinXscaleZ;
			transform.h = _y;
			transform.i = -sinY;
			transform.j = cosY*sinXscaleY;
			transform.k = cosY*cosXscaleZ;
			transform.l = _z;
			// Inverse matrix
			var sinXsinY:Number = sinX*sinY;
			cosYscaleX = cosY;
			cosXscaleY = cosX;
			sinXscaleZ = -sinX;
			cosXscaleZ = cosX;
			inverseTransform.a = cosZ*cosYscaleX;
			inverseTransform.b = sinZ*cosYscaleX;
			inverseTransform.c = -sinY;
			inverseTransform.d = -inverseTransform.a*_x - inverseTransform.b*_y - inverseTransform.c*_z;
			inverseTransform.e = sinXsinY*cosZ - sinZ*cosXscaleY;
			inverseTransform.f = cosZ*cosXscaleY + sinXsinY*sinZ;
			inverseTransform.g = sinX*cosY;
			inverseTransform.h = -inverseTransform.e*_x - inverseTransform.f*_y - inverseTransform.g*_z;
			inverseTransform.i = cosZ*sinY*cosXscaleZ - sinZ*sinXscaleZ;
			inverseTransform.j = cosZ*sinXscaleZ + sinY*sinZ*cosXscaleZ;
			inverseTransform.k = cosY*cosXscaleZ;
			inverseTransform.l = -inverseTransform.i*_x - inverseTransform.j*_y - inverseTransform.k*_z;
		}

		public function clone():CObject3DVO
		{
			var vo:CObject3DVO=new CObject3DVO();
			vo.uniqueID=this.uniqueID;
			vo.type=this.type;
			vo.direction=this.direction;
			vo.length=this.length;
			vo.width=this.width;
			vo.height=this.height;
			vo.parentID=this.parentID;
			vo.isLife=this.isLife;
			
			vo.rotation=this.rotation;
			vo.x=this.x;
			vo.y=this.y;
			vo.z=this.z;
			
			return vo;
		}
		
		public function toString():String
		{
			return "uniqueID:"+_uniqueID+" "+"type:"+_type+" "+"parentID:"+_parentID+" "+"direction:"+_direction+" "
				+"length:"+_length+" "+"width:"+_width+" "+"height:"+_height+" "+"position:"+_position+" "
				+"transform:"+transform+" "+"inverseTransform:"+inverseTransform+"\n";
		}
		
		public function update(vo:*):void
		{
			uniqueID=vo.uniqueID;
			type=vo.type;
			length=vo.length;
			width=vo.width;
			height=vo.height;
			direction=vo.direction;
			parentID=vo.parentID;
			isLife=vo.isLife;
			
			x=vo.x;
			y=vo.y;
			z=vo.z;
			rotation=vo.rotation;
		}

		public function clear():void
		{
			_position=null;
			_direction=null;
			_transform=null;
			_inverseTransform=null;
		}
		
		public function compare(source:ICData):Number
		{
			var distance:Number;
			var vo:ICObject3D=source as ICObject3D;
			if(vo)
			{
				var vec:Vector3D=this.position.subtract(vo.position);
				distance=vec.dotProduct(vo.direction)>0 ? vec.length : vec.length*-1;
			}
			else
				KitchenErrorModel.instance.throwErrorByMessage("CObject3DVO","compare"," vo",String(getQualifiedClassName(vo)+" 参数不是家具数据类型！"));
			return distance;
		}
	}
}