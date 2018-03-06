package modules.kitchen.view
{
	import flash.events.MouseEvent;
	
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Plane;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.events.CDataEvent;
	import cloud.core.interfaces.ICData;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CGeometry3DUtil;
	import cloud.core.utils.CMathUtil;
	import cloud.core.utils.CVectorUtil;
	
	import core.model.GlobalModel;
	
	import dict.CommandTypeDict;
	
	import kitchenModule.interfaces.ICFurnitureModel;
	import kitchenModule.model.CabinetModel;
	import kitchenModule.model.KitchenGlobalModel;
	import kitchenModule.view.CBox;
	import kitchenModule.view.CShelterView;
	import kitchenModule.view.CTableBoardView;
	
	import main.a3d.support.CScene3D;
	import main.dict.CDataTypeDict;
	import main.model.WallDataModel;
	import main.model.vo.task.CObject3DVO;
	import main.model.vo.task.CTaskVO;
	
	import ns.cloudLib;
	
	import rl2.mvcs.view.BaseMediator;
	
	import wallDecorationModule.service.CWaistDecorationService;
	
	use namespace cloudLib;
	/**
	 *  单柜可视对象集合中介类
	 * @author cloud
	 */
	public class CabinetViewSetMediator extends BaseMediator
	{
		[Inject]
		public var wallModel:WallDataModel;
		[Inject]
		public var globalModel:GlobalModel;
		[Inject]
		public var cabinetModel:CabinetModel;
//		[Inject]
//		public var hangingCabinetModel:HangingCabinetModel;
		[Inject]
		public var scene:CScene3D;

		private var _intersectPos:CVector;
		private var _tableBoard:CTableBoardView;
		private var _shelter:CShelterView;
		private var _shelterPlanes:Vector.<Plane>;
		
		public function get cabinetSet():CabinetViewSet
		{
			return _view as CabinetViewSet;
		}
		
		public function CabinetViewSetMediator()
		{
			super("CabinetViewSetMediator");
			_intersectPos=CVector.CreateOneInstance();
			_shelterPlanes=new Vector.<Plane>();
		}

		private function onMouseDown(evt:MouseEvent3D):void
		{
			scene.view.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			scene.view.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			scene.controller.disable();
			var mesh:L3DMesh=evt.currentTarget as L3DMesh;
			cabinetSet.setSelected(mesh);
			cabinetModel.excuteMouseDown(mesh.UniqueID,KitchenGlobalModel.instance.DIR_FRONT);
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			var furnitureModel:ICFurnitureModel=cabinetModel;
			scene.calculateMouseRay(CVectorUtil.RAY_3D,evt.localX,evt.localY);
			CGeometry3DUtil.Instance.intersectPlaneByRay(CVectorUtil.RAY_3D,CVector.ZERO,CVector.Z_AXIS,_intersectPos);
			cabinetSet.fixPos(_intersectPos,globalModel.roomLength,globalModel.roomHeight,globalModel.wallHeight);
			var bool:Boolean=furnitureModel.excuteMove(cabinetSet.currentRotation,CVectorUtil.Instance.transformToVector3D(_intersectPos));
			if(bool)
			{
				onMouseUp(evt);
			}
			else
			{
				cabinetSet.updateCurrent(cabinetSet.currentRotation,_intersectPos);
			}
			
		}
		private function onMouseUp(evt:MouseEvent):void
		{
			var furnitureModel:ICFurnitureModel=cabinetModel;
			scene.view.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			scene.view.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			scene.controller.enable();
			var vos:Vector.<ICData>=furnitureModel.excuteMouseUp();
			if(vos)
			{
				updateMeshPosition(vos);
				furnitureModel.excuteEnd();
			}
		}
		private function updateMeshPosition(vos:Vector.<ICData>):void
		{
			var mesh:L3DMesh;
			var meshes:Array;
			var furnitureModel:ICFurnitureModel=cabinetModel;
			for each(var vo:CObject3DVO in vos)
			{
				for (var i:int=0; i<cabinetSet.meshes.length; i++)
				{
					mesh=cabinetSet.meshes[i] as L3DMesh;
					if(mesh && mesh.UniqueID==vo.uniqueID)
					{
						if(vo.isLife)
						{
							mesh.rotationZ=CMathUtil.Instance.toRadians(vo.rotationHeight);
							mesh.x=vo.position.x;
							mesh.y=vo.position.y;
							mesh.z=vo.position.z;
						}
						else
						{
							meshes ||=new Array();
							meshes.push(mesh);
						}
					}
				}
			}
			if(meshes)
			{
				for(i=0;i<meshes.length;i++)
				{
					mesh=meshes[i];
					furnitureModel.deleteFurnitureVo(mesh.UniqueID);
					cabinetSet.removeFurnitureView(mesh);
//					mesh.Dispose(false);
				}
			}
			
		}
		/**
		 * 创建单柜 
		 * @param evt
		 * 
		 */		
		private function onCreateKitchenFurniture(evt:CDataEvent):void
		{
			var mesh:L3DMesh = evt.data as L3DMesh;
			var childMesh:L3DMesh=mesh.getChildAt(0) as L3DMesh;
			var material:Material=childMesh.getSurface(0).material;
			mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
	 		cabinetSet.createCabinet(mesh);
			cabinetModel.createFurnitureVo(mesh.UniqueID,CMathUtil.Instance.toDegrees(mesh.rotationZ),mesh.catalog,mesh.Length,mesh.Width,mesh.Height);
		}
		
		/**
		 * 创建台面 
		 * @param evt
		 * 
		 */		
		private function onCreateTableBoard(evt:CDataEvent):void
		{
			if(_tableBoard)
			{
				delelteCorners();
			}
			else
			{
				createTableBoard();
			}
		}
		private function createTableBoard():void
		{
			var vos:Vector.<CBaseObject3DVO>=cabinetModel.createTableBoards();
			if(vos)
			{
				_tableBoard=new CTableBoardView();
				_tableBoard.createTableBoards(vos);
				var child:CBox;
				for(var i:int=0; i<_tableBoard.numChildren; i++)
				{
					child=_tableBoard.getChildAt(i) as CBox;
					child.scaleX=10;
					child.scaleY=10;
					child.scaleZ=10;
				}
				cabinetSet.addFurnitureView(_tableBoard);
			}
		}
		/**
		 * 创建挡板 
		 * @param evt
		 * 
		 */		
		private function onCreateShelter(evt:CDataEvent):void
		{
			if(_shelter)
			{
				delelteCorners();
			}
			else
			{
				createShelter();
			}
		}
		private function delelteCorners():void
		{
			if(_shelter)
			{
				cabinetSet.removeFurnitureView(_shelter);
				_shelter.dispose();
				_shelter=null;
				cabinetModel.deleteShelters();
			}
			if(_tableBoard)
			{
				cabinetSet.removeFurnitureView(_tableBoard);
				_tableBoard.dispose();
				_tableBoard=null;
				cabinetModel.deleteTableBoards();
			}
			cabinetModel.deleteRoomCorners();
		}
		
		private var decorationModule:CWaistDecorationService;
		private function createShelter():void
		{
			var vos:Vector.<CBaseObject3DVO>=cabinetModel.createShelterVos();
			if(vos)
			{
				_shelter=new CShelterView();
				_shelter.createShelters(vos);
				var child:CBox;
				for(var i:int=0; i<_shelter.numChildren; i++)
				{
					child=_shelter.getChildAt(i) as CBox;
					child.scaleX=10;
					child.scaleY=10;
					child.scaleZ=10;
				}
				cabinetSet.addFurnitureView(_shelter);
			}
			//Test
//			var box:Box=new Box(100,100,100,1,1,1,false,new FillMaterial(0xff1111));
//			ViewItem3D.ShowItem(box,scene.stage3D,scene.view.parent);
			var taskVo:CTaskVO=new CTaskVO();
			taskVo.type=CDataTypeDict.OBJECT3D_WAIST;
			taskVo.code="YX-3R30472BP";
//			taskVo.url="LIBRARY\\JD20170411201325387427\\YX-3R30472BP.L3D";
			taskVo.length=1000;
			taskVo.height=200;
			taskVo.x=0;
			taskVo.y=0;
			taskVo.z=0;
			taskVo.endCallback=endCallback;
			decorationModule=new CWaistDecorationService();
			decorationModule.addWaist3DTask(taskVo);
		}
		private function endCallback(mesh:Mesh):void
		{
			var l3dModel:L3DModel=new L3DModel();
			l3dModel.Import(mesh,false,true);
			var l3dMesh:L3DMesh=l3dModel.Export(scene.stage3D);
			cabinetSet.addFurnitureView(l3dMesh);
		}
		private function onInitDoubleList(evt:CDataEvent):void
		{
			cabinetModel.rootList=KitchenGlobalModel.instance.initKitchenListByWalls(CDataTypeDict.OBJECT3D_CABINET,wallModel.walls);
//			hangingCabinetModel.rootList=KitchenGlobalModel.instance.initKitchenListByWalls(CDataTypeDict.OBJECT3D_CABINET,wallModel.walls);
		}
		override protected function addListener():void
		{
			dispatcher.addEventListener(CommandTypeDict.CMD_INIT_DOUBLELIST,onInitDoubleList);
			dispatcher.addEventListener(CommandTypeDict.CMD_CREATE_CABINET,onCreateKitchenFurniture);
			dispatcher.addEventListener(CommandTypeDict.CMD_CREATE_HANGING_CABINET,onCreateKitchenFurniture);
			dispatcher.addEventListener(CommandTypeDict.CMD_CREATE_KICHENPART,onCreateKitchenFurniture);
			dispatcher.addEventListener(CommandTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.addEventListener(CommandTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(CommandTypeDict.CMD_INIT_DOUBLELIST,onInitDoubleList);
			dispatcher.removeEventListener(CommandTypeDict.CMD_CREATE_CABINET,onCreateKitchenFurniture);
			dispatcher.removeEventListener(CommandTypeDict.CMD_CREATE_HANGING_CABINET,onCreateKitchenFurniture);
			dispatcher.removeEventListener(CommandTypeDict.CMD_CREATE_KICHENPART,onCreateKitchenFurniture);
			dispatcher.removeEventListener(CommandTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.removeEventListener(CommandTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
	}
}