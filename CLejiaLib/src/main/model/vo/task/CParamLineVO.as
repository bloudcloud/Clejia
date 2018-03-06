package main.model.vo.task
{
	import flash.geom.Vector3D;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CVectorUtil;

	/**
	 * 参数化线条类
	 * @author cloud
	 */
	public class CParamLineVO extends CParamPartVO
	{
		
		public function CParamLineVO(clsType:String="CParamLineVO")
		{
			super(clsType);
		}
		
		override protected function doUpdatePositionByOffset():void
		{
			var dir:CVector=direction.clone() as CVector;
			var toward:CVector=CVector.CrossValue(direction,CVector.Z_AXIS);
			var zAxis:CVector=CVector.Z_AXIS.clone() as CVector;
			CVector.Scale(dir,-parent.length*.5+this.length*.5+offLeft);
			CVector.Scale(toward,parent.width+2+offBack);
			if(num>1)
				CVector.Scale(zAxis,-parent.height*.5+this.height*.5+offGround);
			else
				CVector.Scale(zAxis,-parent.height*.5+offGround);
			x=dir.x+toward.x+zAxis.x;
			y=dir.y+toward.y+zAxis.y;
			z=dir.z+toward.z+zAxis.z;
			dir.back();
			toward.back();
			zAxis.back();
		}
		/**
		 * 创建3D放样围点路径 
		 * @param paths
		 * 
		 */		
		override protected function doCreateLoftingPaths(loftingAxis:CVector,towardAxis:CVector,paths:Array):void
		{
			var rightAxis:CVector;
			var pos:CVector=CVector.CreateOneInstance();
			var dir:CVector=CVector.CreateOneInstance();
			var startPos:CVector=CVector.CreateOneInstance();
			var endPos:CVector=CVector.CreateOneInstance();
			var tmpLoftingAxis:CVector,tmpTowardAixs:CVector;
			
			CVectorUtil.Instance.calculateDirectionByRotation(globalRotation.z,dir);
			CVector.Scale(dir,realLength);
			localToGlobal(CVector.ZERO,pos);
			if(num==1)
			{
				var startOffsetVec:CVector=CVector.CreateOneInstance();
				var endOffsetVec:CVector=CVector.CreateOneInstance();
				rightAxis=CVector.Z_AXIS.clone() as CVector;
				CVector.Copy(loftingAxis,dir);
				CVector.SetTo(towardAxis,loftingAxis.y*rightAxis.z-loftingAxis.z*rightAxis.y
					,loftingAxis.z*rightAxis.x-loftingAxis.x*rightAxis.z
					,loftingAxis.x*rightAxis.y-loftingAxis.y*rightAxis.x);
				CVector.SetTo(startPos,pos.x-loftingAxis.x*.5,pos.y-loftingAxis.y*.5,pos.z-loftingAxis.z*.5);
				//修正线条放样起点和终点方向的偏移值
				tmpLoftingAxis=CVector.Normalize(loftingAxis,true);
				tmpTowardAixs=CVector.Normalize(towardAxis,true);
				startOffsetVec=CVector.CreateOneInstance();
				endOffsetVec=CVector.CreateOneInstance();
				if(startOffsetScale!=0)
				{
					CVector.SetTo(startOffsetVec,
						tmpLoftingAxis.x*startOffsetScale*width+tmpTowardAixs.x*startOffsetScale*width,
						tmpLoftingAxis.y*startOffsetScale*width+tmpTowardAixs.y*startOffsetScale*width,
						tmpLoftingAxis.z*startOffsetScale*width+tmpTowardAixs.z*startOffsetScale*width);
				}
				else
				{
					CVector.SetTo(startOffsetVec,-tmpLoftingAxis.x*width,-tmpLoftingAxis.y*width,-tmpLoftingAxis.z*width);
				}
				if(endOffsetScale!=0)
				{
					CVector.SetTo(endOffsetVec,
						-tmpLoftingAxis.x*endOffsetScale*width+tmpTowardAixs.x*endOffsetScale*width,
						-tmpLoftingAxis.y*endOffsetScale*width+tmpTowardAixs.y*endOffsetScale*width,
						-tmpLoftingAxis.z*endOffsetScale*width+tmpTowardAixs.z*endOffsetScale*width);
				}
				else
				{
					CVector.SetTo(endOffsetVec,tmpLoftingAxis.x*width,tmpLoftingAxis.y*width,tmpLoftingAxis.z*width);
				}
				paths.push(new Vector3D(startPos.x+startOffsetVec.x,startPos.y+startOffsetVec.y,startPos.z+startOffsetVec.z),
					new Vector3D(startPos.x,startPos.y,startPos.z),
					new Vector3D(startPos.x+loftingAxis.x,startPos.y+loftingAxis.y,startPos.z+loftingAxis.z),
					new Vector3D(startPos.x+loftingAxis.x+endOffsetVec.x,startPos.y+loftingAxis.y+endOffsetVec.y,startPos.z+loftingAxis.z+endOffsetVec.z));
				
				qLength=realLength;
				
				CVector.Negate(loftingAxis);
			}
			else if(num==4)
			{
				rightAxis=CVector.CreateOneInstance();
				CVector.Copy(loftingAxis,CVector.Z_AXIS);
				CVector.Copy(rightAxis,dir);
				CVector.Scale(loftingAxis,realHeight);
				CVector.SetTo(startPos,pos.x-loftingAxis.x*.5-rightAxis.x*.5
					,pos.y-loftingAxis.y*.5-rightAxis.y*.5
					,pos.z-loftingAxis.z*.5-rightAxis.z*.5);
				paths.push(new Vector3D(startPos.x+rightAxis.x,startPos.y+rightAxis.y,startPos.z+rightAxis.z)
					,new Vector3D(startPos.x,startPos.y,startPos.z)
					,new Vector3D(startPos.x+loftingAxis.x,startPos.y+loftingAxis.y,startPos.z+loftingAxis.z)
					,new Vector3D(startPos.x+loftingAxis.x+rightAxis.x,startPos.y+loftingAxis.y+rightAxis.y,startPos.z+loftingAxis.z+rightAxis.z)
					,new Vector3D(startPos.x+rightAxis.x,startPos.y+rightAxis.y,startPos.z+rightAxis.z)
					,new Vector3D(startPos.x,startPos.y,startPos.z)
					,new Vector3D(startPos.x+loftingAxis.x,startPos.y+loftingAxis.y,startPos.z+loftingAxis.z)
				);
				CVector.SetTo(towardAxis,rightAxis.y*loftingAxis.z-rightAxis.z*loftingAxis.y
					,rightAxis.z*loftingAxis.x-rightAxis.x*loftingAxis.z
					,rightAxis.x*loftingAxis.y-rightAxis.y*loftingAxis.x);
				qLength=realLength*2+realHeight*2;
			}
			startPos.back();
			endPos.back();
			pos.back();
			dir.back();
			if(rightAxis)
				rightAxis.back();
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			if(num==0)
				num=xml.@lineNum;
		}
		
		override public function updateVO(source:CBaseObject3DVO):void
		{
			super.updateVO(source);
			if(source is CParamLineVO || source is CParamRectangleVO)
				num=source["num"];
		}
	}
}