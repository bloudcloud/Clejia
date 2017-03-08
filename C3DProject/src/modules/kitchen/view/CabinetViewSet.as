package modules.kitchen.view
{
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.objects.Mesh;
	
	import core.view.BaseFurnitureViewSet;
	
	import flash.geom.Vector3D;
	
	/**
	 *  单柜可视对象集合类
	 * @author cloud
	 */
	public class CabinetViewSet extends BaseFurnitureViewSet
	{
		private var _currentMesh:L3DMesh;
		
		public function CabinetViewSet()
		{
			super();
		}
		/**
		 * 设置当前选中的橱柜模型 
		 * @param mesh
		 * 
		 */		
		public function setSelected(mesh:L3DMesh):void
		{
			if(_currentMesh)
				_currentMesh.ShowBoundBox=false;
			_currentMesh=mesh;
			_currentMesh.ShowBoundBox=true;
		}
		/**
		 * 创建一个橱柜 
		 * @param mesh
		 * 
		 */		
		public function createCabinet(mesh:L3DMesh):void
		{
			addFurnitureView(mesh);
		}
		/**
		 *  删除当前橱柜
		 * @param mesh
		 * 
		 */		
		public function deleteCabinet():void
		{
			removeFurnitureView(_currentMesh);
		}
		/**
		 * 更新当前橱柜模型的坐标 
		 * @param pos
		 * 
		 */		
		public function updateCurrentPos(pos:Vector3D):void
		{
			_currentMesh.x=pos.x;
			_currentMesh.y=pos.y;
			_currentMesh.z=pos.z;
		}
		/**
		 * 根据选中的橱柜模型修正坐标 
		 * @param pos
		 * @param roomLength
		 * @param roomWidth
		 * @param roomHeight
		 * 
		 */		
		public function fixPos(pos:Vector3D,roomLength:uint,roomWidth:uint,roomHeight:uint):void
		{
			var disX:uint = roomLength-_currentMesh.Length>>1;
			var disY:uint = roomWidth-_currentMesh.Width>>1;
			var disZ:uint = roomHeight-_currentMesh.Height>>1;
			if(pos.x>disX)
				pos.x=disX;
			else if(pos.x<-disX)
				pos.x=-disX;
			if(pos.y>disY)
				pos.y=disY;
			else if(pos.y<-disY)
				pos.y=-disY;
			if(pos.z>disZ)
				pos.z=disZ;
			else if(pos.z<-disZ)
				pos.z=-disZ;
		}
		/**
		 * 获取当前橱柜的唯一id 
		 * @return String
		 * 
		 */		
		public function getCurrentMeshID():String
		{
			if(_currentMesh)
				return _currentMesh.UniqueID;
			return null;
		}
	}
}