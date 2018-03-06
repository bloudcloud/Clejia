package wallDecorationModule.model.vo
{
	import cloud.core.datas.base.CVector;
	
	import main.model.vo.task.CParamCornerVO;
	
	/**
	 * 带拐角的护墙板区域数据类
	 * @author cloud
	 */
	public class CClapboardRectangleCornerVO extends CParamCornerVO
	{
		public function CClapboardRectangleCornerVO(clsType:String="CClapboardRectangleCornerVO")
		{
			super(clsType);
			
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			if(num==0)
				num=4;
		}
		override protected function doUpdatePositionByOffset():void
		{
			var toward:CVector=CVector.CrossValue(direction,CVector.Z_AXIS);
			var zAxis:CVector=CVector.Z_AXIS.clone() as CVector
			CVector.Scale(toward,parent.width+2+offBack);
			CVector.Scale(zAxis,-parent.height*.5+this.height*.5+offGround);
			x=toward.x+zAxis.x;
			y=toward.y+zAxis.y;
			z=toward.z+zAxis.z;
			toward.back();
			zAxis.back();
		}
	}
}