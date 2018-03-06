package utils
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.datas.base.CTransform3D;
	import cloud.core.datas.base.CVector;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CGeometry3DUtil;
	import cloud.core.utils.CVectorUtil;
	
	import l3dbuild.geometry.L3DBuildableMesh;
	
	import main.dict.CParamDict;
	import main.dict.GlobalConstDict;
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CObject3DVO;
	import main.model.vo.task.CParamLineVO;
	import main.model.vo.task.CParamPartVO;
	import main.model.vo.task.CParamRectangleVO;
	
	import wallDecorationModule.model.vo.CBackgroundWallInlineColumnVO;
	import wallDecorationModule.model.vo.CBackgroundWallInlineCornerVO;
	import wallDecorationModule.model.vo.CBackgroundWallInlineLineVO;
	import wallDecorationModule.model.vo.CBackgroundWallInlineVO;
	import wallDecorationModule.model.vo.CClapboardUnitVO;
	import wallDecorationModule.model.vo.CDoorRectangleVO;

	/**
	 * 
	 * @author cloud
	 * @2017-6-30
	 */
	public class CParamUtil
	{
		private static var _Instance:CParamUtil;
		public static function get Instance():CParamUtil
		{
			return _Instance ||= new CParamUtil(new SingletonEnforce());
		}
		public function CParamUtil(enforcer:SingletonEnforce)
		{
		}
		/**
		 * 获取数据的唯一标记 
		 * @param vo	
		 * @return String
		 * 
		 */		
		public function getUniqueKey(vo:CBaseObject3DVO):String
		{
			return vo.name+"_"+vo.length+"_"+vo.height;
		}
		/**
		 * 处理生成的3D模型对象 
		 * @param l3dMesh
		 * @param meshVos
		 * @param sourceMesh
		 * @param sourceMaterial
		 * @param sourceCode
		 * @param sourceType
		 * 
		 */		
		public function dealClapboardL3DMesh(l3dMesh:L3DMesh,meshVos:Vector.<CBaseTaskObject3DVO>,sourceMesh:L3DMesh,sourceMaterial:Material,sourceCode:String,sourceType:uint):void
		{
			var subMesh:Object3D;
			for(var j:int=0 ;j<l3dMesh.numChildren; j++)
			{
				subMesh=l3dMesh.getChildAt(j);
				if(subMesh is L3DMesh)
				{
					if(sourceMesh)
					{
						(subMesh as L3DMesh).catalog=22;
						(subMesh as L3DMesh).Mode=22;
					}
					(subMesh as L3DMesh).setMaterialToAllSurfaces(sourceMaterial);
				}
			}
			l3dMesh.userData2=meshVos;
			l3dMesh.userData3=sourceMesh;
			l3dMesh.userData4=sourceMaterial;
			l3dMesh.userData5=sourceCode;
			l3dMesh.userData6=sourceType;
			if(sourceMesh)
			{
				l3dMesh.catalog=sourceMesh.catalog;
				l3dMesh.family=sourceMesh.family;
				l3dMesh.Code=sourceMesh.Code;
				l3dMesh.ERPCode=sourceMesh.ERPCode;
				l3dMesh.Mode=sourceMesh.catalog;
				l3dMesh.isPolyMode=sourceMesh.isPolyMode;
			}
			else
			{
				l3dMesh.catalog=22;
				l3dMesh.Mode=22;
			}
		}
		/**
		 * 创建参数化模型 
		 * @param taskVo
		 * @param sourceMesh
		 * @param sourceMaterial
		 * @param parentMesh
		 * @param parentMeshVos
		 * @param addTaskVOCallback
		 * 
		 */			
		public function createParamMesh(taskVo:CBaseTaskObject3DVO,sourceMesh:L3DMesh,sourceMaterial:TextureMaterial,parentMesh:Mesh,parentMeshVos:Vector.<CBaseTaskObject3DVO>=null,addTaskVOCallback:Function=null):void
		{
			var paths:Vector.<Vector3D>;
			var subMesh:Mesh;
			//放样物体的方向轴
			var loftingAxis:CVector;
			//放样物体的朝向轴
			var towardAxis:CVector;
			var dir:CVector;
			var normal:CVector;
			var position:CVector;
			var tmpVec:CVector;
			var realLength:Number;
			var realHeight:Number;
			var rotaZ:Number;
			var partVo:CParamPartVO=taskVo as CParamPartVO;
			var object3DVo:CObject3DVO=taskVo as CObject3DVO;
			var lineVo:CParamLineVO=taskVo as CParamLineVO;
			var child:ICObject3D;
			var wallInlineBottomVo:CBackgroundWallInlineColumnVO;
			var wallInlineVo:CBackgroundWallInlineVO;
			var wallInlineLineVo:CBackgroundWallInlineLineVO;
			var wallInlineCornerVo:CBackgroundWallInlineCornerVO;
			var rectangleVo:CParamRectangleVO=taskVo as CParamRectangleVO;
			var unitVo:CClapboardUnitVO=taskVo as CClapboardUnitVO;
			var type:uint=CParamDict.Instance.getParamType(taskVo.type);
			switch(type)
			{
				case CParamDict.PARAM_UNIT_ONE:
				case CParamDict.PARAM_UNIT_TWO:
				case CParamDict.PARAM_UNIT_THREE:
				case CParamDict.PARAM_UNIT_FOUR:
				case CParamDict.PARAM_UNIT_FIVE:
				case CParamDict.PARAM_UNIT_NORMAL:
				case CParamDict.PARAM_UNIT_BOARD:
				case CParamDict.PARAM_UNIT_RECTANGLE:
				case CParamDict.PARAM_DOOR_RECTANGLE:
					//创建矩形面板
					if(parentMeshVos) parentMeshVos.push(rectangleVo);
					if(rectangleVo.width==0)
						rectangleVo.width=CParamDict.DEFAULT_CLAPBOARD_UINT_BOARD_THICKNESS;
					realLength=rectangleVo.realLength;
					realHeight=rectangleVo.realHeight;
					rotaZ=rectangleVo.globalRotation.z;
					rectangleVo.qLength=rectangleVo.realLength;
					rectangleVo.qWidth=rectangleVo.width;
					rectangleVo.qHeight=rectangleVo.realHeight;
					loftingAxis=CVector.CreateOneInstance();
					towardAxis=CVector.CreateOneInstance();
					position=CVector.CreateOneInstance();
					if(rectangleVo.parent!=null)
						rectangleVo.localToGlobal(CVector.ZERO,position);
					else
						CVector.Copy(position,rectangleVo.position);
					paths=rectangleVo.createLoftingPaths(loftingAxis,towardAxis);
					
					if(partVo is CDoorRectangleVO)
					{
//						CVector.Scale(towardAxis,40);
						CVector.Scale(towardAxis,2);
						position.x+=towardAxis.x;
						position.y+=towardAxis.y;
						position.z+=towardAxis.z+realHeight*.5;
					}
					CMeshUtil.Instance.createBoardMeshBySize(rectangleVo.qName,sourceMaterial,rectangleVo.width,paths,position,parentMesh,rotaZ,rectangleVo.rotationLength,rectangleVo.rotationWidth,rectangleVo.texRotation,true);
					loftingAxis.back();
					towardAxis.back();
					position.back();
					break;
				case CParamDict.PARAM_LINE_TOP:
				case CParamDict.PARAM_LINE_TOP_COLUMN:
				case CParamDict.PARAM_LINE_BOTTOM:
				case CParamDict.PARAM_LINE_BOTTOM_COLUMN:
				case CParamDict.PARAM_LINE_WAIST:
				case CParamDict.PARAM_LINE_WAIST_COLUMN:
				case CParamDict.PARAM_PANEL_LINE:
				case CParamDict.PARAM_RECTANGLE_ON_LINE:
				case CParamDict.PARAM_ROUNDLINE_NORMAL:
				case CParamDict.PARAM_DOOR_LINE:
				case CParamDict.PARAM_DOORSETS_LINE:
				case CParamDict.PARAM_DOORSETS_BODYBOARD:
					//创建线条
					if(parentMeshVos) parentMeshVos.push(partVo);
					if(lineVo!=null)
					{
						loftingAxis=CVector.CreateOneInstance();
						towardAxis=CVector.CreateOneInstance();
						paths=lineVo.createLoftingPaths(loftingAxis,towardAxis);
						tmpVec=CVector.CreateOneInstance();
						position=CVector.CreateOneInstance();
					}
					subMesh=CMeshUtil.Instance.createLoftingLineByPaths(sourceMesh,sourceMaterial,paths,CVectorUtil.Instance.transformToVector3D(loftingAxis),CVectorUtil.Instance.transformToVector3D(towardAxis));
					subMesh.name=partVo.qName;
					parentMesh.addChild(subMesh);
					loftingAxis.back();
					towardAxis.back();
					tmpVec.back();
					position.back();
					break;
				case CParamDict.PARAM_PANEL_CORNER:
					//创建面板拐角
					if(parentMeshVos) parentMeshVos.push(partVo);
					if(sourceMesh!=null && sourceMesh.Width!=0)
						partVo.width=sourceMesh.Width;
					position=CVector.CreateOneInstance();
					dir=CVector.CreateOneInstance();
					rotaZ=partVo.globalRotation.z;
					partVo.localToGlobal(CVector.ZERO,position);
					CVectorUtil.Instance.calculateDirectionByRotation(rotaZ,dir);
					partVo.qLength*=4;
					partVo.qWidth=partVo.width;
					partVo.qHeight*=4;
					CVector.Scale(dir,partVo.realLength*.5);
					//第一个角
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x-dir.x,position.y-dir.y,position.z-dir.z+partVo.height*.5,0,rotaZ);
					subMesh.name=partVo.qName;
					parentMesh.addChild(subMesh);
					//第二个角
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x+dir.x,position.y+dir.y,position.z+dir.z+partVo.height*.5,90,rotaZ);
					subMesh.name=partVo.qName;
					parentMesh.addChild(subMesh);
					//第三个角
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x+dir.x,position.y+dir.y,position.z+dir.z-partVo.height*.5,180,rotaZ);
					subMesh.name=partVo.qName;
					parentMesh.addChild(subMesh);
					//第四个角
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x-dir.x,position.y-dir.y,position.z-dir.z-partVo.height*.5,-90,rotaZ);
					subMesh.name=partVo.qName;
					parentMesh.addChild(subMesh);
					position.back();
					dir.back();
					break;
				case CParamDict.PARAM_COLUMN_NORMAL:
				case 	CParamDict.PARAM_RECTANGLE_ON_BOTTOM:
				case CParamDict.PARAM_RECTANGLE_BOARD_BACKGROUNDWALL:
				case CParamDict.PARAM_BOARD_NORMAL:
				case CParamDict.PARAM_DRAWER_DOOR:
				case CParamDict.PARAM_CABINE_DOORT_LEFT:
				case CParamDict.PARAM_CABINET_DOOR_RIGHT:
					//创建柱体（带边缘板）
 					if(parentMeshVos) parentMeshVos.push(partVo);
					realLength=partVo.length;
					realHeight=partVo.height;
					rotaZ=partVo.globalRotation.z;
					loftingAxis=CVector.CreateOneInstance();
					towardAxis=CVector.CreateOneInstance();
					paths=partVo.createLoftingPaths(loftingAxis,towardAxis);
					position=CVector.CreateOneInstance();
					if(partVo.parent!=null)
						partVo.localToGlobal(CVector.ZERO,position);
					else
						CVector.Copy(position,partVo.position);
					CMeshUtil.Instance.createBoardMeshBySize(partVo.qName,sourceMaterial,partVo.width,paths,position,parentMesh,rotaZ,partVo.rotationLength,partVo.rotationWidth,partVo.texRotation,true);
					subMesh=parentMesh.getChildAt(0) as Mesh;
					loftingAxis.back();
					towardAxis.back();
					position.back();
					break;
				case CParamDict.OBJECT3D_ADORNMENT_HANDLE:
				case CParamDict.OBJECT3D_DOOR_HANDLE:
					//装饰
					if(parentMeshVos) parentMeshVos.push(object3DVo);
					rotaZ=object3DVo.globalRotation.z;
					CVectorUtil.Instance.calculateDirectionByRotation(rotaZ,object3DVo.direction);
					normal=CVector.CrossValue(object3DVo.direction,CVector.Z_AXIS);
					CVector.Scale(normal,2);
					if(sourceMaterial==null)
					{
						subMesh=(sourceMesh.getChildAt(0) as Mesh);
						sourceMaterial=new TextureMaterial((subMesh.getSurface(0).material as TextureMaterial).diffuseMap);
					}
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,object3DVo.x+normal.x,object3DVo.y+normal.y,object3DVo.z+normal.z,object3DVo.rotationWidth,rotaZ);
					subMesh.name=object3DVo.qName;
					parentMesh.addChild(subMesh);
					normal.back();
					break;
				case CParamDict.PARAM_LINE_INLINE_BACKGROUNDWALL:
					if(parentMeshVos) parentMeshVos.push(partVo);
					if(sourceMesh!=null && sourceMesh.Width!=0)
						partVo.width=sourceMesh.Width;
					wallInlineVo=partVo.parent as CBackgroundWallInlineVO;
					dir=CVector.CreateOneInstance();
					CVectorUtil.Instance.calculateDirectionByRotation(partVo.globalRotation.z,dir);
					towardAxis=CVector.CrossValue(dir,CVector.Z_AXIS);
					var pos:Vector3D;
					var i:int;
					paths=new Vector.<Vector3D>();
					for(i=0; i<wallInlineVo.leftLinePath.size; i++)
					{
						pos=new Vector3D();
						wallInlineVo.leftLinePath.getByIndex(i,pos);
						paths.push(pos);
					}
					subMesh=CMeshUtil.Instance.createLoftingLineByPaths(sourceMesh,sourceMaterial,paths,paths[1].subtract(paths[2]),CVectorUtil.Instance.transformToVector3D(towardAxis));
					subMesh.name="背景墙内框线";
					parentMesh.addChild(subMesh);
					
					paths.length=0;
					for(i=0; i<wallInlineVo.rightLinePath.size; i++)
					{
						pos=new Vector3D();
						wallInlineVo.rightLinePath.getByIndex(i,pos);
						paths.push(pos);
					}
					subMesh=CMeshUtil.Instance.createLoftingLineByPaths(sourceMesh,sourceMaterial,paths,paths[1].subtract(paths[2]),CVectorUtil.Instance.transformToVector3D(towardAxis));
					subMesh.name="背景墙内框线";
					parentMesh.addChild(subMesh);
					
					paths.length=0;
					for(i=0; i<wallInlineVo.rightLinePath.size; i++)
					{
						pos=new Vector3D();
						wallInlineVo.topLinePath.getByIndex(i,pos);
						paths.push(pos);
					}
					subMesh=CMeshUtil.Instance.createLoftingLineByPaths(sourceMesh,sourceMaterial,paths,paths[1].subtract(paths[2]),CVectorUtil.Instance.transformToVector3D(towardAxis));
					subMesh.name="背景墙内框线";
					parentMesh.addChild(subMesh);
					
					dir.back();
					towardAxis.back();
					break;
				case CParamDict.PARAM_CORNER_INLINE_BACKGROUNDWALL:
					//背景墙拐角
					if(parentMeshVos) parentMeshVos.push(partVo);
					wallInlineVo=partVo.parent as CBackgroundWallInlineVO;             
					dir=CVector.CreateOneInstance();
					position=CVector.CreateOneInstance();
					rotaZ=partVo.globalRotation.z;
					CVectorUtil.Instance.calculateDirectionByRotation(rotaZ,dir);
					CVector.Scale(dir,partVo.realLength*.5);
					if(partVo.parent)
						partVo.localToGlobal(CVector.ZERO,position);
					else
						CVector.Copy(position,partVo.position);
					//第一个拐角
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x-dir.x,position.y-dir.y,position.z-dir.z+partVo.realHeight*.5,0,rotaZ);
					subMesh.name=partVo.qName;
					parentMesh.addChild(subMesh);
					//第二个拐角
					CVector.Normalize(dir);
					CVector.Scale(dir,partVo.realLength*.5-wallInlineVo.cornerLength*.5);
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x+dir.x,position.y+dir.y,position.z+dir.z+partVo.realHeight*.5,0,rotaZ,CVector.X_AXIS);
					subMesh.name=partVo.qName;
					parentMesh.addChild(subMesh);
					dir.back();
					position.back();
					break;
				case CParamDict.PARAM_BOTTOM_INLINE_BACKGROUNDWALL:
					if(parentMeshVos) parentMeshVos.push(partVo);
					wallInlineVo=partVo.parent as CBackgroundWallInlineVO;
					rotaZ=partVo.globalRotation.z;
					position=CVector.CreateOneInstance();
					dir=CVector.CreateOneInstance();
					CVectorUtil.Instance.calculateDirectionByRotation(rotaZ,dir);
					CVector.Scale(dir,partVo.realLength*.5+wallInlineVo.bottomLength*.5);
					if(partVo.parent)
						partVo.localToGlobal(CVector.ZERO,position);
					else
						CVector.Copy(position,partVo.position);
					//第一个角
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x-dir.x,position.y-dir.y,position.z-dir.z-partVo.realHeight*.5,0,rotaZ);
					subMesh.name=partVo.qName;
					parentMesh.addChild(subMesh);
					//第二个角
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x+dir.x,position.y+dir.y,position.z+dir.z-partVo.realHeight*.5,0,rotaZ);
					subMesh.name=partVo.qName;
					parentMesh.addChild(subMesh);
					
					dir.back();
					position.back();
					break;
				case CParamDict.PARAM_DOORSETS_BOTTOM:
					if(parentMeshVos) parentMeshVos.push(object3DVo);
					rotaZ=object3DVo.globalRotation.z;
					position=CVector.CreateOneInstance();
					dir=CVector.CreateOneInstance();
					realHeight=object3DVo.realHeight;
					CVectorUtil.Instance.calculateDirectionByRotation(rotaZ,dir);
					CVector.Scale(dir,object3DVo.realLength*.5);
					if(object3DVo.parent)
						object3DVo.localToGlobal(CVector.ZERO,position);
					else
						CVector.Copy(position,object3DVo.position);
					position.z+=realHeight*.5;
					//第一个角
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x-dir.x,position.y-dir.y,position.z-dir.z-object3DVo.realHeight*.5,0,rotaZ);
					subMesh.name=object3DVo.qName;
					parentMesh.addChild(subMesh);
					//第二个角
					subMesh=copyL3DMesh(sourceMesh,sourceMaterial,position.x+dir.x,position.y+dir.y,position.z+dir.z-object3DVo.realHeight*.5,0,rotaZ);
					subMesh.name=object3DVo.qName;
					parentMesh.addChild(subMesh);
					
					dir.back();
					position.back();
					break;
			}
		}
		/**
		 * 复制一个L3D模型  
		 * @param sourceMesh	源模型
		 * @param sourceMaterial	源材质
		 * @param posX	X坐标
		 * @param posY	Y坐标
		 * @param posZ	Z坐标
		 * @param rotationWidth		绕宽度轴的旋转角度
		 * @param rotationHeight	绕高度轴的旋转角度
		 * @param mirrorAxis	镜像轴向量
		 * @return Mesh	返回一个源模型的副本
		 * 
		 */	
		public function copyL3DMesh(sourceMesh:L3DMesh,sourceMaterial:Material,posX:Number,posY:Number,posZ:Number,rotationWidth:Number,rotationHeight:Number,mirrorAxis:CVector=null):Mesh
		{
			var mesh:L3DBuildableMesh = new L3DBuildableMesh();
			mesh.copy(sourceMesh.getChildAt(0) as L3DMesh);
			var parent:L3DMesh=new L3DMesh();
			parent.addChild(mesh);
			if(mirrorAxis)
			{
				CMeshUtil.Instance.mirrorMesh(parent,mirrorAxis);
			}
			var transform:CTransform3D=CGeometry3DUtil.Instance.composeTransform(posX*GlobalConstDict.Scene3DScaleRatio,posY*GlobalConstDict.Scene3DScaleRatio,posZ*GlobalConstDict.Scene3DScaleRatio,
				0,rotationWidth,rotationHeight,GlobalConstDict.Scene3DScaleRatio,GlobalConstDict.Scene3DScaleRatio,GlobalConstDict.Scene3DScaleRatio);
			var matrix3d:Matrix3D=CGeometry3DUtil.Instance.getMatrix3DByTransform3D(transform);
			mesh.applyMatrix(matrix3d);
			parent.removeChild(mesh);
			if(sourceMaterial)
				mesh.setMaterialToAllSurfaces(sourceMaterial);
			return mesh;
		}
	}
}