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
		
		protected function addContent(mesh:Mesh):void
		{
			_meshes.push(mesh);
		}

		public function get furnitureVos():Vector.<ICObject3DData>
		{
			return _datas;			
		}
		public function dispose():void
		{
			for each(var mesh:Mesh in _meshes)
			{
				this.removeChild(mesh);
			}
			_meshes.length=0;
			_meshes=null;
			_datas.length=0;
			_datas=null;
		}
	}
}