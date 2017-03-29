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
	import model.vo.CShelterVO;

	/**
	 *  挡板
	 * @author cloud
	 */
	public class CShelterView extends CBuildFurnitureSet
	{
		protected var _material:Material;
		
		public function CShelterView()
		{
			super();
			_material=new FillMaterial(0x880000);
		}
		
		private function doCreateShelter(vo:CShelterVO):void
		{
			var shelter:CBox=new CBox(vo.length*.1,vo.width*.1,vo.height*.1);
//			shelter.name="shelter"+vo.uniqueID;
			shelter.userData=new Object();
			shelter.setMaterialToAllSurfaces(_material);
			shelter.uniqueID=vo.uniqueID;
			var vertices:Vector.<Number>=shelter.geometry.getAttributeValues(VertexAttributes.POSITION);
			var newVertices:Vector.<Number>=new Vector.<Number>(vertices.length);
			var matrix3d:Matrix3D=Matrix3DUtil.MATRIX3D_UNIT;
			matrix3d.appendRotation(vo.direction,Vector3DUtil.AXIS_Z);
			matrix3d.appendTranslation(vo.position.x*.1,vo.position.y*.1,vo.position.z*.1);
			matrix3d.transformVectors(vertices,newVertices);
			matrix3d.identity();

			shelter.geometry.setAttributeValues(VertexAttributes.POSITION,newVertices);
			this.addChild(shelter);
			this.addContent(shelter,vo);
		}
		/**
		 * 创建挡板 
		 * @param vos	一组挡板数据
		 * 
		 */
		public function createShelter(vos:Vector.<ICData>):void
		{
			for each(var vo:CShelterVO in vos)
			{
				doCreateShelter(vo);
			}
		}

		override public function dispose():void
		{
			super.dispose();
			_material=null;
		}
	}
}