package wallDecorationModule.model.vo
{
	import flash.geom.Vector3D;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.utils.CMathUtil;
	import cloud.core.utils.CVectorUtil;
	
	import main.model.vo.task.CParamLineVO;
	 
	/**
	 * 参数化门线数据类
	 * @author cloud
	 * @2017-8-28
	 */
	public class CDoorLineVO extends CParamLineVO
	{
		public var cornerPaths:String;
		
		public function CDoorLineVO(clsType:String="CParamLineVO")
		{
			super(clsType);
			_isXYZ=true;
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			cornerPaths=xml.@cornerPaths;
		}

		override protected function doCreateLoftingPaths(loftingAxis:CVector, towardAxis:CVector, paths:Array):void
		{
			var dir:CVector=CVector.CreateOneInstance();
			var startPos:CVector=CVector.CreateOneInstance();
			var pos:CVector=CVector.CreateOneInstance();
			CVectorUtil.Instance.calculateDirectionByRotation(globalRotation.z,dir);
			localToGlobal(CVector.ZERO,pos);
			_qLength=0;
			if(num==4)
			{
				CVector.Copy(loftingAxis,CVector.Z_AXIS);
				CVector.SetTo(towardAxis,dir.y*loftingAxis.z-dir.z*loftingAxis.y
					,dir.z*loftingAxis.x-dir.x*loftingAxis.z	
					,dir.x*loftingAxis.y-dir.y*loftingAxis.x);
				CVector.Scale(towardAxis,2);
				if(cornerPaths.length==0)
				{
					CVector.Scale(dir,realLength);
					CVector.Scale(loftingAxis,realHeight);
					CVector.SetTo(startPos,pos.x-dir.x*.5+towardAxis.x
						,pos.y-dir.y*.5+towardAxis.y
						,pos.z-dir.z*.5+towardAxis.z);
					paths.push(new Vector3D(startPos.x+dir.x,startPos.y+dir.y,startPos.z+dir.z)
						,new Vector3D(startPos.x,startPos.y,startPos.z)
						,new Vector3D(startPos.x+loftingAxis.x,startPos.y+loftingAxis.y,startPos.z+loftingAxis.z)
						,new Vector3D(startPos.x+loftingAxis.x+dir.x,startPos.y+loftingAxis.y+dir.y,startPos.z+loftingAxis.z+dir.z)
						,new Vector3D(startPos.x+dir.x,startPos.y+dir.y,startPos.z+dir.z)
						,new Vector3D(startPos.x,startPos.y,startPos.z)
						,new Vector3D(startPos.x+loftingAxis.x,startPos.y+loftingAxis.y,startPos.z+loftingAxis.z)
					);
					_qLength=realLength*2+realHeight*2;
				}
				else
				{
					var currentPaths:Vector.<Number>;
					var sourceCornerPos:Vector.<Number>=Vector.<Number>(cornerPaths.split(","));
					var len:int;
					var maxX:Number=int.MIN_VALUE,minX:Number=int.MAX_VALUE,maxY:Number=int.MIN_VALUE,minY:Number=int.MAX_VALUE,maxZ:Number=int.MIN_VALUE,minZ:Number=int.MAX_VALUE;
					var length:Number,width:Number,height:Number;
					var localPos:CVector,globalPos:CVector;
					localPos=CVector.CreateOneInstance();
					globalPos=CVector.CreateOneInstance();
					len=sourceCornerPos.length;
					for(var i:int=0; i<len; i+=3)
					{
						if(maxX<sourceCornerPos[i])
							maxX=sourceCornerPos[i];
						if(minX>sourceCornerPos[i])
							minX=sourceCornerPos[i];
						if(maxY<sourceCornerPos[i+1])
							maxY=sourceCornerPos[i+1];
						if(minY>sourceCornerPos[i+1])
							minY=sourceCornerPos[i+1];
						if(maxZ<sourceCornerPos[i+2])
							maxZ=sourceCornerPos[i+2];
						if(minZ>sourceCornerPos[i+2])
							minZ=sourceCornerPos[i+2];
					}
					length=maxX-minX;
					width=maxY-minY;
					height=maxZ-minZ;
					var originPos:CVector=new CVector(0,0,0);
					var pos3D:Vector3D;
					//生成放样路径
					currentPaths=CMathUtil.Instance.calMirrorByAxis(sourceCornerPos,originPos,true,false,true);
					var count:int;
					for(i=len-1; i>0; i-=3)
					{
						CVector.SetTo(localPos,currentPaths[i-2],currentPaths[i-1],currentPaths[i]);
						this.localToGlobal(localPos,globalPos);
						pos3D=CVectorUtil.Instance.transformToVector3D(globalPos);
						pos3D.x+=towardAxis.x;
						pos3D.y+=towardAxis.y;
						pos3D.z+=realHeight*.5+towardAxis.z;
						paths.push(pos3D);
					}
					CVector.Scale(dir,this.length);
					paths.unshift(new Vector3D(paths[0].x+dir.x,paths[0].y+dir.y,paths[0].z+dir.z));
					for(i=0; i<len; i+=3)
					{
						CVector.SetTo(localPos,sourceCornerPos[i],sourceCornerPos[i+1],sourceCornerPos[i+2]);
						this.localToGlobal(localPos,globalPos);
						pos3D=CVectorUtil.Instance.transformToVector3D(globalPos);
						pos3D.x+=towardAxis.x;
						pos3D.y+=towardAxis.y;
						pos3D.z+=realHeight*.5+towardAxis.z;
						paths.push(pos3D);
					}
					currentPaths=CMathUtil.Instance.calMirrorByAxis(sourceCornerPos,originPos,false,true,true);
					for(i=len-1; i>0; i-=3)
					{
						CVector.SetTo(localPos,currentPaths[i-2],currentPaths[i-1],currentPaths[i]);
						this.localToGlobal(localPos,globalPos);
						pos3D=CVectorUtil.Instance.transformToVector3D(globalPos);
						pos3D.x+=towardAxis.x;
						pos3D.y+=towardAxis.y;
						pos3D.z+=realHeight*.5+towardAxis.z;
						paths.push(pos3D);
					}
					currentPaths=CMathUtil.Instance.calMirrorByAxis(sourceCornerPos,originPos,true,true,true);
					for(i=0; i<len; i+=3)
					{
						CVector.SetTo(localPos,currentPaths[i],currentPaths[i+1],currentPaths[i+2]);
						this.localToGlobal(localPos,globalPos);
						pos3D=CVectorUtil.Instance.transformToVector3D(globalPos);
						pos3D.x+=towardAxis.x;
						pos3D.y+=towardAxis.y;
						pos3D.z+=realHeight*.5+towardAxis.z;
						paths.push(pos3D);
					}
					paths.push(paths[1].clone(),paths[2].clone());
					localPos.back();
					globalPos.back();
					len=paths.length;

					for(i=1; i<len-2; i++)
					{
						_qLength+=Vector3D.distance(paths[i],paths[i+1]);
					}
				}
				CVector.Negate(loftingAxis);
			}
			dir.back();
			startPos.back();
			pos.back();
		}
	}
}