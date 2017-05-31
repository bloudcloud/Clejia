package kitchenModule.view
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import mx.utils.UIDUtil;
	
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	
	import cloud.core.utils.Geometry3DUtil;
	import cloud.core.utils.CMatrix3DUtil;
	
	import kitchenModule.model.KitchenGlobalModel;
	import kitchenModule.model.vo.CRoomCornerVO;
	
	import main.model.vo.CObject3DVO;
	
	import ns.cloudLib;

	use namespace cloudLib;
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
		
		private function createShelter(vo:CRoomCornerVO):void
		{
			var length:Number,width:Number,height:Number,rotation:Number;
			var position:Vector3D;
			if(vo.prevLength>0)
			{
				position=Geometry3DUtil.instance.transformVectorByCTransform3D(vo.startPos,vo.parentInverseTransform);
				length=vo.prevLength;
				width=KitchenGlobalModel.instance.SHELTER_WIDTH;
				height=position.z*2;
				rotation=vo.rotation;
				position.x=position.x+vo.prevLength*.5;
				position.y=position.y-vo.prevWidth+width*.5;
				position.z=position.z;
				position=Geometry3DUtil.instance.transformVectorByCTransform3D(position,vo.parentTransform);
				doCreateShelter(length,width,height,rotation,position.x,position.y,position.z);
			}
			if(vo.nextLength>0)
			{
				position=Geometry3DUtil.instance.transformVectorByCTransform3D(vo.endPos,vo.parentInverseTransform);
				length=vo.nextLength;
				width=KitchenGlobalModel.instance.SHELTER_WIDTH;
				height=position.z*2;
				rotation=vo.rotation-90;
				position.x=position.x-vo.nextWidth+width*.5;
				position.y=position.y+vo.nextLength*.5;
				position.z=position.z;
				position=Geometry3DUtil.instance.transformVectorByCTransform3D(position,vo.parentTransform);
				doCreateShelter(length,width,height,rotation,position.x,position.y,position.z);
			}
		}
		private function doCreateShelter(length:Number,width:Number,height:Number,rotation:Number,posX:Number,posY:Number,posZ:Number):void
		{
			var shelter:CBox=new CBox(length*.1,width*.1,height*.1);
			shelter.userData=new RelatingParams();
			shelter.setMaterialToAllSurfaces(_material);
			shelter.uniqueID=UIDUtil.createUID();
			var vertices:Vector.<Number>=shelter.geometry.getAttributeValues(VertexAttributes.POSITION);
			var newVertices:Vector.<Number>=new Vector.<Number>(vertices.length);
			var matrix3d:Matrix3D=CMatrix3DUtil.instance.matrix3D;
			matrix3d.appendRotation(rotation,Vector3D.Z_AXIS);
			matrix3d.appendTranslation(posX*.1,posY*.1,posZ*.1);
			matrix3d.transformVectors(vertices,newVertices);
			matrix3d.identity();
			
			shelter.geometry.setAttributeValues(VertexAttributes.POSITION,newVertices);
			this.addChild(shelter);
			this.addContent(shelter);
		}
		/**
		 * 创建挡板 
		 * @param vos	一组挡板数据
		 * 
		 */
		public function createShelters(vos:Vector.<CObject3DVO>):void
		{
			for each(var vo:CObject3DVO in vos)
			{
//				createShelter(vo);
				doCreateShelter(vo.length,vo.width,vo.height,vo.rotation,vo.position.x,vo.position.y,vo.position.z);
			}
		}

		override public function dispose():void
		{
			super.dispose();
			_material=null;
		}
	}
}