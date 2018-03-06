package main.model.vo.task
{
	import flash.utils.ByteArray;
	
	import cloud.core.datas.base.CVector;
	
	import wallDecorationModule.interfaces.ICQuotes;
	
	/**
	 *	3D家具基础数据类
	 * @author cloud
	 */
	public class CObject3DVO extends CBaseTaskObject3DVO implements ICQuotes
	{
		protected var _qType:uint;
		protected var _qName:String;
		protected var _qLength:Number;
		protected var _qWidth:Number;
		protected var _qHeight:Number;
		protected var _price:Number;
		protected var _previewBuffer:ByteArray;
		protected var _size:CVector;
		
		public function get size():CVector
		{
			return _size;
		}
		public function set size(value:CVector):void
		{
			if(value!=null)
				CVector.Copy(_size,value);
		}
		public function get qType():uint
		{
			return _qType;
		}
		public function set qType(value:uint):void
		{
			_qType=value;
		}
		public function get qName():String
		{
			return _qName;
		}
		public function set qName(value:String):void
		{
			_qName=value;
		}
		public function get qLength():Number
		{
			return _qLength;
		}
		public function set qLength(value:Number):void
		{
			_qLength=value;
		}
		public function get qWidth():Number
		{
			return _qWidth;
		}
		public function set qWidth(value:Number):void
		{
			_qWidth=value;
		}
		public function get qHeight():Number
		{
			return _qHeight;
		}
		public function set qHeight(value:Number):void
		{
			_qHeight=value;
		}
		public function get price():Number
		{
			return _price;
		}
		public function set price(value:Number):void
		{
			_price=value;
		}
		public function get previewBuffer():ByteArray
		{
			return _previewBuffer;
		}
		public function set previewBuffer(value:ByteArray):void
		{
			_previewBuffer=value;
		}
		
		/**
		 * 获取真实长度 
		 * @return Number
		 * 
		 */		
		public function get realLength():Number
		{
			return length*scaleLength;
		}
		/**
		 * 获取真实宽度 
		 * @return Number
		 * 
		 */		
		public function get realWidth():Number
		{
			return width*scaleWidth;
		}
		/**
		 * 获取真实高度 
		 * @return Number
		 * 
		 */		
		public function get realHeight():Number
		{
			return height*scaleHeight;
		}
		
		public function CObject3DVO(clsName:String="CObject3DVO")
		{
			super(clsName);
			_size=CVector.CreateOneInstance();
			_isXYZ=true;
		}
		
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CObject3DVO=super.clone() as CObject3DVO;
			clone.qName=qName;
			clone.qLength=qLength;
			clone.qWidth=qWidth;
			clone.qHeight=qHeight;
			clone.qType=qType;
			clone.price=price;
			clone.previewBuffer=previewBuffer;
			clone.size=size;
			return clone;
		}
		override public function clear():void
		{
			super.clear();
			_size.back();
			_size=null;
			_previewBuffer=null;
		}
	}
}