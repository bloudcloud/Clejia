package core.view
{
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	
	import core.model.GlobalModel;

	/**
	 *  地面可视对象集合类
	 * @author cloud
	 */
	public class FloorViewSet extends BaseFurnitureViewSet
	{
		private var _floor:Mesh;
		
		public function FloorViewSet()
		{
			super();
		}
		public function createFloor(isThin:Boolean,width:uint,length:uint,height:uint=1):void
		{
			if(isThin)
			{
				_floor = new Plane(width,length,1,1,false);
			}
			else
			{
				_floor = new Box(width,length,height);
			}
			_floor.setMaterialToAllSurfaces(new FillMaterial(0x808080));
			addFurnitureView(_floor);
			
		}
		
	}
}