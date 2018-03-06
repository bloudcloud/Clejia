package main.model.vo.task
{
	/**
	 * 参数化拐角数据类
	 * @author cloud
	 */
	public class CParamCornerVO extends CParamPartVO
	{
		public function CParamCornerVO(clsType:String="CParamCornerVO")
		{
			super(clsType);
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			num=int(xml.@cornerNum);
		}
	}
}