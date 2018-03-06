package wallDecorationModule.model.vo
{
	import main.model.vo.task.CParamRectangleVO;
	
	/**
	 * 参数化门单元件数据类
	 * @author cloud
	 * @2017-8-28
	 */
	public class CDoorUnitVO extends CParamRectangleVO
	{
		public function CDoorUnitVO(clsType:String="CDoorUnitVO")
		{
			super(clsType);
			_isXYZ=true;
		}
		
	}
}