package main.model.vo.task
{
	import mx.utils.UIDUtil;
	
	import wallDecorationModule.dict.CDecorationParamDict;

	/**
	 * 参数化矩形区域任务数据类
	 * @author cloud
	 */
	public class CParamRectangle3DTaskVO extends CParam3DTaskVO
	{
		public var lineCode:String;
		public var lineMaterial:String;
		public var cornerCode:String;
		public var cornerMaterial:String;
		public var lineType:uint;
		public var cornerType:uint;
		
		public var lineLength:Number;
		public var lineWidth:Number;
		public var cornerLength:Number;
		public var cornerWidth:Number;
		
		public function CParamRectangle3DTaskVO()
		{
			super();
		}

		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			lineCode=String(xml.@lineCode);
			lineMaterial=String(xml.@lineMaterial);
			lineLength=Number(xml.@lineLength);
			lineWidth=Number(xml.@lineWidth);
			cornerCode=String(xml.@cornerCode);
			cornerMaterial=String(xml.@cornerMaterial);
			cornerLength=Number(xml.@cornerLength);
			cornerWidth=Number(xml.@cornerWidth);
			lineType=CDecorationParamDict.instance.getTypeByString(String(xml.@lineType));
			cornerType=CDecorationParamDict.instance.getTypeByString(String(xml.@cornerType));
		}
		override public function clone():CParam3DTaskVO
		{
			var clone:CParamRectangle3DTaskVO=new CParamRectangle3DTaskVO();
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
			clone.rotation=rotation;
			clone.direction=direction;
			clone.isLife=isLife;
			clone.topSpacing=topSpacing;
			clone.bottomSpacing=bottomSpacing;
			clone.leftSpacing=leftSpacing;
			clone.rightSpacing=rightSpacing;
			clone.lineType=lineType;
			clone.lineCode=lineCode;
			clone.lineMaterial=lineMaterial;
			clone.lineLength=lineLength;
			clone.lineWidth=lineWidth;
			clone.cornerType=cornerType;
			clone.cornerCode=cornerCode;
			clone.cornerMaterial=cornerMaterial;
			clone.cornerLength=cornerLength;
			clone.cornerWidth=cornerWidth;
			clone.unitType=unitType;
			clone.unitUniqueID=unitUniqueID;
			clone.offGround=offGround;
			clone.lengthScale=lengthScale;
			clone.heightScale=heightScale;
			clone.thicknessOffset=thicknessOffset;
			clone.groupID=groupID;
			clone.name=name;
			clone.qLength=qLength;
			clone.qWidth=qWidth;
			clone.qHeight=qHeight;
			clone.price=price;
			clone.previewBuffer=previewBuffer;
			return clone;
		}
	}
}