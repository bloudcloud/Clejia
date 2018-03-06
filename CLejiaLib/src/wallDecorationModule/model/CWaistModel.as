package wallDecorationModule.model
{
	import main.model.CDecorationModel;
	/**
	 *  3D腰线数据模型类
	 * @author cloud
	 * 
	 */	
	public class CWaistModel extends CDecorationModel
	{
		public function CWaistModel()
		{
			super("CWaistModel");
		}
		
		public function excuteDataCollection():Boolean
		{
			if(!isLoadEnd) return false;
			return canLoad;
		}
	}
}