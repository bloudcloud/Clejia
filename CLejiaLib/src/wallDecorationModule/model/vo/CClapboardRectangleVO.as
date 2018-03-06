package wallDecorationModule.model.vo
{
	import cloud.core.datas.base.CVector;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import main.dict.CParamDict;
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParamRectangleVO;
	
	/**
	 * 护墙板矩形区域数据类
	 * @author cloud
	 */
	public class CClapboardRectangleVO extends CParamRectangleVO	
	{
		override public function get width():Number
		{
			return super.width;
		}
		public function CClapboardRectangleVO(clsType:String="CClapboardRectangleVO")
		{
			super(clsType);
		}
		override protected function doUpdatePositionByOffset():void
		{
			var toward:CVector=CVector.CrossValue(direction,CVector.Z_AXIS);
			var zAxis:CVector=CVector.Z_AXIS.clone() as CVector;
//			if(material.length==0)
//			{
//				CVector.Scale(toward,0);
//			}
//			else
//			{
//				if(_width==0)
//					_width=CParamDict.DEFAULT_CLAPBOARD_UINT_BOARD_THICKNESS;
//				CVector.Scale(toward,width+2+offBack);
//			}
			if(material.length>0 && _width==0)
				_width=CParamDict.DEFAULT_CLAPBOARD_UINT_BOARD_THICKNESS;
			CVector.Scale(toward,width+2+offBack);
			CVector.Scale(zAxis,-parent.height*.5+this.height*.5+offGround);
			x=toward.x+zAxis.x;
			y=toward.y+zAxis.y;
			z=toward.z+zAxis.z;
			toward.back();
			zAxis.back();
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			if(lineNum==0)
			{
				lineNum=4;
			}
		}
		override public function updateVO(source:CBaseObject3DVO):void
		{
			super.updateVO(source);
			if(lineNum==0)
				lineNum=4;
		}
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CClapboardRectangleVO=super.clone() as CClapboardRectangleVO;
			if(clone.lineNum==0)
				clone.lineNum=4;
			return clone;
		}
	}
}