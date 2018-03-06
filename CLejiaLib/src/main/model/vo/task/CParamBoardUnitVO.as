
package main.model.vo.task
{
	import flash.utils.ByteArray;
	
	import cloud.core.datas.base.CVector;
	
	import main.dict.CParamDict;
	
	import ns.singleton;
	
	import wallDecorationModule.interfaces.ICQuotes;
	
	use namespace singleton;
	/**
	 * 参数化单元板数据类
	 * @author cloud
	 */
	public class CParamBoardUnitVO extends CBaseTaskObject3DVO implements ICQuotes
	{
		private var _invalidSize:Boolean;

		protected var _qType:uint;
		protected var _qName:String;
		protected var _qLength:Number;
		protected var _qWidth:Number;
		protected var _qHeight:Number;
		protected var _price:Number;
		protected var _previewBuffer:ByteArray;
		protected var _size:CVector;

		/**
		 * 所属组ID 
		 */		
		public var groupID:uint;
		/**
		 * 裁切长度 
		 */		
		public var cutLength:Number;
		/**
		 * 纹理旋转角度 
		 */		
		public var texRotation:Number=0;
		public var roomID:String;
		public var wallID:String;
		
		override public function set length(value:Number):void
		{
			_invalidSize=_length!=value;
			super.length=value;
		}
		override public function set width(value:Number):void
		{
			_invalidSize=_width!=value;
			super.width=value;
		}
		override public function set height(value:Number):void
		{
			_invalidSize=_height!=value;
			super.height=value;
		}
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
		public function get realHeight():Number
		{
			return height*scaleHeight;
		}
		
		public function CParamBoardUnitVO(clsType:String)
		{
			super(clsType);
			cutLength=0;
			_size=CVector.CreateOneInstance();
		}
		
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			texRotation=Number(xml.@texRotation);
			if(width==0)
			{
				width=CParamDict.DEFAULT_CLAPBOARD_UINT_BOARD_THICKNESS;
			}
			x=y=z=0;
		}

		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CParamBoardUnitVO=super.clone() as CParamBoardUnitVO;
			clone.cutLength=cutLength;
			clone.qName=qName;
			clone.qLength=qLength;
			clone.qWidth=qWidth;
			clone.qHeight=qHeight;
			clone.qType=qType;
			clone.price=price;
			clone.previewBuffer=previewBuffer;
			clone.texRotation=texRotation;
			clone.size=size;
			clone.roomID=roomID;
			clone.wallID=wallID;
			return clone;
		}
		override public function clear():void
		{
			super.clear();
			_previewBuffer=null;
		}
		
		override public function toString():String
		{
			return "uniqueID:"+uniqueID+" "+"type:"+type+" "+"parentID:"+parentID+" "+"code:"+code+" "+"material:"+material+" "+"offGround:"+offGround+" "+"offLeft:"+offLeft+" "+"url:"+url+"\n";
		}
	}
}