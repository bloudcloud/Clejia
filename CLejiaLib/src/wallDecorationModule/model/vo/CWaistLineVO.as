package wallDecorationModule.model.vo
{
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParamLineVO;
	
	public class CWaistLineVO extends CParamLineVO
	{
		public function CWaistLineVO(clsType:String="CWaistLineVO")
		{
			super(clsType);
		}
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CWaistLineVO=super.clone() as CWaistLineVO;
			if(clone.num==0)
				clone.num=1;
			return clone;
		}
	}
}