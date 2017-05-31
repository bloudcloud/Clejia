package core.view
{
	import flash.geom.Point;
	
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;

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
		public function createFloor(roundPoints:Array,floorThickness:int):void
		{
			var minX:Number=int.MAX_VALUE,minY:Number=int.MAX_VALUE;
			var maxX:Number=int.MIN_VALUE,maxY:Number=int.MIN_VALUE;
			for each(var pt:Point in roundPoints)
			{
				if(minX>pt.x) minX=pt.x;
				if(minY>pt.y) minY=pt.y;
				if(maxX<pt.x) maxX=pt.x;
				if(maxY<pt.y) maxY=pt.y;
			}
			_floor = new Box(maxX-minX,maxY-minY,floorThickness);
			_floor.x=maxX+minX>>1;
			_floor.y=maxY+minY>>1;
			_floor.setMaterialToAllSurfaces(new FillMaterial(0x808080));
			addFurnitureView(_floor);
			
		}
		
	}
}