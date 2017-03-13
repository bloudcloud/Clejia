package interfaces
{
	import flash.geom.Vector3D;

	/**
	 *  家具属性接口
	 * @author cloud
	 */
	public interface IFurnitureProperty
	{	
		/**
		 * 获取方向 
		 * @return int
		 * 
		 */		
		function get direction():int;
		/**
		 * 设置方向 
		 * @param value
		 * 
		 */		
		function set direction(value:int):void;
		/**
		 * 获取数据类型属性 
		 * @return uint
		 * 
		 */		
		function get type():uint;
		/**
		 * 设置数据类型属性 
		 * @param value
		 * 
		 */		
		function set type(value:uint):void;
		/**
		 * 获取位置 
		 * @return Vector3D
		 * 
		 */		
		function get position():Vector3D;
		/**
		 * 设置位置 
		 * @param value
		 * 
		 */		
		function set position(value:Vector3D):void;
		/**
		 * 获取长度 
		 * @return Number
		 * 
		 */		
		function get length():Number;
		/**
		 * 设置长度 
		 * @param value
		 * 
		 */		
		function set length(value:Number):void;
		/**
		 * 获取宽度 
		 * @return Number
		 * 
		 */		
		function get width():Number;
		/**
		 * 设置宽度 
		 * @param value
		 * 
		 */		
		function set width(value:Number):void;
		/**
		 *  获取高度
		 * @return Number
		 * 
		 */
		function get height():Number;
		/**
		 * 设置高度 
		 * @param value
		 * 
		 */		
		function set height(value:Number):void;
		/**
		 *  获取唯一ID
		 * @return String
		 * 
		 */		
		function get uniqueID():String;
		/**
		 * 设置唯一ID
		 * @param value 
		 * 
		 */		
		function set uniqueID(value:String):void;
	}
}