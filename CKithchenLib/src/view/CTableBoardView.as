package view
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.primitives.Box;
	
	import dic.KitchenGlobalDic;
	
	import flash.geom.Vector3D;
	
	import model.vo.TableBoardVO;

	/**
	 *  台面类
	 * @author cloud
	 */
	public class CTableBoardView extends CBuildFurnitureSet
	{
		private var _material:Material;
		
		public function getTableBoardID():String
		{
			var child:Object3D;
			for (var i:int=0; i<numChildren; i++)
			{
				child=getChildAt(i);
				if(child is CBox)
					return (child as CBox).uniqueID;
			}
			return null;
		}
		public function CTableBoardView()
		{
			super();
			_material=new FillMaterial(0x088000);
		}
		
		public function createTableBoard(vo:TableBoardVO):void
		{
			var mesh:CBox=new CBox(vo.length,vo.width,vo.height);
			mesh.name="tableBoard"+vo.uniqueID;
			mesh.userData=new RelatingParams();
			mesh.uniqueID=vo.uniqueID;
			mesh.setMaterialToAllSurfaces(_material);
			mesh.position=vo.position;
			this.addChild(mesh);
		}
		
		override public function dispose():void
		{
			_material=null;
		}
	}
}