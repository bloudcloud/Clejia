package wallDecorationModule.interfaces
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	/**
	 * 报价数据接口 
	 * @author cloud
	 * 
	 */
	public interface ICQuotes
	{
		function get name():String;
		function set name(value:String):void;
		function get qLength():Number;
		function set qLength(value:Number):void;
		function get qWidth():Number;
		function set qWidth(value:Number):void;
		function get qHeight():Number;
		function set qHeight(value:Number):void;
		function get price():Number;
		function set price(value:Number):void;
		function get previewBuffer():ByteArray;
		function set previewBuffer(value:ByteArray):void;
	}
}