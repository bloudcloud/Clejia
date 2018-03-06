package wallDecorationModule.model.vo
{
	import flash.geom.Vector3D;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.utils.CVectorUtil;
	
	import main.model.vo.task.CParamLineVO;
	
	/**
	 * 参数化门套线数据类
	 * @author cloud
	 * @2017-8-28
	 */
	public class CDoorSetsLineVO extends CParamLineVO
	{
		public function CDoorSetsLineVO(clsType:String="CDoorSetsLineVO")
		{
			super(clsType);
			_isXYZ=true;
		}

		override protected function doCreateLoftingPaths(loftingAxis:CVector, towardAxis:CVector, paths:Array):void
		{
			var pos:CVector,dir:CVector,startPos:CVector;
			var i:int,len:int;
			pos=CVector.CreateOneInstance();
			startPos=CVector.CreateOneInstance();
			dir=CVector.CreateOneInstance();
			CVectorUtil.Instance.calculateDirectionByRotation(globalRotation.z,dir);
			localToGlobal(CVector.ZERO,pos);
			if(num==3)
			{
				CVector.Copy(loftingAxis,CVector.Z_AXIS);
				CVector.SetTo(towardAxis,dir.y*loftingAxis.z-dir.z*loftingAxis.y
					,dir.z*loftingAxis.x-dir.x*loftingAxis.z
					,dir.x*loftingAxis.y-dir.y*loftingAxis.x);

				CVector.Scale(dir,realLength);
				CVector.Scale(loftingAxis,realHeight);
				CVector.SetTo(startPos,pos.x-dir.x*.5,pos.y-dir.y*.5,pos.z-dir.z*.5);
				paths.push(new Vector3D(startPos.x-loftingAxis.x,startPos.y-loftingAxis.y,startPos.z-loftingAxis.z)
					,new Vector3D(startPos.x,startPos.y,startPos.z)
					,new Vector3D(startPos.x+loftingAxis.x,startPos.y+loftingAxis.y,startPos.z+loftingAxis.z)
					,new Vector3D(startPos.x+loftingAxis.x+dir.x,startPos.y+loftingAxis.y+dir.y,startPos.z+loftingAxis.z+dir.z)
					,new Vector3D(startPos.x+dir.x,startPos.y+dir.y,startPos.z+dir.z)
					,new Vector3D(startPos.x-loftingAxis.x+dir.x,startPos.y-loftingAxis.y+dir.y,startPos.z-loftingAxis.z+dir.z)
				);
				len=paths.length;
				_qLength=0;
				for(i=1; i<len-2; i++)
				{
					_qLength+=Vector3D.distance(paths[i],paths[i+1]);
				}
				CVector.Negate(loftingAxis);
				pos.back();
				dir.back();
				startPos.back();
			}
		}
		
	}
}