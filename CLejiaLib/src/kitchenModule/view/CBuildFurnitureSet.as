package kitchenModule.view
{
	import alternativa.engine3d.objects.Mesh;
	
	import kitchenModule.interfaces.ICFurnitureSet;
	
	import main.model.vo.task.CObject3DVO;
	
	/**
	 *  
	 * @author cloud
	 */
	public class CBuildFurnitureSet extends Mesh implements ICFurnitureSet
	{
		private var _meshes:Vector.<Mesh>;
		private var _datas:Vector.<CObject3DVO>;
		public function CBuildFurnitureSet()
		{
			super();
			_meshes=new Vector.<Mesh>();
			_datas=new Vector.<CObject3DVO>();
		}
		
		protected function addContent(mesh:Mesh):void
		{
			_meshes.push(mesh);
		}

		public function get furnitureVos():Vector.<CObject3DVO>
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