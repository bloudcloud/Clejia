package kitchenModule.view
{
	import flash.geom.Vector3D;
	
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.utils.Object3DUtils;
	
	import cloud.core.utils.Vector3DUtil;
	
	/**
	 *  
	 * @author cloud
	 */
	public class CBox extends Box
	{
		protected var _length:Number;
		protected var _width:Number;
		protected var _height:Number;
		protected var _uniqueID:String;
		protected var _type:uint;
		protected var _position:Vector3D;
		protected var _direction:Vector3D;
		
		public function CBox(width:Number=100, length:Number=100, height:Number=100, widthSegments:uint=1, lengthSegments:uint=1, heightSegments:uint=1, reverse:Boolean=false, material:Material=null)
		{
			super(width, length, height, widthSegments, lengthSegments, heightSegments, reverse, material);
			_position=new Vector3D();
			_direction=new Vector3D();
		}
		
		public function get type():uint
		{
			return _type;
		}
		
		public function set type(value:uint):void
		{
			_type=value;
		}
		
		public function get direction():Vector3D
		{
			return _direction;
		}
		
		public function set direction(value:Vector3D):void
		{
			_direction=value;
		}
		
		public function get position():Vector3D
		{
			return _position;
		}	
		
		public function set position(value:Vector3D):void
		{
			if(value!=null)
				_position.copyFrom(value);
			else
				_position.copyFrom(Vector3DUtil.ZERO);
			this.x=_position.x;
			this.y=_position.y;
			this.z=_position.z;
		}
		
		public function get length():Number
		{
			if(boundBox != null)
			{
				return Math.abs(boundBox.maxX - boundBox.minX) * scaleX;
			}
			return _length;
		}
		
		public function set length(value:Number):void
		{
			_length = value;
			if(boundBox == null)
			{
				boundBox = Object3DUtils.calculateHierarchyBoundBox(this);
			}
			scaleX = value / Math.abs(boundBox.maxX - boundBox.minX);
		}
		
		public function get width():Number
		{
			if(boundBox != null)
			{
				return Math.abs(boundBox.maxY - boundBox.minY) * scaleY;
			}
			return _width;
		}
		
		public function set width(value:Number):void
		{
			_width = value;
			if(boundBox == null)
			{
				boundBox = Object3DUtils.calculateHierarchyBoundBox(this);
			}
			scaleY = value / Math.abs(boundBox.maxY - boundBox.minY);
		}
		
		public function get height():Number
		{
			if(boundBox != null)
			{
				return Math.abs(boundBox.maxZ - boundBox.minZ) * scaleZ;
			}
			return _height;
		}
		
		public function set height(value:Number):void
		{
			_height = value;
			if(boundBox == null)
			{
				boundBox = Object3DUtils.calculateHierarchyBoundBox(this);
			}
			scaleZ = value / Math.abs(boundBox.maxZ - boundBox.minZ);
		}
		
		public function get uniqueID():String
		{
			return _uniqueID;
		}
		
		public function set uniqueID(value:String):void
		{
			_uniqueID=value;
		}

	}
}