package main.model.vo.plans
{
	
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CUtil;
	
	/**
	 * 参数化方案数据类
	 * @author cloud
	 */
	public class CParamPlanVO extends CBaseObject3DVO
	{
		private var _invalidLength:Boolean;
		private var _realLength:Number;
		
		public function get realLength():Number
		{
			if(_invalidLength)
			{
				_invalidLength=false;
				_realLength=0;
				for(var child:ICObject3D=children; child!=null; child=child.next)
				{
					_realLength+=child.length;
				}
			}
			return _realLength;
		}
		
		public function CParamPlanVO(clsName:String)
		{
			super(clsName);
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			name=xml.@type;
			_length=Number(xml.@length);
			_width=Number(xml.@width);
			_height=Number(xml.@height);
			_scaleLength=Number(xml.@scaleLength);
			_scaleWidth=Number(xml.@scaleWidth);
			_scaleHeight=Number(xml.@scaleHeight);
			_rotationLength=Number(xml.@rotationLength);
			_rotationWidth=Number(xml.@rotationWidth);
			_rotationHeight=Number(xml.@rotationHeight);
			offLeft=Number(xml.@offLeft);
			offBack=Number(xml.@offBack);
			offGround=Number(xml.@offGround);
			x=Number(xml.@x);
			y=Number(xml.@y);
			z=Number(xml.@z);
			if(uniqueID=="" || uniqueID==null)
				uniqueID=CUtil.Instance.createUID();
			if(_scaleLength==0)
				_scaleLength=1;
			if(_scaleWidth==0)
				_scaleWidth=1;
			if(_scaleHeight==0)
				_scaleHeight=1;
		}
		override protected function doSerializeXML():XML
		{
			var xml:XML=<{className}></{className}>;
			xml.@type=name;
			xml.@length=length;
			xml.@width=width;
			xml.@height=height;
			xml.@scaleLength=scaleLength;
			xml.@scaleWidth=scaleWidth;
			xml.@scaleHeight=scaleHeight;
			xml.@offLeft=offLeft;
			xml.@offBack=offBack;
			xml.@offGround=offGround;
			return xml;
		}
		/**
		 * 销毁计划数据 
		 * 
		 */		
		public function dispose():void
		{
			clear();
		}
	}
}