package main
{

	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.utils.CDebug;
	
	import interfaces.ICFurnitureModel;
	import interfaces.ICFurnitureSet;
	import interfaces.ICKitchenModule;
	
	import model.CabinetModel;
	import model.KitchenGlobalModel;
	
	import ns.cloudLib;
	
	import view.CBox;
	import view.CShelterView;
	import view.CTableBoardView;

	use namespace cloudLib
	/**
	 *  厨房模块接口实现类
	 * @author cloud
	 */
	internal class CKitchenModuleImp extends EventDispatcher implements ICKitchenModule
	{
		private var _modelsDict:Dictionary;
		private var _tableBoard:CTableBoardView;
		private var _shelter:CShelterView;
		private var _isRunning:Boolean;
		
		public function CKitchenModuleImp()
		{
		}

		public function hasFloorID(floorID:String):Boolean
		{
			CONFIG::isKitchen
				{
					return KitchenGlobalModel.instance.hasFloorID(floorID);
				}
			return false;
		}
		public function importWallPosition(poses:Vector.<Vector3D>,floorID:String):void
		{
			CONFIG::isKitchen
				{
					KitchenGlobalModel.instance.parseWalls(poses,floorID);
				}
		}
		public function createKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void
		{
			CONFIG::isKitchen
				{
					KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).createFurnitureVo(furnitureID,furnitureDirection,furnitureType,furnitureLength,furnitureWidth,furnitureHeight);
				}
		}
		public function deleteKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint):void
		{
			CONFIG::isKitchen
				{
					KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).deleteFurnitureVo(furnitureID);
				}
		}
		public function excuteMove(furnitureDir:int,furnitureType:uint,position:Vector3D):Boolean
		{
			CONFIG::isKitchen
				{
					return KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).excuteMove(furnitureDir,position);
				}
			return false;
		}
		public function excuteMouseDown(furnitureID:String,furnitureDir:int,furnitureType:uint):Boolean
		{
			CONFIG::isKitchen
				{
					return KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).excuteMouseDown(furnitureID,furnitureDir);
				}
			return true;
		}
		public function excuteMouseUp(furnitureType:uint):Vector.<ICData>
		{
			CONFIG::isKitchen
				{
					return KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).excuteMouseUp();
				}
			return null;
		}
		public function excuteEnd(furnitureType:uint):void
		{
			CONFIG::isKitchen
				{
					KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).excuteEnd();
				}
		}
		public function createTableBoard():ICFurnitureSet
		{		
			CONFIG::isKitchen
				{
					var cabinetModel:CabinetModel=(KitchenGlobalModel.instance.getModerByDic(Object3DDic.OBJECT3D_CABINET,_modelsDict) as CabinetModel)
					var vos:Vector.<ICObject3DData>=cabinetModel.createTableBoards();
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
				return null;
		}
		public function createShelter():ICFurnitureSet
		{
			CONFIG::isKitchen
				{
					var vos:Vector.<ICObject3DData>=(KitchenGlobalModel.instance.getModerByDic(Object3DDic.OBJECT3D_CABINET,_modelsDict) as CabinetModel).createShelterVos();
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
				return null;
		}
		public function clear():void
		{
			CONFIG::isKitchen
				{
					var cabinetModel:CabinetModel=KitchenGlobalModel.instance.getModerByDic(Object3DDic.OBJECT3D_CABINET,_modelsDict) as CabinetModel;
					if(_tableBoard)
					{
						_tableBoard.dispose();
						_tableBoard=null;
						cabinetModel.deleteTableBoards();
					}
					if(_shelter)
					{
						_shelter.dispose();
						_shelter=null;
						cabinetModel.deleteShelters();
					}
					cabinetModel.deleteRoomCorners();
				}
		}
		public function getQuotes():void
		{
			CONFIG::isKitchen
				{
					CDebug.instance.traceStr("CKithenModuleImp->getQuotes()");
				}
		}
		public function get isRunning():Boolean
		{
			CONFIG::isKitchen
				{
					return _isRunning;
				}
			return false;
		}
		public function start():void
		{
			CONFIG::isKitchen
				{
					if(!_isRunning)
					{
						_isRunning=true;
						_modelsDict=new Dictionary();
					}
				}
		}
		public function stop():void
		{
			CONFIG::isKitchen
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
		}
		public function updateByFrame(startTime:Number=0,frameTime:Number=0):void
		{
			CONFIG::isKitchen
				{
					if(getTimer()-startTime<frameTime)
					{
						//TODO:
					}
				}
		}
	}
}