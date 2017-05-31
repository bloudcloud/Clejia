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
	import kitchenModule.model.vo.CFurnitureVO;
	import kitchenModule.model.vo.CRoomCornerVO;
	
	import main.model.vo.CObject3DVO;
	
	import ns.cloudLib;

	use namespace cloudLib;
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
		
		private function createTableBoardByCornerVo(vo:CRoomCornerVO):void
		{
			var length:Number,width:Number,height:Number,rotation:Number;
			var position:Vector3D;
			if(vo.prevLength>0)
			{
				position=Geometry3DUtil.instance.transformVectorByCTransform3D(vo.startPos,vo.parentInverseTransform);
				length=vo.length;
				width=vo.prevWidth;
				height=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
				rotation=vo.rotation;
				position.x=position.x+length*.5;
				position.y=position.y-width*.5;
				position.z=vo.height+height*.5;
				position=Geometry3DUtil.instance.transformVectorByCTransform3D(position,vo.parentTransform);
				doCreateTableBoard(length,width,height,rotation,position);
			}
			if(vo.nextLength>0)
			{
				
				position=Geometry3DUtil.instance.transformVectorByCTransform3D(vo.endPos,vo.parentInverseTransform);
				if(this.numChildren>0)
				{
					length=vo.nextLength;
				}
				else
				{
					length=vo.width;
				}
				width=vo.nextWidth;
				height=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
				rotation=vo.rotation-90;
				position.x=position.x-width*.5;
				position.y=position.y+length*.5;
				position.z=vo.height+height*.5;
				position=Geometry3DUtil.instance.transformVectorByCTransform3D(position,vo.parentTransform);
				doCreateTableBoard(length,width,height,rotation,position);
			}
		}
		
		private function createTableBoardByFurnitureVo(vo:CFurnitureVO):void
		{
			var height:Number=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
			var position:Vector3D=vo.position.clone();
			position.z+=vo.height+height*.5;
			doCreateTableBoard(vo.length,vo.width,height,vo.rotation,position);
		}
		private function doCreateTableBoard(length:Number,width:Number,height:Number,rotation:Number,position:Vector3D):void
		{
			var mesh:CBox=new CBox(length*.1,width*.1,height*.1);
			mesh.uniqueID=UIDUtil.createUID();
			mesh.userData=new RelatingParams();
			mesh.setMaterialToAllSurfaces(_material);
			
			var vertices:Vector.<Number>=mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var newVertices:Vector.<Number>=new Vector.<Number>(vertices.length);
			var matrix3d:Matrix3D=CMatrix3DUtil.instance.matrix3D;
			matrix3d.appendRotation(rotation,Vector3D.Z_AXIS);
			matrix3d.appendTranslation(position.x*.1,position.y*.1,position.z*.1);
			matrix3d.transformVectors(vertices,newVertices);
			matrix3d.identity();
			
			mesh.geometry.setAttributeValues(VertexAttributes.POSITION,newVertices);
			this.addChild(mesh);
			this.addContent(mesh);
		}
		/**
		 * 创建挡板 
		 * @param vos	一组挡板数据
		 * 
		 */
		public function createTableBoards(vos:Vector.<CObject3DVO>):void
		{
			for each(var vo:CObject3DVO in vos)
			{
				doCreateTableBoard(vo.length,vo.width,vo.height,vo.rotation,vo.position);
//				if(vos[i] is CRoomCornerVO)
//					createTableBoardByCornerVo(vos[i] as CRoomCornerVO);
//				else if(vos[i] is CFurnitureVO)
//					createTableBoardByFurnitureVo(vos[i] as CFurnitureVO);
			}
		}
		override public function dispose():void
		{
			super.dispose();
			_material=null;
		}
	}
}