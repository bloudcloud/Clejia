package core.view
{
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.primitives.Box;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.utils.MathUtil;
	
	import main.model.vo.CWallVO;

	/**
	 *  墙体可视对象集合类
	 * @author cloud
	 */
	public class WallViewSet extends BaseFurnitureViewSet
	{
		
		public function WallViewSet()
		{
			super();
		}
		
		public function createWallViews(vos:Vector.<ICData>):void
		{
			var material:FillMaterial=new FillMaterial(0xcccccc);
			var wall:Box;
			for each(var vo:CWallVO in vos)
			{
				wall=new Box(vo.length,vo.width,vo.height,1,1,1,false,material);
				wall.rotationZ=MathUtil.instance.toRadians(vo.rotation);
				wall.x=vo.x;
				wall.y=vo.y;
				wall.z=vo.z;
				addFurnitureView(wall);
			}
		}

	}
}