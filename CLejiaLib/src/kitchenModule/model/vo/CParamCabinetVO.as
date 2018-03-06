package kitchenModule.model.vo
{
	import main.model.vo.task.CParamAssembleVO;
	
	/**
	 * 参数化柜体数据类（地柜，高柜，中高柜等）
	 * @author cloud
	 * @2017-6-28
	 */
	public class CParamCabinetVO extends CParamAssembleVO
	{
		public function CParamCabinetVO(clsName:String="CParamCabinetVO")
		{
			super(clsName);
		}
		
	}
}