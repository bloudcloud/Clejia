package main.model.vo
{
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	public class CRoom3DVO extends CBaseObject3DVO
	{
		public var roomHeight:uint=2800;
		
		public function CRoom3DVO(clsName:String="CRoom3DVO")
		{
			super(clsName);
		}
		
	}
}