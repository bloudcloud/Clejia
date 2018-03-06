package wallDecorationModule.model.vo
{
	import main.dict.CParamDict;
	import main.model.vo.task.CParamRectangleVO;
	
	/**
	 * 护墙板单元件数据类
	 * @author cloud
	 */
	public class CClapboardUnitVO extends CParamRectangleVO
	{
		public function CClapboardUnitVO(clsType:String="CClapboardUnitVO")
		{
			super(clsType);
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			if(width==0)
				width=CParamDict.DEFAULT_CLAPBOARD_UINT_BOARD_THICKNESS;
		}
	}
}