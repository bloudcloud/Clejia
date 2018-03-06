package kitchenModule.view
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import mx.utils.UIDUtil;
	
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CGeometry3DUtil;
	
	import kitchenModule.model.KitchenGlobalModel;
	import kitchenModule.model.vo.CRoomCornerVO;
	
	import main.model.vo.task.CObject3DVO;
	
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
			var position:CVector;
			if(vo.prevLength>0)
			{
				position=CGeometry3DUtil.Instance.transformVectorByCTransform3D(vo.startPos,vo.parentInverseTransform);
				length=vo.length;
				width=vo.prevWidth;
				height=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
				rotation=vo.rotationHeight;
				position.x=position.x+length*.5;
				position.y=position.y-width*.5;
				position.z=vo.height+height*.5;
				CGeometry3DUtil.Instance.transformVectorByCTransform3D(position,vo.parentTransform,false);
				doCreateTableBoard(length,width,height,rotation,position.x,position.y,position.z);
				position.back();
			}
			if(vo.nextLength>0)
			{
				position=CGeometry3DUtil.Instance.transformVectorByCTransform3D(vo.endPos,vo.parentInverseTransform);
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
				rotation=vo.rotationHeight-90;
				position.x=position.x-width*.5;
				position.y=position.y+length*.5;
				position.z=vo.height+height*.5;
				CGeometry3DUtil.Instance.transformVectorByCTransform3D(position,vo.parentTransform,false);
				doCreateTableBoard(length,width,height,rotation,position.x,position.y,position.z);
				
			}
		}
		
		private function createTableBoardByFurnitureVo(vo:CBaseObject3DVO):void
		{
			var height:Number=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
			vo.position.z+=vo.height+height*.5;
			doCreateTableBoard(vo.length,vo.width,height,vo.rotationHeight,vo.position.x,vo.position.y,vo.position.z);
		}
		private function doCreateTableBoard(length:Number,width:Number,height:Number,rotation:Number,posX:Number,posY:Number,posZ:Number):void
		{
			var mesh:CBox=new CBox(length*.1,width*.1,height*.1);
			mesh.uniqueID=UIDUtil.createUID();
			mesh.userData=new RelatingParams();
			mesh.setMaterialToAllSurfaces(_material);
			
			var vertices:Vector.<Number>=mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var newVertices:Vector.<Number>=new Vector.<Number>(vertices.length);
			var matrix3d:Matrix3D=new Matrix3D();
			matrix3d.appendRotation(rotation,Vector3D.Z_AXIS);
			matrix3d.appendTranslation(posX*.1,posY*.1,posZ*.1);
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
		public function createTableBoards(vos:Vector.<CBaseObject3DVO>):void
		{
			for each(var vo:CObject3DVO in vos)
			{
				doCreateTableBoard(vo.length,vo.width,vo.height,vo.rotationHeight,vo.position.x,vo.position.y,vo.position.z);
			}
		}
		override public function dispose():void
		{
			super.dispose();
			_material=null;
		}
	}
}