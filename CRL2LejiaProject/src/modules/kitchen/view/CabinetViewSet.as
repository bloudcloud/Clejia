package modules.kitchen.view
{
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.utils.CMathUtil;
	
	import core.view.BaseFurnitureViewSet;
	
	/**
	 *  单柜可视对象集合类
	 * @author cloud
	 */
	public class CabinetViewSet extends BaseFurnitureViewSet
	{
		private var _currentMesh:L3DMesh;
		
		public function get meshes():Vector.<Mesh>
		{
			return _meshes;
		}
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
		 * 创建一个单柜
		 * @param mesh
		 * 
		 */		
		public function createCabinet(mesh:L3DMesh):void
		{
			addFurnitureView(mesh);
			_currentMesh=mesh;
		}
		/**
		 *  删除当前橱柜
		 * @param mesh
		 * 
		 */		
		public function deleteCabinet():void
		{
			removeFurnitureView(_currentMesh);
			_currentMesh=null;
		}
		/**
		 * 创建一个吊柜 
		 * @param mesh
		 * 
		 */		
		public function createHangingCabinet(mesh:L3DMesh):void
		{
			addFurnitureView(mesh);
		}
		/**
		 * 删除当前吊柜 
		 * 
		 */		
		public function deleteHangingCabinet():void
		{
			removeFurnitureView(_currentMesh);
		}
		/**
		 * 更新当前橱柜模型的坐标 
		 * @param pos
		 * 
		 */		
		public function updateCurrent(direction:int,pos:CVector):void
		{
			_currentMesh.rotationZ=CMathUtil.Instance.toRadians(direction);
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
		public function fixPos(pos:CVector,roomLength:uint,roomWidth:uint,roomHeight:uint):void
		{
			var disX:uint = (roomLength-_currentMesh.Length)*.5;
			var disY:uint = (roomWidth-_currentMesh.Length)*.5;
			var disZ:uint = roomHeight-_currentMesh.Height*.5;
			if(pos.x>disX)
			{
				_currentMesh.rotationZ=CMathUtil.Instance.toRadians(-90);
				pos.x=disX;
			}
			else if(pos.x<-disX)
			{
				_currentMesh.rotationZ=CMathUtil.Instance.toRadians(90);
				pos.x=-disX;
			}
			if(pos.y>disY)
			{
				_currentMesh.rotationZ=CMathUtil.Instance.toRadians(0);
				pos.y=disY;
			}
			else if(pos.y<-disY)
			{
				_currentMesh.rotationZ=CMathUtil.Instance.toRadians(180);
				pos.y=-disY;
			}
			if(pos.z>disZ)
				pos.z=disZ;
			else if(pos.z<-disZ)
				pos.z=-disZ;
		}
		public function get currentRotation():Number
		{
			return CMathUtil.Instance.toDegrees(_currentMesh.rotationZ);
		}
		/**
		 * 获取当前家具模型的唯一id 
		 * @return String
		 * 
		 */		
		public function get currentMeshID():String
		{
			return _currentMesh?_currentMesh.UniqueID:null;
		}
		/**
		 * 获取当前家具模型的类型 
		 * @return 
		 * 
		 */		
		public function get currentMeshType():int
		{
			return _currentMesh?_currentMesh.catalog:-1;
		}
	}
}