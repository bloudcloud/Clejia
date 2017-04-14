package modules.kitchen.view
{
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import a3d.support.Scene3D;
	
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Plane;
	
	import bearas.geometrytool.IGeometryVertex;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.utils.Geometry3DUtil;
	import cloud.core.utils.MathUtil;
	import cloud.core.utils.Vector3DUtil;
	
	import core.model.GlobalModel;
	
	import dict.EventTypeDict;
	import dict.Object3DDict;
	
	import interfaces.ICFurnitureModel;
	
	import l3dbuild.geometry.L3DGeometryData;
	import l3dbuild.geometry.L3DVertex;
	import l3dbuild.geometry.ProcessPathExtrude;
	
	import main.CDecorationModuleImp;
	
	import model.CabinetModel;
	import model.HangingCabinetModel;
	import model.KitchenGlobalModel;
	import model.vo.CWallVO;
	import model.vo.task.CTaskVO;
	
	import ns.cloudLib;
	
	import rl2.mvcs.view.BaseMediator;
	
	import utils.DatasEvent;
	
	import view.CBox;
	import view.CShelterView;
	import view.CTableBoardView;
	
	use namespace cloudLib;
	/**
	 *  单柜可视对象集合中介类
	 * @author cloud
	 */
	public class CabinetViewSetMediator extends BaseMediator
	{
		[Inject]
		public var globalModel:GlobalModel;
		[Inject]
		public var cabinetModel:CabinetModel;
		[Inject]
		public var hangingCabinetModel:HangingCabinetModel;
		[Inject]
		public var scene:Scene3D;

		private var _intersectPos:Vector3D;
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
			_intersectPos=new Vector3D();
			_shelterPlanes=new Vector.<Plane>();
		}
		private function getModel(type:uint):ICFurnitureModel
		{
			switch(cabinetSet.currentMeshType)
			{
				case Object3DDict.OBJECT3D_CABINET:
				case Object3DDict.OBJECT3D_BASIN:
					return cabinetModel;
				case Object3DDict.OBJECT3D_HANGING_CABINET:
					return hangingCabinetModel;
				default:
					return null;
			}
		}
		
		private function onMouseDown(evt:MouseEvent3D):void
		{
			scene.view.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			scene.view.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			scene.controller.disable();
			var mesh:L3DMesh=evt.currentTarget as L3DMesh;
			cabinetSet.setSelected(mesh);
			getModel(mesh.catalog).excuteMouseDown(mesh.UniqueID,KitchenGlobalModel.instance.DIR_FRONT);
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			var furnitureModel:ICFurnitureModel=getModel(cabinetSet.currentMeshType);
			var lastPos:Vector3D=_intersectPos;
			scene.calculateMouseRay(Vector3DUtil.RAY_3D,evt.localX,evt.localY);
			Geometry3DUtil.intersectPlaneByRay(Vector3DUtil.RAY_3D,Vector3DUtil.ZERO,Vector3D.Z_AXIS,_intersectPos);
			cabinetSet.fixPos(_intersectPos,globalModel.roomLength,globalModel.roomWidth,globalModel.floorHeight);
			var bool:Boolean=furnitureModel.excuteMove(cabinetSet.currentRotation,_intersectPos);
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
			var furnitureModel:ICFurnitureModel=getModel(cabinetSet.currentMeshType);
			scene.view.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			scene.view.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			scene.controller.enable();
			var vos:Vector.<ICData>=furnitureModel.excuteMouseUp();
			if(vos)
			{
				updateMeshPosition(vos);
				furnitureModel.excuteEnd();
			}
			//test
			var geo:L3DGeometryData=new L3DGeometryData();
			var sourceGeo:L3DGeometryData=new L3DGeometryData();
			var sourceMesh:L3DMesh=cabinetSet.meshes[i].getChildAt(0) as L3DMesh
			sourceGeo.readFromMesh(sourceMesh);
			var paths:Vector.<Vector3D>=new Vector.<Vector3D>();
			var walls:Vector.<CWallVO>=KitchenGlobalModel.instance.wallVos;
			for(var i:int=0; i<walls.length; i++)
			{
				paths.push(walls[i].startPos.clone());
			}
			var func:Function=function travelFunction(vertex:IGeometryVertex,pos:Vector3D,dir:Vector3D):void{
				var v:L3DVertex = vertex as  L3DVertex;
				var length:Number = pos.subtract(v.position).dotProduct(dir);
				v.texcord0.y += length/100;
				v.texcord1.y += length/100;
			};
			ProcessPathExtrude(geo,sourceGeo,paths,func);
			var mesh:Mesh=new Mesh();
			var material:Material=sourceMesh.getSurface(0).material;
			geo.writeToMesh(mesh,material);
			cabinetSet.addFurnitureView(mesh);
		}
		private function updateMeshPosition(vos:Vector.<ICData>):void
		{
			var mesh:L3DMesh;
			var meshes:Array;
			var furnitureModel:ICFurnitureModel=getModel(cabinetSet.currentMeshType);
			for each(var vo:ICObject3DData in vos)
			{
				for (var i:int=0; i<cabinetSet.meshes.length; i++)
				{
					mesh=cabinetSet.meshes[i] as L3DMesh;
					if(mesh && mesh.UniqueID==vo.uniqueID)
					{
						if(vo.isLife)
						{
							mesh.rotationZ=MathUtil.toRadians(vo.rotation);
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
		private function onCreateKitchenFurniture(evt:DatasEvent):void
		{
			var mesh:L3DMesh = evt.data as L3DMesh;
			var childMesh:L3DMesh=mesh.getChildAt(0) as L3DMesh;
			var material:Material=childMesh.getSurface(0).material;
			mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
	 		cabinetSet.createCabinet(mesh);
			getModel(mesh.catalog).createFurnitureVo(mesh.UniqueID,MathUtil.toDegrees(mesh.rotationZ),mesh.catalog,mesh.Length,mesh.Width,mesh.Height);
		}
		
		/**
		 * 创建台面 
		 * @param evt
		 * 
		 */		
		private function onCreateTableBoard(evt:DatasEvent):void
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
			var vos:Vector.<ICObject3DData>=cabinetModel.createTableBoards();
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
		private function onCreateShelter(evt:DatasEvent):void
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
		
		private var decorationModule:CDecorationModuleImp;
		private function createShelter():void
		{
			var vos:Vector.<ICObject3DData>=cabinetModel.createShelterVos();
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
			var taskVo:CTaskVO=new CTaskVO();
			taskVo.type=Object3DDict.OBJECT3D_WAIST;
			taskVo.code="YX-3R30472BP";
			taskVo.url="LIBRARY\\JD20170411201325387427\\YX-3R30472BP.L3D";
			taskVo.direction=Vector3D.X_AXIS;
			taskVo.length=1000;
			taskVo.height=80;
			taskVo.x=0;
			taskVo.y=0;
			taskVo.z=0;
			taskVo.endCallback=endCallback;
			decorationModule=new CDecorationModuleImp();
			decorationModule.addDecorationTask(taskVo,scene.stage3D);
		}
		private function endCallback(mesh:Mesh):void
		{
			var material:Material=mesh.getSurface(0).material;
			var parentMesh:Mesh=new Mesh();
			parentMesh.addChild(mesh);
			var l3dModel:L3DModel=new L3DModel();
			l3dModel.Import(parentMesh,false,true);
			var l3dMesh:L3DMesh=l3dModel.Export(scene.stage3D);
			var child:L3DMesh=l3dMesh.getChildAt(0) as L3DMesh;
			child.addSurface(material,0,child.NumberTriangles);
			cabinetSet.addFurnitureView(l3dMesh);
		}
		override protected function addListener():void
		{
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateKitchenFurniture);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_HANGING_CABINET,onCreateKitchenFurniture);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_KICHENPART,onCreateKitchenFurniture);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.addEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_CABINET,onCreateKitchenFurniture);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_HANGING_CABINET,onCreateKitchenFurniture);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_KICHENPART,onCreateKitchenFurniture);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_TABLE_BOARD,onCreateTableBoard);
			dispatcher.removeEventListener(EventTypeDict.CMD_CREATE_SHELTER,onCreateShelter);
		}
	}
}