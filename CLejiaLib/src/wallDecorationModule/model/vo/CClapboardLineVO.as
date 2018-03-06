package wallDecorationModule.model.vo
{
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParamLineVO;
	
	/**
	 * 护墙板线条数据类
	 * @author cloud
	 */
	public class CClapboardLineVO extends CParamLineVO
	{

		public function CClapboardLineVO(clsType:String="CClapboardLineVO")
		{
			super(clsType);
		}
	
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			if(num==0)
				num=1;
		}
		
		override public function updateVO(source:CBaseObject3DVO):void
		{
			super.updateVO(source);
			if(num==0)
				num=1;
		}
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CClapboardLineVO=super.clone() as CClapboardLineVO;
			if(clone.num==0)
				clone.num=1;
			return clone;
		}
	}
}