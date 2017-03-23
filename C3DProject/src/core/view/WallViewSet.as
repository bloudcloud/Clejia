package core.view
{
	import flash.geom.Vector3D;
	
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	
	import cloud.core.utils.MathUtil;

	/**
	 *  墙体可视对象集合类
	 * @author cloud
	 */
	public class WallViewSet extends BaseFurnitureViewSet
	{
		private var _fwall:Mesh;
		private var _lwall:Mesh;
		private var _rwall:Mesh;
		/**
		 * 顶部左上角位置 
		 */		
		public var leftUpPos:Vector3D=new Vector3D();
		/**
		 * 顶部左下角位置
		 */		
		public var leftDownPos:Vector3D=new Vector3D();
		/**
		 * 顶部右上角位置 
		 */		
		public var rightUpPos:Vector3D=new Vector3D();
		/**
		 * 顶部右下角位置 
		 */		
		public var rightDownPos:Vector3D=new Vector3D();
		
		public function WallViewSet()
		{
			super();
		}
		
		public function createWall(isThin:Boolean,width:uint,length:uint,height:uint=1):void
		{
			var material:FillMaterial=new FillMaterial(0xcccccc);
			var wall:Mesh;
			if(isThin)
			{
				_fwall=new Plane(width,length,1,1,false);
				_lwall=new Plane(width,length,1,1,false);
				_rwall=new Plane(width,length,1,1,false);
			}
			else
			{
				_fwall=new Box(width,length,height);
				_lwall=new Box(width,length,height);
				_rwall=new Box(width,length,height);
			}
			_fwall.rotationX=MathUtil.toRadians(90);
			_lwall.rotationY=MathUtil.toRadians(90);
			_rwall.rotationY=MathUtil.toRadians(-90);
//			_fwall.userData=KitchenGlobalDic.DIR_BACK;
//			_lwall.userData=KitchenGlobalDic.DIR_RIGHT;
//			_rwall.userData=KitchenGlobalDic.DIR_LEFT;
			_fwall.setMaterialToAllSurfaces(material);
			_lwall.setMaterialToAllSurfaces(material);
			_rwall.setMaterialToAllSurfaces(material);
//			_fwall.x=0;
			_fwall.y=width>>1;
			_lwall.x=-length>>1;
//			_lwall.y=0;
			_rwall.x=length>>1;
//			_rwall.y=0;
			addFurnitureView(_fwall);
			addFurnitureView(_lwall);
			addFurnitureView(_rwall);
			
			leftUpPos.setTo(-length>>1,width>>1,width>>1);
			rightUpPos.setTo(length>>1,width>>1,width>>1);
			leftDownPos.setTo(-length>>1,-width>>1,width>>1);
			rightDownPos.setTo(length>>1,-width>>1,width>>1);
		}

	}
}