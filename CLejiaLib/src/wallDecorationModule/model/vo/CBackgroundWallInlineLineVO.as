package wallDecorationModule.model.vo
{
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import main.model.vo.task.CParamLineVO;
	
	/**
	 * 背景墙内区域的线条数据类
	 * @author cloud
	 */
	public class CBackgroundWallInlineLineVO extends CParamLineVO
	{
		
		public function CBackgroundWallInlineLineVO(clsType:String)
		{
			super(clsType);
			num=3;
		}
		override public function updateVO(source:CBaseObject3DVO):void
		{
			super.updateVO(source);
			num=3;
		}
	}
}