package main
{

	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.utils.CDebug;
	
	import interfaces.ICFurnitureModel;
	import interfaces.ICFurnitureSet;
	import interfaces.ICKithenModule;
	
	import model.CabinetModel;
	import model.KitchenGlobalModel;
	
	import ns.cloudLib;
	
	import view.CBox;
	import view.CShelterView;
	import view.CTableBoardView;

	use namespace cloudLib
	/**
	 *  厨房模块实例
	 * @author cloud
	 */
	internal class CKithenModuleImp extends EventDispatcher implements ICKithenModule
	{
		private var _modelsDict:Dictionary;
		private var _tableBoard:CTableBoardView;
		private var _shelter:CShelterView;
		private var _isRunning:Boolean;
		
		public function CKithenModuleImp()
		{
		}
		
		public function hasFloorID(floorID:String):Boolean
		{
			return KitchenGlobalModel.instance.hasFloorID(floorID);
		}
		public function importWallPosition(poses:Vector.<Vector3D>,floorID:String):void
		{
			KitchenGlobalModel.instance.parseWalls(poses,floorID);
		}
		public function createKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void
		{
			KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).createFurnitureVo(furnitureID,furnitureDirection,furnitureType,furnitureLength,furnitureWidth,furnitureHeight);
		}
		public function deleteKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint):void
		{
			KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).deleteFurnitureVo(furnitureID);
		}
		public function excuteMove(furnitureDir:int,furnitureType:uint,position:Vector3D):Boolean
		{
			return KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).excuteMove(furnitureDir,position);
		}
		public function excuteMouseDown(furnitureID:String,furnitureDir:int,furnitureType:uint):Boolean
		{
			return KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).excuteMouseDown(furnitureID,furnitureDir);
		}
		public function excuteMouseUp(furnitureType:uint):Vector.<ICData>
		{
			return KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).excuteMouseUp();
		}
		public function createTableBoard():ICFurnitureSet
		{		
			var cabinetModel:CabinetModel=(KitchenGlobalModel.instance.getModerByDic(KitchenGlobalModel.instance.OBJECT3D_CABINET,_modelsDict) as CabinetModel)
			var vos:Vector.<ICObject3DData>=cabinetModel.getRoomCorners();
			if(vos)
			{
				_tableBoard=new CTableBoardView();
				_tableBoard.createTableBoards(vos);
				var furniturevos:Vector.<ICObject3DData>=cabinetModel.getFurnituresInList();
				if(furniturevos)
					_tableBoard.createTableBoards(furniturevos);
				var child:CBox;
				for(var i:int=0; i<_tableBoard.numChildren; i++)
				{
					child=_tableBoard.getChildAt(i) as CBox;
					child.scaleX=10;
					child.scaleY=10;
					child.scaleZ=10;
				}
			}
			return _tableBoard;	
		}
		public function createShelter(ptl:Vector3D,ptr:Vector3D,pbl:Vector3D,pbr:Vector3D):ICFurnitureSet
		{
			var vos:Vector.<ICObject3DData>=(KitchenGlobalModel.instance.getModerByDic(KitchenGlobalModel.instance.OBJECT3D_CABINET,_modelsDict) as CabinetModel).getRoomCorners();
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
			}
			return _shelter;
		}
		public function clear():void
		{
			var cabinetModel:CabinetModel=KitchenGlobalModel.instance.getModerByDic(KitchenGlobalModel.instance.OBJECT3D_CABINET,_modelsDict) as CabinetModel;
			if(_tableBoard)
			{
				_tableBoard.dispose();
				_tableBoard=null;
			}
			if(_shelter)
			{
				_shelter.dispose();
				_shelter=null;
			}
			cabinetModel.deleteRoomCorners();
		}
		public function getQuotes():void
		{
			CDebug.instance.traceStr("CKithenModuleImp->getQuotes()");
		}
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		public function start():void
		{
			if(!_isRunning)
			{
				_isRunning=true;
				_modelsDict=new Dictionary();
			}
		}
		public function stop():void
		{
			if(_isRunning)
			{
				_isRunning=false;
				clear();
				for(var key:String in _modelsDict)
				{
					var furnitureModel:ICFurnitureModel=_modelsDict[key] as ICFurnitureModel;
					furnitureModel.clear();
					delete _modelsDict[key];
				}
				_modelsDict=null;
			}
		}
		public function updateByFrame(time:Number=0):void
		{
			
		}
	}
}