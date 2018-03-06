package wallDecorationModule.model.vo
{
	import main.model.vo.plans.CParamPlanVO;

	/**
	 * 背景墙方案数据类
	 * @author cloud
	 */
	public class CBackgroundWallPlanVO extends CParamPlanVO
	{
		public var rangeMode:uint;
		
		public function CBackgroundWallPlanVO(clsName:String)
		{
			super(clsName);
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			rangeMode=Number(xml.@rangeMode);
		}
		override protected function doSerializeXML():XML
		{
			var xml:XML=super.doSerializeXML();
			xml.@rangeMode=rangeMode;
			return xml;
		}
	}
}