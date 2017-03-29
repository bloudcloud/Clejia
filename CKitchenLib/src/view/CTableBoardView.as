package view
{
	import flash.geom.Matrix3D;
	
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.utils.Matrix3DUtil;
	import cloud.core.utils.Vector3DUtil;
	
	import model.vo.CFurnitureVO;

	/**
	 *  台面类
	 * @author cloud
	 */
	public class CTableBoardView extends CBuildFurnitureSet
	{
		private var _material:Material;
		
		public function CTableBoardView()
		{
			super();
			_material=new FillMaterial(0x088000);
		}
		
		public function doCreateTableBoard(vo:CFurnitureVO):void
		{
			var mesh:CBox=new CBox(vo.length*.1,vo.width*.1,vo.height*.1);
			mesh.uniqueID=vo.uniqueID;
			mesh.userData=new Object();
			mesh.setMaterialToAllSurfaces(_material);
			
			var vertices:Vector.<Number>=mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var newVertices:Vector.<Number>=new Vector.<Number>(vertices.length);
			var matrix3d:Matrix3D=Matrix3DUtil.MATRIX3D_UNIT;
			matrix3d.appendRotation(vo.direction,Vector3DUtil.AXIS_Z);
			matrix3d.appendTranslation(vo.position.x*.1,vo.position.y*.1,vo.position.z*.1);
			matrix3d.transformVectors(vertices,newVertices);
			matrix3d.identity();
			
			mesh.geometry.setAttributeValues(VertexAttributes.POSITION,newVertices);
			this.addChild(mesh);
			this.addContent(mesh,vo);
		}
		/**
		 * 创建挡板 
		 * @param vos	一组挡板数据
		 * 
		 */
		public function createTableBoard(vos:Vector.<ICData>):void
		{
			for each(var vo:CFurnitureVO in vos)
			{
				doCreateTableBoard(vo);
			}
		}
		override public function dispose():void
		{
			super.dispose();
			_material=null;
		}
	}
}