package main.model.vo.task
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CDebugUtil;
	
	import wallDecorationModule.interfaces.ICQuotes;
	
	/**
	 * 参数化部件数据类
	 * @author cloud
	 */
	public class CParamPartVO extends CBaseTaskObject3DVO implements ICQuotes
	{
		protected var _qType:uint;
		protected var _qName:String;
		protected var _qLength:Number;
		protected var _qWidth:Number;
		protected var _qHeight:Number;
		protected var _price:Number;
		protected var _previewBuffer:ByteArray;
		protected var _size:CVector;
		
		public var texRotation:Number=0;
		public var roomID:String;
		public var wallID:String;
		/**
		 * 起始点方向角的偏移缩放值（值为正表示内向缩进，值为负表示外向延伸）
		 */		
		public var startOffsetScale:Number;
		/**
		 * 终止点方向角的偏移缩放值 （值为正表示内向缩进，值为负表示外向延伸）
		 */		
		public var endOffsetScale:Number;
		
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
		 * 裁切长度 
		 */		
		public var cutLength:Number;
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
		
		public function CParamPartVO(clsType:String="CParamPartVO")
		{
			super(clsType);
			startOffsetScale=0;
			endOffsetScale=0;
			cutLength=0;
			_size=CVector.CreateOneInstance();
		}
		protected function doCreateLoftingPaths(loftingAxis:CVector,towardAxis:CVector,paths:Array):void
		{
			var rightAxis:CVector=CVector.Z_AXIS;
			CVector.Copy(loftingAxis,direction);
			CVector.SetTo(towardAxis,loftingAxis.y*rightAxis.z-loftingAxis.z*rightAxis.y
				,loftingAxis.z*rightAxis.x-loftingAxis.x*rightAxis.z
				,loftingAxis.x*rightAxis.y-loftingAxis.y*rightAxis.x);
			paths.push(new Vector3D(-realLength*.5,0,-realHeight*.5),new Vector3D(realLength*.5,0,-realHeight*.5),new Vector3D(realLength*.5,0,realHeight*.5),new Vector3D(-realLength*.5,0,realHeight*.5));
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			texRotation=Number(xml.@texRotation);
		}
		/**
		 * 创建放样路径 
		 * @return Vector.<Vector3D>
		 * 
		 */		
		public function createLoftingPaths(loftingAxis:CVector,towardAxis:CVector):Vector.<Vector3D>
		{
			roundPoints.clear();
			var paths:Array=[];
			doCreateLoftingPaths(loftingAxis,towardAxis,paths);
			roundPoints.add(paths);
			return Vector.<Vector3D>(paths);
		}
		override public function updateVO(source:CBaseObject3DVO):void
		{
			super.updateVO(source);
			if(source is CParamPartVO)
			{
				this.roomID=(source as CParamPartVO).roomID;
				this.wallID=(source as CParamPartVO).wallID;
			}
		}
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CParamPartVO=super.clone() as CParamPartVO;
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
			clone.startOffsetScale=startOffsetScale;
			clone.endOffsetScale=endOffsetScale;
			return clone;
		}
		override public function clear():void
		{
			super.clear();
			startOffsetScale=0;
			endOffsetScale=0;
			_size.back();
			_size=null;
			_previewBuffer=null;
		}
		override public function toString():String
		{
			return "uniqueID:"+uniqueID+" "+"type:"+type+" "+"parentID:"+parentID+" "+"code:"+code+" "+"material:"+material+" "+"offGround:"+offGround+" "+"offLeft:"+offLeft+" "+"url:"+url+"\n";
		}
		override public function compare(source:ICData):Number
		{
			var distance:Number;
			var vo:ICObject3D=source as ICObject3D;
			if(vo)
			{
				var vec:CVector=CVector.Substract(this.position,vo.position);
				distance=CVector.DotValue(vec,vo.direction)>0 ? vec.length : vec.length*-1;
			}
			else
				CDebugUtil.Instance.throwError("CParam3DTaskVO","compare"," vo",String(getQualifiedClassName(vo)+" 参数不是家具数据类型！"));
			return distance;
		}
		
	}
}