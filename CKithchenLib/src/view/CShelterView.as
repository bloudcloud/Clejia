package view
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Plane;
	
	import dic.KitchenGlobalDic;
	
	import flash.geom.Vector3D;
	
	import model.vo.ShelterVO;

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
		
		private function doCreateShelter(vo:ShelterVO):void
		{
			var shelter:CBox=new CBox(vo.length,vo.width,vo.height);
			shelter.name="shelter"+vo.uniqueID;
			shelter.userData=new RelatingParams();
			shelter.setMaterialToAllSurfaces(_material);
			shelter.uniqueID=vo.uniqueID;
			shelter.position=vo.position;
			switch(vo.direction)
			{
				case KitchenGlobalDic.DIR_FRONT:
				case KitchenGlobalDic.DIR_BACK:
					shelter.rotationX=vo.rotation;
					break;
				case KitchenGlobalDic.DIR_LEFT:
				case KitchenGlobalDic.DIR_RIGHT:
					shelter.rotationY=vo.rotation;
					break;
			}
			this.addChild(shelter);
		}
		/**
		 * 创建挡板 
		 * @param vos	一组挡板数据
		 * 
		 */
		public function createShelter(vos:Vector.<ShelterVO>):void
		{
			for each(var vo:ShelterVO in vos)
			{
				doCreateShelter(vo);
			}
		}
		public function deleteShelter():void
		{
			removeChildren();
		}
		/**
		 * 获取所有挡板的id 
		 * @return Vector.<int>
		 * 
		 */		
		public function getShelterIDs():Vector.<String>
		{
			var ids:Vector.<String>=new Vector.<String>();
			var child:Object3D;
			for (var i:int=0; i<this.numChildren; i++)
			{
				child=getChildAt(i);
				if(child is CBox)
				{
					ids.push((child as CBox).uniqueID);
				}
			}
			return ids;
		}
		override public function dispose():void
		{
			_material=null;
		}
	}
}