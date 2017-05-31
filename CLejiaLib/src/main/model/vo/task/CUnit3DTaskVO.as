package main.model.vo.task
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import mx.utils.UIDUtil;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICPoolObject;
	import cloud.core.interfaces.ICSerialization;
	import cloud.core.model.paramVos.CBaseUnit3D;
	import cloud.core.singleton.CPoolsManager;
	
	import ns.singleton;
	
	import wallDecorationModule.dict.CDecorationParamDict;
	import wallDecorationModule.interfaces.ICQuotes;
	
	use namespace singleton;
	/**
	 * 单元件任务数据类
	 * @author cloud
	 */
	public class CUnit3DTaskVO extends CBaseUnit3D implements ITaskVO,ICSerialization,ICPoolObject,ICQuotes
	{
		private var _refCount:uint;
		private var _invalidSize:Boolean;
		
		protected var _uniqueID:String;
		protected var _parentID:String;
		protected var _type:uint;
		protected var _url:String;
		protected var _code:String;
		protected var _material:String;
		protected var _name:String;
		protected var _qLength:Number;
		protected var _qWidth:Number;
		protected var _qHeight:Number;
		protected var _price:Number;
		protected var _previewBuffer:ByteArray;

		/**
		 * 所属组ID 
		 */		
		public var groupID:uint;
		/**
		 * 离地高 
		 */		
		public var offGround:Number;
		/**
		 * 裁切长度 
		 */		
		public var cutLength:Number;
		/**
		 * 缩放比例 
		 */		
		public var lengthScale:Number=1;
		public var heightScale:Number=1;
		
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
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			_name=value;
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
			return length*lengthScale;
		}
		public function get realHeight():Number
		{
			return height*heightScale;
		}
		public function get refCount():uint
		{
			return _refCount;
		}
		public function set refCount(value:uint):void
		{
			_refCount=value;
		}	
		public function get url():String
		{
			return _url;
		}
		
		public function set url(value:String):void
		{
			_url=value;
		}
		
		public function get code():String
		{
			return _code;
		}
		
		public function set code(value:String):void
		{
			_code=value;
		}
		
		public function get material():String
		{
			return _material;
		}

		public function set material(value:String):void
		{
			_material=value;
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
		
		public function CUnit3DTaskVO()
		{
			super();
			cutLength=0;
		}
		
		protected function doDeserializeXML(xml:XML):void
		{
			code=String(xml.@code);
			material=String(xml.@material);
			url=String(xml.@url);
			uniqueID=String(xml.@uniqueID);
			parentID=String(xml.@parentID);
			type=CDecorationParamDict.instance.getTypeByString(String(xml.@type));
			length=Number(xml.@length);
			width=Number(xml.@width);
			height=Number(xml.@height);
			offGround=Number(xml.@offGround);
			leftSpacing=Number(xml.@leftSpacing);
			rotation=Number(xml.@rotation);
			if(width==0)
			{
				width=CDecorationParamDict.DEFAULT_UINT_BOARD_THICKNESS;
			}
			x=y=z=0;
		}

		public function clone():CUnit3DTaskVO
		{
//			var clone:CUnit3DTaskVO=CPoolsManager.instance.getPool(CUnit3DTaskVO).pop() as CUnit3DTaskVO;
			var clone:CUnit3DTaskVO=new CUnit3DTaskVO();
			clone.code=_code;
			clone.material=_material;
			clone.url=_url;
			clone.uniqueID=UIDUtil.createUID();
			clone.parentID=_parentID;
			clone.type=_type;
			clone.length=_length;
			clone.width=_width;
			clone.height=_height;
			clone.x=x;
			clone.y=y;
			clone.z=z;
			clone.offGround=offGround;
			clone.rotation=rotation;
			clone.direction=direction;
			clone.isLife=isLife;
			clone.leftSpacing=leftSpacing;
			clone.rightSpacing=rightSpacing;
			clone.topSpacing=topSpacing;
			clone.bottomSpacing=bottomSpacing;
			clone.cutLength=cutLength;
			clone.lengthScale=lengthScale;
			clone.heightScale=heightScale;
			clone.name=name;
			clone.qLength=qLength;
			clone.qWidth=qWidth;
			clone.qHeight=qHeight;
			clone.price=price;
			clone.previewBuffer=previewBuffer;
			return clone;
		}
		override public function clear():void
		{
			super.clear();
			_previewBuffer=null;
		}
		public function deserialize(source:*):void
		{
			if(source is XML)
			{
				doDeserializeXML(source as XML);
			}
			if(_uniqueID=="" || _uniqueID==null)
				this.uniqueID=UIDUtil.createUID();
		}
		public function serialize():*
		{
			var xml:XML;
			return xml;
		}
		public function compare(source:ICData):Number
		{
			return 0;
		}
		public function toString():String
		{
			return "uniqueID:"+_uniqueID+" "+"type:"+_type+" "+"parentID:"+_parentID+" "+"code:"+_code+" "+"material:"+_material+" "+"offGround:"+offGround+" "+"leftSpacing:"+leftSpacing+" "+"url:"+_url+"\n";
		}
		public function initObject(initParam:Object=null):void
		{
		}
		public function dispose():void
		{
			CPoolsManager.instance.getPool(CUnit3DTaskVO).push(this);
		}
	}
}