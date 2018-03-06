package wallDecorationModule.model.vo
{
	import main.model.vo.task.CAttachmentVO;

	/**
	 * 门把手附属物数据类
	 * @author cloud
	 * @2017-8-28
	 */
	public class CDoorHandleVO extends CAttachmentVO
	{
		public function CDoorHandleVO(clsType:String="CDoorHandleVO")
		{
			super(clsType);
			_isXYZ=true;
		}
	
	}
}