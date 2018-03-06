package main.model.vo.task
{
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CUtil;
	
	import main.dict.CParamDict;
	
	/**
	 * 基础参数化任务数据类
	 * @author cloud
	 */
	public class CBaseTaskObject3DVO extends CBaseObject3DVO implements ITaskVO
	{
		private var _url:String;
		private var _code:String;
		private var _material:String;

		public var num:Number;
		
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
		
		public function CBaseTaskObject3DVO(clsName:String="CBaseTaskObject3DVO")
		{
			super(clsName);
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			code=String(xml.@code);
			material=String(xml.@material);
			url=String(xml.@url);
			num=Number(xml.@num);
			uniqueID=String(xml.@uniqueID);
			parentID=String(xml.@parentID);
			type=CParamDict.Instance.getTypeByString(String(xml.@type));
			parentType=CParamDict.Instance.getTypeByString(String(xml.@parentType));
			length=Number(xml.@length);
			width=Number(xml.@width);
			height=Number(xml.@height);
			_originX=Number(xml.@x);
			_originY=Number(xml.@y);
			_originZ=Number(xml.@z);
			_scaleLength=Number(xml.@scaleLength);
			_scaleWidth=Number(xml.@scaleWidth);
			_scaleHeight=Number(xml.@scaleHeight);
			rotationLength=Number(xml.@rotationLength);
			rotationWidth=Number(xml.@rotationWidth);
			rotationHeight=Number(xml.@rotationHeight);
			offLeft=Number(xml.@offLeft);
			offBack=Number(xml.@offBack);
			offGround=Number(xml.@offGround);
			if(uniqueID=="" || uniqueID==null)
				uniqueID=CUtil.Instance.createUID();
			if(_scaleLength==0)
				_scaleLength=1;
			if(_scaleWidth==0)
				_scaleWidth=1;
			if(_scaleHeight==0)
				_scaleHeight=1;
			var sizeLength:String=xml.@sizeLength;
			var sizeWidth:String=xml.@sizeWidth;
			var sizeHeight:String=xml.@sizeHeight;
			var index:int;
			if(sizeLength.length>0)
			{
				index=sizeLength.indexOf("-");
				_minSize.x=Number(sizeLength.substr(0,index));
				_maxSize.x=Number(sizeLength.substr(index+1));
			}
			if(sizeWidth.length>0)
			{
				index=sizeWidth.indexOf("-");
				_minSize.y=Number(sizeWidth.substr(0,index));
				_maxSize.y=Number(sizeWidth.substr(index+1));
			}
			if(sizeHeight.length>0)
			{
				index=sizeHeight.indexOf("-");
				_minSize.z=Number(sizeHeight.substr(0,index));
				_maxSize.z=Number(sizeHeight.substr(index+1));
			}
			invalidPosition=true;
		}
		public function clone():CBaseTaskObject3DVO
		{
			var cls:Class=CParamDict.Instance.getParamDataTypeCls(_className);
			var clone:CBaseTaskObject3DVO=new cls(_className);
			clone.name=name;
			clone.code=code;
			clone.material=material;
			clone.url=url;
			clone.uniqueID=CUtil.Instance.createUID();
			clone.parentID=parentID;
			clone.type=type;
			clone.parentType=parentType;
			clone.length=length;
			clone.width=width;
			clone.height=height;
			clone.x=x;
			clone.y=y;
			clone.z=z;
			clone.scaleLength=scaleLength;
			clone.scaleWidth=scaleWidth;
			clone.scaleHeight=scaleHeight;
			clone.rotationLength=rotationLength;
			clone.rotationWidth=rotationWidth;
			clone.rotationHeight=rotationHeight;
			clone.offLeft=offLeft;
			clone.offBack=offBack;
			clone.offGround=offGround;
			clone.roundPoints=roundPoints;
			clone.isLife=isLife;
			clone.num=num;
			return clone;
		}
		
		
	}
}