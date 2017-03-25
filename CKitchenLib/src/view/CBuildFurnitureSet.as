package view
{
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.interfaces.ICObject3DData;
	
	import interfaces.ICFurnitureSet;
	
	/**
	 *  
	 * @author cloud
	 */
	public class CBuildFurnitureSet extends Mesh implements ICFurnitureSet
	{
		private var _meshes:Vector.<Mesh>;
		private var _datas:Vector.<ICObject3DData>;
		public function CBuildFurnitureSet()
		{
			super();
			_meshes=new Vector.<Mesh>();
			_datas=new Vector.<ICObject3DData>();
		}
		
		protected function addContent(mesh:Mesh,vo:ICObject3DData):void
		{
			_meshes.push(mesh);
			_datas.push(vo);
		}

		public function get furnitureVos():Vector.<ICObject3DData>
		{
			return _datas;			
		}
		public function dispose():void
		{
			_meshes=null;
			_datas=null;
		}
	}
}