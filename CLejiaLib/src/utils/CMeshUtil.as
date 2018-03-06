package utils
{
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.utils.Object3DUtils;
	
	import bearas.geometrytool.GeometryData;
	import bearas.geometrytool.IGeometryVertex;
	import bearas.geometrytool.ProcessPathBoard;
	import bearas.geometrytool.ProcessPathExtrude;
	import bearas.math.Matrix3DUtil;
	import bearas.math.Vector2D;
	
	import cloud.core.datas.base.CTransform3D;
	import cloud.core.datas.base.CVector;
	import cloud.core.utils.CGeometry3DUtil;
	
	import l3dbuild.geometry.L3DGeometryData;
	import l3dbuild.geometry.L3DVertex;
	import l3dbuild.geometry.ProcessHighResTexture;
	import l3dbuild.geometry.ProcessMatterProfileWithYAxis;
	
	import main.dict.CParamDict;
	import main.dict.GlobalConstDict;
	import main.extension.CRectangle;

	/**
	 * 装修模块工具类
	 * @author cloud
	 */
	public class CMeshUtil
	{
		private static var _Instance:CMeshUtil;
		public static function get Instance():CMeshUtil
		{
			return _Instance ||= new CMeshUtil(new SingletonEnforce());
		}
		
		private const _curTexTransform:CTransform3D=new CTransform3D();
		private var _curTexRotation:Number=0;
		
		protected function set curTexRotation(value:Number):void
		{
			if(_curTexRotation!=value)
			{
				CTransform3D.Compose(_curTexTransform,0,0,value,1,1,1,0,0,0);
			}
			_curTexRotation=value;
		}
		public function CMeshUtil(enforcer:SingletonEnforce)
		{
		}
		
		private function setWaistUV(vertex:IGeometryVertex,pos:Vector3D,dir:Vector3D):void
		{
			var v:L3DVertex = vertex as  L3DVertex;
			var length:Number = pos.subtract(v.position).dotProduct(dir);
			v.texcord0.y += length/(100*GlobalConstDict.Scene3DScaleRatio);
			v.texcord1.y += length/(100*GlobalConstDict.Scene3DScaleRatio);
//			v.texcord0.y += length/(100);
//			v.texcord1.y += length/(100);
		}
		private function createLoftingMeshGeometry(source:L3DMesh,paths:Vector.<Vector3D>,loftingAxis:Vector3D,towardAxis:Vector3D,mirrorAxis:Vector3D,testMesh:Mesh=null):GeometryData
		{
//			CDebug.instance.traceStr(toward.toString());
//			DrawVector(mesh,path[0],path[0].add(vmul(toward,50)),new Vector3D(0,0,1),4,new Vector2D(5,3),0xffbb00);
			var subSourceMesh:Mesh=source.getChildAt(0) as Mesh;
			var go:L3DGeometryData = new L3DGeometryData();
			go.readFromMesh(subSourceMesh);
			var outline:L3DGeometryData = new L3DGeometryData();
			ProcessMatterProfileWithYAxis(outline,go);
//			if(mirrorAxis)
//				outline.mirror(mirrorAxis);
			const scale:Number=GlobalConstDict.Scene3DScaleRatio;
			for each(var path:Vector3D in paths)
			{
				path.scaleBy(GlobalConstDict.Scene3DScaleRatio);
			}
			//修正坐标
			var mat:Matrix3D;
			mat=Matrix3DUtil.fromToMatrix(new Matrix3D(),Matrix3DUtil.createMatrix(loftingAxis,towardAxis));
			mat.appendScale(scale,scale,scale);
			mat.appendTranslation(paths[1].x,paths[1].y,paths[1].z);
//			var dir:Vector3D=loftingAxis.crossProduct(towardAxis);
//			dir.normalize();
//			dir.scaleBy(source.Height*.5*scale);
//			mat.appendTranslation(paths[1].x-dir.x,paths[1].y-dir.y,paths[1].z-dir.z);
//			towardAxis.normalize();
//			towardAxis.scaleBy(source.Width*.5);
//			mat.appendTranslation(towardAxis.x,towardAxis.y,towardAxis.z);
			outline.applyMatrix(mat);
			//开始放样
			var finalgo:L3DGeometryData = new L3DGeometryData();
			ProcessPathExtrude(finalgo,outline,paths,setWaistUV);
			finalgo.lines.length = 0;
			return finalgo;
		}
		/**
		 * 沿着路径放样一个模型 
		 * @param sourceMesh
		 * @param sourceMaterial
		 * @param path
		 * @param toward
		 * @param testMesh
		 * @param isHighResTexture
		 * @return Mesh
		 * 
		 */			
		public function createLoftingLineByPaths(sourceMesh:L3DMesh,sourceMaterial:Material,path:Vector.<Vector3D>,loftingAxis:Vector3D,towardAxis:Vector3D,mirrorAxis:Vector3D=null,testMesh:Mesh=null,isHighResTexture:Boolean=true):Mesh
		{
			//创建放样模型网格信息
			var geo:L3DGeometryData;
			var subMesh:Mesh;
			//修正位置
			geo=createLoftingMeshGeometry(sourceMesh,path,loftingAxis,towardAxis,mirrorAxis,testMesh) as L3DGeometryData;
			
			if(isHighResTexture)
				ProcessHighResTexture(geo,4);
			//创建模型
			subMesh=new Mesh();
			geo.writeToMesh(subMesh,sourceMaterial);
			subMesh.userData=new RelatingParams();
			return subMesh;
		}
		private function travelFunctionFace(iVertex:IGeometryVertex,pos:Vector3D,dir0:Vector3D,dir1:Vector3D):void{
			var vertex:L3DVertex = iVertex as  L3DVertex;
			var ab:Vector3D = pos.subtract(vertex.position);
			var u:Number=ab.dotProduct(dir0)/(100/GlobalConstDict.Scene3DScaleRatio);
			var v:Number=ab.dotProduct(dir1)/(100/GlobalConstDict.Scene3DScaleRatio);
			if(_curTexRotation!=0)
			{
				ab.setTo(u*_curTexTransform.a+v*_curTexTransform.b+_curTexTransform.d,
					u*_curTexTransform.e+v*_curTexTransform.f+_curTexTransform.h,
					0);
				u=ab.x;
				v=ab.y;
			}
			vertex.texcord0.x += u;
			vertex.texcord1.x += u;
			vertex.texcord0.y -= v;
			vertex.texcord1.y -= v;
		}
		
		private function travelFunctionX(vertex:IGeometryVertex,pos:Vector3D,dir:Vector3D):void{
			var v:L3DVertex = vertex as  L3DVertex;
			var length:Number = pos.subtract(v.position).dotProduct(dir);
			v.texcord0.x += length/(100/GlobalConstDict.Scene3DScaleRatio);
			v.texcord1.x += length/(100/GlobalConstDict.Scene3DScaleRatio);
//			v.texcord0.x += length/(100);
//			v.texcord1.x += length/(100);
		}
		
		private function travelFunctionY(vertex:IGeometryVertex,pos:Vector3D,dir:Vector3D):void{
			var v:L3DVertex = vertex as  L3DVertex;
			var length:Number = pos.subtract(v.position).dotProduct(dir);
			v.texcord0.y -= length/(100/GlobalConstDict.Scene3DScaleRatio);
			v.texcord1.y -= length/(100/GlobalConstDict.Scene3DScaleRatio);
//			v.texcord0.y -= length/(100);
//			v.texcord1.y -= length/(100);
		}
		/**
		 *  创建一个立方体模型对象
		 * @param name	名字
		 * @param material	
		 * @param thickness	厚度
		 * @param paths	
		 * @param position	
		 * @param rotation	
		 * @param texRotation 
		 * @param parentMesh	父模型容器
		 * @param hasBoarder		是否有边框  
		 * @param name	名字
		 * @param material	材质
		 * @param thickness		厚度
		 * @param paths	立方体表面围点路径
		 * @param position	中心点位置
		 * @param parentMesh	父模型容器
		 * @param rotation	以高度方向为轴的旋转角度
		 * @param rotationLength	以长度方向为轴的旋转角度
		 * @param rotationWidth	以厚度方向为轴的旋转角度
		 * @param texRotation	纹理旋转角度
		 * @param hasBoarder	是否有边缘面
		 * 
		 */					
		public function createBoardMeshBySize(name:String,material:Material,thickness:Number,paths:Vector.<Vector3D>,position:CVector,parentMesh:Mesh,rotation:Number,rotationLength:Number=0,rotationWidth:Number=0,texRotation:Number=0,hasBoarder:Boolean=false):void
		{
			curTexRotation=texRotation;
			var matrix:Matrix3D;
			var faceGeometry:L3DGeometryData = new L3DGeometryData();
			var boarderGeometry:L3DGeometryData = new L3DGeometryData();
			ProcessPathBoard(faceGeometry,boarderGeometry,paths,new Vector3D(0,-1,0),new Vector2D(0,thickness),travelFunctionFace,travelFunctionX,travelFunctionY);
			var transform:CTransform3D=CGeometry3DUtil.Instance.composeTransform(
				position.x*GlobalConstDict.Scene3DScaleRatio
				,position.y*GlobalConstDict.Scene3DScaleRatio
				,position.z*GlobalConstDict.Scene3DScaleRatio
				,rotationLength,rotationWidth,rotation
//				,1,1,1);
				,GlobalConstDict.Scene3DScaleRatio,GlobalConstDict.Scene3DScaleRatio,GlobalConstDict.Scene3DScaleRatio);
			matrix=CGeometry3DUtil.Instance.getMatrix3DByTransform3D(transform);
//			faceGeometry.applyScale(new Vector3D(GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO));
			faceGeometry.applyMatrix(matrix);
			var mesh:Mesh;
			mesh = new Mesh();
			mesh.name=name;
			faceGeometry.writeToMesh(mesh,material);
			parentMesh.addChild(mesh);
			mesh.userData=new RelatingParams();
			if(hasBoarder)
			{
				transform=CGeometry3DUtil.Instance.composeTransform(position.x*GlobalConstDict.Scene3DScaleRatio,position.y*GlobalConstDict.Scene3DScaleRatio,position.z*GlobalConstDict.Scene3DScaleRatio
					,rotationLength,rotationWidth,rotation
					,GlobalConstDict.Scene3DScaleRatio,GlobalConstDict.Scene3DScaleRatio,GlobalConstDict.Scene3DScaleRatio);
				matrix=CGeometry3DUtil.Instance.getMatrix3DByTransform3D(transform);
//				faceGeometry.applyScale(new Vector3D(GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO));
				boarderGeometry.applyMatrix(matrix);
				mesh=new Mesh();
				mesh.name=name+"boarder";
//				ProcessHighResTexture(boarderGeometry,4);
				boarderGeometry.writeToMesh(mesh,material);
				parentMesh.addChild(mesh);
				mesh.userData=new RelatingParams();
			}
			
		}
		private function sortRectangle(a:Rectangle,b:Rectangle):int
		{
			if(a.x>b.x)
				return 1;
			else if(a.x==b.x)
			{
				if(a.y>b.y)
					return 1;
				else 
					return -1;
			}
			else 
				return -1;
		}
		private function doCreateRoundPoints(startX:Number,startY:Number,length:Number,height:Number):Array
		{
			var roundPoints:Array=new Array();
			roundPoints.push(
				new Vector3D(startX,startY+height),
				new Vector3D(startX+length,startY+height),
				new Vector3D(startX+length,startY),
				new Vector3D(startX,startY)
			);
			return roundPoints;
		}
		/**
		 * 根据区域门窗洞数据集合，获取墙的区域围点数据集合 
		 * @param holes	门窗洞数据集合
		 * @param wallLength	墙的长度
		 * @param wallHeight	墙的高度
		 * @param limit		区域限制（小于该值得区域忽略）
		 * @param isIncludeHole	是否返回门窗洞区域围点
		 * @return Array
		 * 
		 */			
		public function getWallAllRegionRoundPointsByholes(holes:Array,wallLength:Number,wallHeight:Number,limit:int=10,isIncludeHole:Boolean=false):Array
		{ 
			var maxX:Number=int.MIN_VALUE,maxY:Number=int.MIN_VALUE,minX:Number=int.MAX_VALUE,minY:Number=int.MAX_VALUE;
			var rectangles:Vector.<Rectangle>=new Vector.<Rectangle>();
			var len:int=0;
			//创建区域
			var regions:Array=new Array();
			var points:Array;
			if(holes==null || holes.length==0)
			{
				regions.push(doCreateRoundPoints(0,0,wallLength,wallHeight));
				return regions;
			}
			for(var i:int=0; i<holes.length; i++)
			{
				points=holes[i].points;
				for(var j:int=0; j<points.length; j++)
				{
					if(maxX<points[j].x) maxX=points[j].x;
					if(maxY<points[j].y) maxY=points[j].y;
					if(minX>points[j].x) minX=points[j].x;
					if(minY>points[j].y) minY=points[j].y;
				}
				rectangles.push(new Rectangle(minX,minY,maxX-minX,maxY-minY));
				maxX=maxY=int.MIN_VALUE;
				minX=minY=int.MAX_VALUE;
			}
			rectangles.sort(sortRectangle);
			//
			var prevX:Number=0;
			len=rectangles.length;
			if(len==0)
			{
				regions.push(doCreateRoundPoints(0,0,wallLength,wallHeight));
			}
			else
			{
				prevX=0;
				for(i=0; i<len; i++)
				{
					if(i==0)
					{
						prevX=0;
					}
					else
					{
						prevX=rectangles[i-1].x+rectangles[i-1].width;
					}
					if(rectangles[i].x-prevX>0.001)
					{
						if(rectangles[i].x-prevX>limit && wallHeight>limit)
						{
							regions.push(doCreateRoundPoints(prevX,0,rectangles[i].x-prevX,wallHeight));
						}
					}
					if(rectangles[i].y-0<0.001)
					{
						//门窗区域在顶部
						if(rectangles[i].width>limit && wallHeight-rectangles[i].height>limit)
						{
							regions.push(doCreateRoundPoints(rectangles[i].x,rectangles[i].y+rectangles[i].height,rectangles[i].width,wallHeight-rectangles[i].height));
						}
					}
					else if(wallHeight-(rectangles[i].y+rectangles[i].height)<0.001)
					{
						//门窗区域在底部
						if(rectangles[i].width>limit && wallHeight-rectangles[i].height>limit)
						{
							regions.push(doCreateRoundPoints(rectangles[i].x,0,rectangles[i].width,wallHeight-rectangles[i].height));	
						}
					}
					else
					{
						//门窗区域在中间
						if(rectangles[i].width>limit && rectangles[i].y-0>limit)
						{
							regions.push(doCreateRoundPoints(rectangles[i].x,0,rectangles[i].width,rectangles[i].y-0));
						}
						if(rectangles[i].width>limit && wallHeight-(rectangles[i].y+rectangles[i].height)>limit)
						{
							regions.push(doCreateRoundPoints(rectangles[i].x,rectangles[i].y+rectangles[i].height,rectangles[i].width,wallHeight-(rectangles[i].y+rectangles[i].height)));	
						}
					}
					if(isIncludeHole)
					{
						//生成门窗洞区域
						if(rectangles[i].width>limit && rectangles[i].height>limit)
						{
							regions.push(doCreateRoundPoints(rectangles[i].x,rectangles[i].y,rectangles[i].width,rectangles[i].height));	
						}
					}
				}
				prevX=rectangles[len-1].x+rectangles[len-1].width;
				if(wallLength-prevX>0.001)
				{
					if(wallLength-prevX>limit && wallHeight>limit)
					{
						regions.push(doCreateRoundPoints(prevX,0,wallLength-prevX,wallHeight));
					}
				}
			}
			return regions;
		}
		/**
		 *	根据Point围点,判断当前模型对象是否是要查找的目标墙 
		 * @param mesh	当前的模型对象
		 * @param pointA	围点A
		 * @param pointB	围点B
		 * @return Boolean
		 * 
		 */		
		public function searchWallMeshByPointAB(mesh:Mesh,pointA:Point,pointB:Point):Boolean
		{
			if(mesh==null || mesh is L3DMesh || mesh.name != "wall_in")	return false;
			mesh.boundBox ||= Object3DUtils.calculateHierarchyBoundBox(mesh);
			var centerX:Number=(mesh.boundBox.minX + mesh.boundBox.maxX) *.5;
			var centerY:Number=(mesh.boundBox.minY + mesh.boundBox.maxY) *.5;
			return centerX==(pointA.x+pointB.x)*.5 && centerY==(pointA.y+pointB.y)*.5;
		}
		/**
		 * 遍历XMLList所有节点,删除嵌板等面板类型的节点 
		 * @param xmlList
		 * 
		 */		
		private function loopXMLtoDeleteBoard(xmlList:XMLList):void
		{
			var paramType:uint;
			for(var i:int=0; i<xmlList.length();)
			{
				paramType=CParamDict.Instance.getParamType(CParamDict.Instance.getTypeByString(xmlList[i].@type));
				switch(paramType)
				{
					case CParamDict.PARAM_UNIT_BOARD:
//					case CParamDict.PARAM_RECTANGLE_CORNER:
						delete xmlList[i];
						break;
					default:
						i++;
						break;
				}
			}
		}
		/**
		 * 遍历XMLList所有节点,更新属性
		 * @param xml	XMLList对象
		 * @param newLength 需要更新的新长度
		 * 
		 */		
		private function loopXMLtoChangeProperties(xmlList:XMLList,oldScale:Number,newScale:Number):void
		{
			if(oldScale==newScale) return;
			var length:Number;
			var len:int=xmlList.length();
			for(var i:int=0; i<len; i++)
			{
				length=Number(xmlList[i].@length/oldScale);
				if(length!=0)
				{
					xmlList[i].@length=(length*newScale).toString();
				}
				if(xmlList[i].children().length()>0)
				{
					loopXMLtoChangeProperties(xmlList.children(),oldScale,newScale);
				}
			}
		}
		private function loopXMLtoChangeContent(xmlList:XMLList,unitLength:Number,regionRect:CRectangle,partRect:CRectangle):void
		{
			var rectX:Number,rectY:Number,partLength:Number,partHeight:Number;
			var intersectRect:Rectangle;
			for(var i:int=0; i<xmlList.length();)
			{
				partLength=Number(xmlList[i].@length);
				partHeight=Number(xmlList[i].@height);
				rectX=(unitLength-partLength)*.5;
				rectY=regionRect.height-Number(xmlList[i].@offGround)-partHeight;
				partRect.setTo(rectX,rectY,partLength,partHeight);
				intersectRect=partRect.intersection(regionRect);
				if(intersectRect==null || intersectRect.width!=partRect.width || intersectRect.height!=partRect.height)
				{
					delete xmlList[i];
				}
				else
				{
					i++;
				}
			}
		}
		/**
		 * 更新护墙板单元件 
		 * @param xml	单元件XML数据
		 * @param regionVo	区域数据对象
		 * @param regionPoints	区域围点数据集合
		 * 
		 */		
		private function doUpdateClapboardUnitVo(xml:XML,regionVo:Object,regionPoints:Array):void
		{
			var xmlList:XMLList;
			var regionLength:Number;
			var regionHeight:Number;
			var regionRect:CRectangle;
			var partRect:CRectangle;
			var sourceLength:Number;
			var unitNum:int;
			var randNum:int;
			var newScaleX:Number;
			var newScaleY:Number;
			
			regionLength=L3DUtils.AmendInt(regionPoints[1].x-regionPoints[0].x);
			regionHeight=L3DUtils.AmendInt(regionPoints[1].y-regionPoints[2].y);
			sourceLength=L3DUtils.AmendInt(Number(xml.@length)/regionVo.scaleX);
			unitNum=regionLength/sourceLength;
			randNum=regionLength % sourceLength;
			if(unitNum==0) unitNum=1;
			switch(regionVo.mode)
			{
				case CParamDict.TILING_DECREASE:
					if(randNum>0) unitNum++;
					newScaleX=regionLength/unitNum/sourceLength;
					break;
				case CParamDict.TILING_INCREASE:
					newScaleX=regionLength/unitNum/sourceLength;
					break;
				case CParamDict.TILING_NORMAL:
					newScaleX=1;
					break;
				default:
					newScaleX=1;
					break;
			}
			//修改xml
			if(newScaleX!=regionVo.scaleX)
			{
				xml.@length=String(sourceLength*newScaleX);
				xmlList=xml.children();
				if(newScaleX<0.33)
				{
					//过窄，删除所有的嵌板
					loopXMLtoDeleteBoard(xmlList);
				}
				if(xmlList.length()>0)
				{
					loopXMLtoChangeProperties(xmlList,regionVo.scaleX,newScaleX);
				}
				if(regionHeight<GlobalConstDict.ROOM_HEIGHT)
				{
					//非整墙高度的区域,删除区域外的部件
					regionRect=new CRectangle(0,regionPoints[3].y,regionLength,regionHeight);
					partRect=new CRectangle();
					loopXMLtoChangeContent(xmlList,sourceLength*newScaleX,regionRect,partRect);
				}
			}
			//更新缩放值
			regionVo.scaleX=newScaleX;
		}
		/**
		 * 更新XML源数据 
		 * @param xmlSource
		 * @param regionPoints
		 * 
		 */		
		public function updateClapboardPlanSourceData(sourceData:Object,regionPoints:Array):void
		{
			var xmlList:XMLList;
			var len:int;
			xmlList=sourceData.xml.children();
			len=xmlList.length();
			for(var i:int=0; i<len; i++)
			{
				doUpdateClapboardUnitVo(xmlList[i],sourceData,regionPoints);
			}
		}
	
		/**
		 * 获取 
		 * @param mesh
		 * @return Array
		 * 
		 */		
		public function getMeshProfilePath(mesh:Mesh):Array
		{
			var paths:Array=[];
			var go:L3DGeometryData = new L3DGeometryData();
			go.readFromMesh(mesh);
			var outline:L3DGeometryData = new L3DGeometryData();
			ProcessMatterProfileWithYAxis(outline,go);
			return paths;
		}
		/**
		 * 镜像坐标点集合容器 
		 * @param sourceContainer	源坐标点容器对象
		 * @param mirrorOrigin	 镜像的原点
		 * @param mirrorAixs	镜像的改变轴方向
		 * @return Vector.<Number>
		 * 
		 */		
		public function mirrorPositionContainer(sourceContainer:*,mirrorOrigin:CVector,mirrorAixs:CVector,isNew:Boolean=false):Vector.<Number>
		{
			var vertices:Vector.<Number>;
			if(sourceContainer is Vector.<Number>)
			{
				var count:uint = sourceContainer.length;
				vertices= isNew ? (sourceContainer as Vector.<Number>).concat() : sourceContainer;
				for (var j:uint = 0; j < count; j += 3)
				{
					var x:Number = vertices[j];
					var y:Number = vertices[j+1];
					var z:Number = vertices[j+2];
					switch(mirrorAixs)
					{
						case CVector.X_AXIS:
						{
							vertices[j] = mirrorOrigin.x - x;
							vertices[j+1] = y;
							vertices[j+2] = z;
						}
							break;
						case CVector.Y_AXIS:
						{
							vertices[j] = x;
							vertices[j+1] = mirrorOrigin.y - y;
							vertices[j+2] = z;
						}
							break;
						case CVector.Z_AXIS:
						{
							vertices[j] = x;
							vertices[j+1] = y;
							vertices[j+2] = mirrorOrigin.z - z;
						}
							break;
					}
				}
			}
			return vertices;
		}
		/**
		 * 镜像模型 
		 * @param mesh
		 * @param axis
		 * 
		 */			
		public function mirrorMesh(mesh:Mesh,axis:CVector):void
		{
			var mirrorPosition:CVector=CVector.CreateOneInstance();
			var boundBox:BoundBox;
			if(mesh.boundBox == null)
			{
				mesh.boundBox = Object3DUtils.calculateHierarchyBoundBox(mesh);
			}		
			boundBox=mesh.boundBox;
			CVector.SetTo(mirrorPosition,(boundBox.maxX + boundBox.minX)*.5,(boundBox.maxY + boundBox.minY)*.5,(boundBox.maxZ + boundBox.minZ)*.5);
			var count:int;
			for (var i:int = 0; i < mesh.numChildren; i++)
			{
				var subset:Object3D = mesh.getChildAt(i);
				if(subset is Mesh)
				{
					var mesh:Mesh = Mesh(subset);
					if(mesh.geometry == null)
						continue;
					var vertices:Vector.<Number>=mirrorPositionContainer(mesh.geometry.getAttributeValues(VertexAttributes.POSITION),mirrorPosition,axis);
					mesh.geometry.setAttributeValues(VertexAttributes.POSITION, vertices);					
					var indices:Vector.<uint> = mesh.geometry.indices;
					count = indices.length;
					var invertIndices:Vector.<uint> = new Vector.<uint>();
					for (var k:uint = 0; k < count; k ++)
					{
						invertIndices.push(indices[count - 1 - k]);
					}
					mesh.geometry.indices = invertIndices;
				}
			}
		}
	}
}