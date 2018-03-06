package main.model.vo.task
{
	/**
	 * 参数化组合部件数据类
	 * @author cloud
	 */
	public class CParamAssembleVO extends CParamPartVO
	{
		public function CParamAssembleVO(clsName:String="CParamAssembleVO")
		{
			super(clsName);
			_isXYZ=true;
		}
		override protected function doUpdatePositionByXYZ():void
		{
			if(parent is CParamPartVO)
			{
				super.doUpdatePositionByXYZ();
			}
		}
	}
}