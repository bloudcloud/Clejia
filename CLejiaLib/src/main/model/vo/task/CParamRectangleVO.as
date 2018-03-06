package main.model.vo.task
{
	import flash.geom.Vector3D;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CUtil;
	
	import main.dict.CParamDict;

	/**
	 * 参数化矩形组合数据类(板，圈线，角)
	 * @author cloud
	 */
	public class CParamRectangleVO extends CParamPartVO
	{
		public var lineClassName:String;
		public var lineCode:String;
		public var lineMaterial:String;
		public var lineType:uint;
		public var lineLength:Number;
		public var lineWidth:Number;
		public var lineHeight:Number;
		public var lineOffLeft:Number;
		public var lineOffBack:Number;
		public var lineOffGround:Number;
		public var lineNum:int;
		
		public var cornerClassName:String;
		public var cornerCode:String;
		public var cornerMaterial:String;
		public var cornerType:uint;
		public var cornerLength:Number;
		public var cornerWidth:Number;
		public var cornerHeight:Number;
		public var cornerOffLeft:Number;
		public var cornerOffBack:Number;
		public var cornerOffGround:Number;
		public var cornerNum:int;
		
		public var bottomClassName:String;
		public var bottomCode:String;
		public var bottomMaterial:String;
		public var bottomType:uint;
		public var bottomLength:Number;
		public var bottomWidth:Number;
		public var bottomHeight:Number;
		public var bottomOffLeft:Number;
		public var bottomOffBack:Number;
		public var bottomOffGround:Number;
		public var bottomNum:int;
		
		public function get hasLine():Boolean
		{
			return lineCode!=null&&lineCode.length>0;
		}
		public function get hasCorner():Boolean
		{
			return cornerCode!=null&&cornerCode.length>0;
		}
		public function get hasBottom():Boolean
		{
			return bottomCode!=null&&bottomCode.length>0;
		}
		
		public function CParamRectangleVO(clsType:String="CParamRectangleVO")
		{
			super(clsType);
		}
		protected function doCreateLineVO():CBaseTaskObject3DVO
		{
			var cls:Class=CParamDict.Instance.getParamDataTypeCls(lineClassName);
			var childVo:CBaseTaskObject3DVO;	
			childVo=new cls(lineClassName);
			childVo.uniqueID=CUtil.Instance.createUID();
			childVo.length=this.length;
			childVo.width=this.width;
			childVo.height=this.height;
			childVo.type=lineType;
			childVo.code=lineCode;
			childVo.material=lineMaterial;
			childVo.num=lineNum;
			this.addChild(childVo);
			return childVo;
		}
		protected function doCreateCorner():CBaseTaskObject3DVO
		{
			var cls:Class=CParamDict.Instance.getParamDataTypeCls(cornerClassName);
			var childVo:CBaseTaskObject3DVO=new cls(cornerClassName);
			childVo.uniqueID=CUtil.Instance.createUID();
			childVo.length=this.length;
			childVo.width=this.width;
			childVo.height=this.height;
			childVo.type=cornerType;
			childVo.code=cornerCode;
			childVo.material=cornerMaterial;
			childVo.num=cornerNum;
			this.addChild(childVo);
			return childVo;
		}
		protected function doCreateBottom():CBaseTaskObject3DVO
		{
			var cls:Class=CParamDict.Instance.getParamDataTypeCls(bottomClassName);
			var childVo:CBaseTaskObject3DVO=new cls(bottomClassName);
			childVo.uniqueID=CUtil.Instance.createUID();
			childVo.length=this.length;
			childVo.width=this.width;
			childVo.height=this.height;
			childVo.type=bottomType;
			childVo.code=bottomCode;
			childVo.material=bottomMaterial;
			this.addChild(childVo);
			return childVo;
		}
		protected function doDeserializeLine(xml:XML):void
		{
			lineClassName=xml.@lineClassName;
			lineCode=String(xml.@lineCode);
			lineMaterial=String(xml.@lineMaterial);
			CParamDict.Instance.addTypeDef(String(xml.@lineType),lineClassName);
			lineType=CParamDict.Instance.getTypeByString(String(xml.@lineType));
			lineLength=Number(xml.@lineLength);
			lineWidth=Number(xml.@lineWidth);
			lineHeight=Number(xml.@lineHeight);
			lineNum=int(xml.@lineNum);
			if(lineMaterial.length>0)
			{
				doCreateLineVO();
			}
		}
		protected function doDeserializeCorner(xml:XML):void
		{
			cornerClassName=xml.@cornerClassName;
			cornerCode=String(xml.@cornerCode);
			cornerMaterial=String(xml.@cornerMaterial);
			CParamDict.Instance.addTypeDef(String(xml.@cornerType),cornerClassName);
			cornerType=CParamDict.Instance.getTypeByString(String(xml.@cornerType));
			cornerLength=Number(xml.@cornerLength);
			cornerWidth=Number(xml.@cornerWidth);
			cornerHeight=Number(xml.@cornerHeight);
			cornerNum=int(xml.@cornerNum);
			if(cornerCode.length>0 || cornerMaterial.length>0)
			{
				doCreateCorner();
			}
		}
		protected function doDeserializeBottom(xml:XML):void
		{
			bottomClassName=xml.@bottomClassName;
			bottomCode=String(xml.@bottomCode);
			bottomMaterial=String(xml.@bottomMaterial);
			CParamDict.Instance.addTypeDef(String(xml.@bottomType),bottomClassName);
			bottomType=CParamDict.Instance.getTypeByString(String(xml.@bottomType));
			bottomLength=Number(xml.@bottomLength);
			bottomWidth=Number(xml.@bottomWidth);
			bottomHeight=Number(xml.@bottomHeight);
			bottomNum=int(xml.@bottomNum);
			if(bottomCode.length>0 || bottomMaterial.length>0)
			{
				doCreateBottom();
			}
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			doDeserializeLine(xml);
			doDeserializeCorner(xml);
			doDeserializeBottom(xml);
		}
		override protected function doCreateLoftingPaths(loftingAxis:CVector, towardAxis:CVector, paths:Array):void
		{
			var startPos:CVector,endPos:CVector;
			var rightAxis:CVector;
			
			startPos=CVector.CreateOneInstance();
			endPos=CVector.CreateOneInstance();
			rightAxis=CVector.Z_AXIS;
			CVector.Copy(loftingAxis,direction);
			CVector.SetTo(towardAxis,loftingAxis.y*rightAxis.z-loftingAxis.z*rightAxis.y
				,loftingAxis.z*rightAxis.x-loftingAxis.x*rightAxis.z
				,loftingAxis.x*rightAxis.y-loftingAxis.y*rightAxis.x);
			width||=CParamDict.DEFAULT_CLAPBOARD_UINT_BOARD_THICKNESS;
			CVector.SetTo(startPos,-realLength*.5,0,-realHeight*.5);
			CVector.SetTo(endPos,realLength*.5,0,-realHeight*.5);
			if(startOffsetScale!=0)
			{
				startPos.x+=startOffsetScale*width*2;
			}
			if(endOffsetScale!=0)
			{
				endPos.x-=endOffsetScale*width*2;
			}
			paths.push(new Vector3D(startPos.x,startPos.y,startPos.z),
				new Vector3D(endPos.x,endPos.y,endPos.z),
				new Vector3D(endPos.x,endPos.y,endPos.z+realHeight),
				new Vector3D(startPos.x,startPos.y,startPos.z+realHeight));
		}
		override public function updateVO(source:CBaseObject3DVO):void
		{
			super.updateVO(source);
			if(source is CParamLineVO || source is CParamRectangleVO)
				this.lineNum=source["lineNum"];
		}
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CParamRectangleVO=super.clone() as CParamRectangleVO;
			clone.lineClassName=lineClassName;
			clone.lineType=lineType;
			clone.lineCode=lineCode;
			clone.lineMaterial=lineMaterial;
			clone.lineLength=lineLength;
			clone.lineWidth=lineWidth;
			clone.lineHeight=lineHeight;
			clone.lineNum=lineNum;
			clone.cornerClassName=cornerClassName;
			clone.cornerType=cornerType;
			clone.cornerCode=cornerCode;
			clone.cornerMaterial=cornerMaterial;
			clone.cornerLength=cornerLength;
			clone.cornerWidth=cornerWidth;
			clone.cornerHeight=cornerHeight;
			clone.cornerNum=cornerNum;
			clone.bottomClassName=bottomClassName;
			clone.bottomType=bottomType;
			clone.bottomCode=bottomCode;
			clone.bottomMaterial=bottomMaterial;
			clone.bottomLength=bottomLength;
			clone.bottomWidth=bottomWidth;
			clone.bottomHeight=bottomHeight;
			clone.bottomNum=bottomNum;
			return clone;
		}
	}
}