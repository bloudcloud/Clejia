package utils
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	
	import bearas.geometrytool.GeometryData;
	import bearas.geometrytool.IGeometryVertex;
	import bearas.math.Matrix3DUtil;
	import bearas.math.Vector2D;
	
	import cloud.core.dataStruct.CTransform3D;
	import cloud.core.singleton.CVector3DUtil;
	import cloud.core.utils.Geometry3DUtil;
	
	import l3dbuild.geometry.L3DGeometryData;
	import l3dbuild.geometry.L3DVertex;
	import l3dbuild.geometry.ProcessHighResTexture;
	import l3dbuild.geometry.ProcessMatterProfileWithYAxis;
	import l3dbuild.geometry.ProcessPathBoard;
	import l3dbuild.geometry.ProcessPathExtrude;
	
	import main.dict.GlobalConstDict;

	/**
	 * 
	 * @author cloud
	 */
	public class CDecorationMeshUtil
	{
		private static var _instance:CDecorationMeshUtil;
		public static function get instance():CDecorationMeshUtil
		{
			return _instance ||= new CDecorationMeshUtil();
		}
		
		public function CDecorationMeshUtil()
		{
		}
		
		private function setWaistUV(vertex:IGeometryVertex,pos:Vector3D,dir:Vector3D):void
		{
			var v:L3DVertex = vertex as  L3DVertex;
			var length:Number = pos.subtract(v.position).dotProduct(dir);
			v.texcord0.y += length/(100*GlobalConstDict.SCENE3D_SCALERATIO);
			v.texcord1.y += length/(100*GlobalConstDict.SCENE3D_SCALERATIO);
//			v.texcord0.y += length/(100);
//			v.texcord1.y += length/(100);
		}
		private function createLoftingMeshGeometry(source:L3DMesh,paths:Vector.<Vector3D>,toward:Vector3D,testMesh:Mesh=null):GeometryData
		{
//			CDebug.instance.traceStr(toward.toString());
//			DrawVector(mesh,path[0],path[0].add(vmul(toward,50)),new Vector3D(0,0,1),4,new Vector2D(5,3),0xffbb00);
			var subSourceMesh:Mesh=source.getChildAt(0) as Mesh;
			var go:L3DGeometryData = new L3DGeometryData();
			go.readFromMesh(subSourceMesh);
			
			var outline:L3DGeometryData = new L3DGeometryData();
			ProcessMatterProfileWithYAxis(outline,go);
			
			for each(var path:Vector3D in paths)
			{
				path.scaleBy(GlobalConstDict.SCENE3D_SCALERATIO);
			}
			//修正坐标
//			var sizeVec:Vector3D=outline.getBounds().size;
//			trace("size:",sizeVec);
//			sizeVec.scaleBy(.5*GlobalConstDict.SCENE3D_SCALERATIO);
//			toward.normalize();
//			var dir:Vector3D=paths[1].subtract(paths[2]);
//			dir.normalize();
			var mat:Matrix3D = Matrix3DUtil.fromToMatrix(new Matrix3D(),Matrix3DUtil.createMatrix(paths[1].subtract(paths[2]),toward));
			mat.appendScale(GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO);
			mat.appendTranslation(paths[1].x,paths[1].y,paths[1].z);
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
		public function createLoftingLineByPaths(sourceMesh:L3DMesh,sourceMaterial:Material,path:Vector.<Vector3D>,toward:Vector3D,testMesh:Mesh=null,isHighResTexture:Boolean=true):Mesh
		{
			//创建放样模型网格信息
			var geo:L3DGeometryData;
			var subMesh:Mesh;
			//修正位置
			geo=createLoftingMeshGeometry(sourceMesh,path,toward,testMesh) as L3DGeometryData;
			if(isHighResTexture)
				ProcessHighResTexture(geo,4);
			//创建模型
			subMesh=new Mesh();
			geo.writeToMesh(subMesh,sourceMaterial);
			subMesh.userData=new RelatingParams();
			return subMesh;
		}
		
		private function travelFunctionFace(vertex:IGeometryVertex,pos:Vector3D,dir0:Vector3D,dir1:Vector3D):void{
			var v:L3DVertex = vertex as  L3DVertex;
			var ab:Vector3D = pos.subtract(v.position);
//			v.texcord0.x += ab.dotProduct(dir0)/(1000/GlobalConstDict.SCENE3D_SCALERATIO);
//			v.texcord1.x += ab.dotProduct(dir0)/(1000/GlobalConstDict.SCENE3D_SCALERATIO);
//			v.texcord0.y -= ab.dotProduct(dir1)/(1000/GlobalConstDict.SCENE3D_SCALERATIO);
//			v.texcord1.y -= ab.dotProduct(dir1)/(1000/GlobalConstDict.SCENE3D_SCALERATIO);
			v.texcord0.x += ab.dotProduct(dir0)/(1000);
			v.texcord1.x += ab.dotProduct(dir0)/(1000);
			v.texcord0.y -= ab.dotProduct(dir1)/(1000);
			v.texcord1.y -= ab.dotProduct(dir1)/(1000);
		}
		
		private function travelFunctionX(vertex:IGeometryVertex,pos:Vector3D,dir:Vector3D):void{
			var v:L3DVertex = vertex as  L3DVertex;
			var length:Number = pos.subtract(v.position).dotProduct(dir);
			v.texcord0.x += length/(100*GlobalConstDict.SCENE3D_SCALERATIO);
			v.texcord1.x += length/(100*GlobalConstDict.SCENE3D_SCALERATIO);
//			v.texcord0.x += length/(100);
//			v.texcord1.x += length/(100);
		}
		
		private function travelFunctionY(vertex:IGeometryVertex,pos:Vector3D,dir:Vector3D):void{
			var v:L3DVertex = vertex as  L3DVertex;
			var length:Number = pos.subtract(v.position).dotProduct(dir);
			v.texcord0.y -= length/(100*GlobalConstDict.SCENE3D_SCALERATIO);
			v.texcord1.y -= length/(100*GlobalConstDict.SCENE3D_SCALERATIO);
//			v.texcord0.y -= length/(100);
//			v.texcord1.y -= length/(100);
		}
		/**
		 * 创建一块板材模型 
		 * @param material	材质
		 * @param length	长度
		 * @param width	厚度
		 * @param height	高度
		 * @param position	中心点位置
		 * @param rotation	旋转角度
		 * @param parentMesh	父模型容器
		 * @param hasBoarder		是否有边框
		 * 
		 */			
		public function createBoardMeshBySize(name:String,material:Material,length:Number,width:Number,height:Number,position:Vector3D,direction:Vector3D,rotation:Number,parentMesh:Mesh,hasBoarder:Boolean=true):void
		{
			var path:Vector.<Vector3D> = new Vector.<Vector3D>();
			var halfLength:Number=length*.5;
			var halfHeight:Number=height*.5;
			var thickness:Number=width;
			var matrix:Matrix3D;
			path.push(new Vector3D(-halfLength,0,-halfHeight),new Vector3D(halfLength,0,-halfHeight),new Vector3D(halfLength,0,halfHeight),new Vector3D(-halfLength,0,halfHeight));
			
			var faceGeometry:L3DGeometryData = new L3DGeometryData();
			var boarderGeometry:L3DGeometryData = new L3DGeometryData();
			ProcessPathBoard(faceGeometry,boarderGeometry,path,CVector3DUtil.NEGATIVE_Y_AXIS,new Vector2D(0,thickness),travelFunctionFace,travelFunctionX,travelFunctionY);
			var transform:CTransform3D=Geometry3DUtil.instance.composeTransform(position.x*GlobalConstDict.SCENE3D_SCALERATIO,position.y*GlobalConstDict.SCENE3D_SCALERATIO,position.z*GlobalConstDict.SCENE3D_SCALERATIO
				,0,0,rotation
				,GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO);
			matrix=Geometry3DUtil.instance.getMatrix3DByTransform3D(transform);
			faceGeometry.applyMatrix(matrix);
			var mesh:Mesh;
			mesh = new Mesh();
			mesh.name=name;
			faceGeometry.writeToMesh(mesh,material);
			parentMesh.addChild(mesh);
			mesh.userData=new RelatingParams();
			if(hasBoarder)
			{
				transform=Geometry3DUtil.instance.composeTransform(position.x*GlobalConstDict.SCENE3D_SCALERATIO,position.y*GlobalConstDict.SCENE3D_SCALERATIO,position.z*GlobalConstDict.SCENE3D_SCALERATIO
					,0,0,rotation
					,GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO);
				matrix=Geometry3DUtil.instance.getMatrix3DByTransform3D(transform);
				boarderGeometry.applyMatrix(matrix);
				mesh=new Mesh();
				mesh.name=name+"boarder";
//				ProcessHighResTexture(boarderGeometry,4);
				boarderGeometry.writeToMesh(mesh,material);
				parentMesh.addChild(mesh);
				mesh.userData=new RelatingParams();
			}
			
		}
	}
}