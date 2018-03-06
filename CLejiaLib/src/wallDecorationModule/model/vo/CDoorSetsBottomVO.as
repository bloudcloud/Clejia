package wallDecorationModule.model.vo
{
	import main.model.vo.task.CAttachmentVO;
	
	/**
	 * 门套角柱数据类
	 * @author cloud
	 * @2017-9-1
	 */
	public class CDoorSetsBottomVO extends CAttachmentVO
	{
		
		public function CDoorSetsBottomVO(clsType:String="CDoorSetsBottomVO")
		{
			super(clsType);
			_isXYZ=true;
		}
	}
}