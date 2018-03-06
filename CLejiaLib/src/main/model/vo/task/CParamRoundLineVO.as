package main.model.vo.task
{
	import flash.geom.Vector3D;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.utils.CVectorUtil;

	/**
	 * 参数化围线数据类
	 * @author cloud
	 */
	public class CParamRoundLineVO extends CParamLineVO
	{
		/**
		 * svg下载code 
		 */		
		public var svg:String;
		/**
		 * 是否镜像 
		 */		
		public var isMirror:Boolean;
		
		public function CParamRoundLineVO(clsType:String)
		{
			super(clsType);
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			svg=xml.@svg;
			var str:String=xml.@isMirror;
			isMirror=Boolean(str);
		}
		override protected function doUpdatePositionByOffset():void
		{
			var dir:CVector=direction.clone() as CVector;
			var toward:CVector=CVector.CrossValue(direction,CVector.Z_AXIS);
			var zAxis:CVector=CVector.Z_AXIS.clone() as CVector;
			CVector.Scale(dir,-parent.length*.5+this.length*.5+offLeft);
			CVector.Scale(toward,parent.width+2+offBack);
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
			var zAxis:CVector;
			var pos:CVector=CVector.CreateOneInstance();
			var dir:CVector=CVector.CreateOneInstance();
			var startPos:CVector=CVector.CreateOneInstance();
			CVectorUtil.Instance.calculateDirectionByRotation(globalRotation.z,dir);
			zAxis=CVector.Z_AXIS;
			CVector.SetTo(loftingAxis,dir.y*zAxis.z-dir.z*zAxis.y,dir.z*zAxis.x-dir.x*zAxis.z,dir.x*zAxis.y-dir.y*zAxis.x);
			CVector.Scale(dir,realLength);
			if(parent)
				localToGlobal(CVector.ZERO,pos);
			else
				CVector.Copy(pos,position);
			CVector.Copy(towardAxis,dir);
			CVector.Scale(loftingAxis,width);
			if(isMirror)
			{
				CVector.Negate(towardAxis);
			}
			if(num==2)
			{
				CVector.SetTo(startPos,pos.x-loftingAxis.x-towardAxis.x*.5,pos.y-loftingAxis.y-towardAxis.y*.5,pos.z-loftingAxis.z-towardAxis.z*.5);
				paths.push(new Vector3D(startPos.x-loftingAxis.x,startPos.y-loftingAxis.y,startPos.z-loftingAxis.z)
					,new Vector3D(startPos.x,startPos.y,startPos.z)
					,new Vector3D(startPos.x+loftingAxis.x,startPos.y+loftingAxis.y,startPos.z+loftingAxis.z)
					,new Vector3D(startPos.x+loftingAxis.x+towardAxis.x,startPos.y+loftingAxis.y+towardAxis.y,startPos.z+loftingAxis.z+towardAxis.z)
					,new Vector3D(startPos.x+loftingAxis.x+towardAxis.x+towardAxis.x,startPos.y+loftingAxis.y+towardAxis.y+towardAxis.y,startPos.z+loftingAxis.z+towardAxis.z+towardAxis.z));
			}
			else if(num==3)
			{
				CVector.SetTo(startPos,pos.x-loftingAxis.x-towardAxis.x*.5,pos.y-loftingAxis.y-towardAxis.y*.5,pos.z-loftingAxis.z-towardAxis.z*.5);
				paths.push(new Vector3D(startPos.x-loftingAxis.x,startPos.y-loftingAxis.y,startPos.z-loftingAxis.z)
					,new Vector3D(startPos.x,startPos.y,startPos.z)
					,new Vector3D(startPos.x+loftingAxis.x,startPos.y+loftingAxis.y,startPos.z+loftingAxis.z)
					,new Vector3D(startPos.x+loftingAxis.x+towardAxis.x,startPos.y+loftingAxis.y+towardAxis.y,startPos.z+loftingAxis.z+towardAxis.z)
					,new Vector3D(startPos.x+towardAxis.x,startPos.y+towardAxis.y,startPos.z+towardAxis.z)
					,new Vector3D(startPos.x+towardAxis.x-loftingAxis.x,startPos.y+towardAxis.y-loftingAxis.y,startPos.z+towardAxis.z-loftingAxis.z));
			}
			if(!isMirror)
				CVector.Negate(loftingAxis);
			CVector.Negate(towardAxis);
			startPos.back();
			pos.back();
			dir.back();
		}
		
	}
}