package main.model.vo.task
{
	import flash.geom.Vector3D;
	
	import cloud.core.datas.base.CVector;

	/**
	 * 参数化柱体数据类
	 * @author cloud
	 */
	public class CParamColumnVO extends CParamPartVO
	{
		public function CParamColumnVO(clsType:String="CParamColumnVO")
		{
			super(clsType);
		}
		override protected function doCreateLoftingPaths(loftingAxis:CVector, towardAxis:CVector, paths:Array):void
		{
			paths.push(new Vector3D(-realLength*.5,0,-realHeight*.5),new Vector3D(realLength*.5,0,-realHeight*.5),new Vector3D(realLength*.5,0,realHeight*.5),new Vector3D(-realLength*.5,0,realHeight*.5));
		}
	}
}