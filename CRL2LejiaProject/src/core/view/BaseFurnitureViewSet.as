package core.view
{
	import flash.display.Stage3D;
	import flash.geom.Vector3D;
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.interfaces.IRenderAble;
	
	/**
	 *  基础家具视图类
	 * @author cloud
	 */
	public class BaseFurnitureViewSet extends Object3D implements IRenderAble
	{
		protected var _meshes:Vector.<Mesh>;
		
		protected var _width:uint;
		protected var _invalidRender:Boolean;

		public function get width():uint
		{
			return _width;
		}

		protected var _height:uint;

		public function get height():uint
		{
			return _height;
		}

		private var _length:uint;

		public function get length():uint
		{
			return _length;
		}
		
		protected var _position:Vector3D;

		public function get position():Vector3D
		{
			return _position;
		}
		
		public function BaseFurnitureViewSet()
		{
			_meshes=new Vector.<Mesh>();
		}
		
		public function addFurnitureView(furniture:Mesh):void
		{
			_invalidRender=true;
			_meshes.push(furniture);
			this.addChild(furniture);
		}
		public function removeFurnitureView(furniture:Mesh):void
		{
			_meshes.removeAt(_meshes.indexOf(furniture));
			this.removeChild(furniture);
		}
		/**
		 * 清除家具集合 
		 * 
		 */		
		public function clear():void
		{
			_meshes.length=0;
		}
		public function render(stage3d:Stage3D,curTime:int):void
		{
			if(_invalidRender)
			{
				_invalidRender=false;
				var rs:Vector.<Resource>
				for each(var mesh:Mesh in _meshes)
				{
					rs =  mesh.getResources(true);
					for(var i:int=0;i<rs.length;i++){
						if(!rs[i].isUploaded)
							rs[i].upload(stage3d.context3D);
					}
				}
			}
		}
	}
}