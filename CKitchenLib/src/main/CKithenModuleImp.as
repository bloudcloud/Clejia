package main
{

	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import cloud.core.interfaces.ICData;
	
	import interfaces.ICFurnitureModel;
	import interfaces.ICFurnitureSet;
	import interfaces.ICKithenModule;
	
	import model.CabinetModel;
	import model.KitchenErrorModel;
	import model.KitchenGlobalModel;
	
	import ns.cloudLib;
	
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
		
		public function CKithenModuleImp()
		{
			_modelsDict=new Dictionary();
		}

		private function getModel(furnitureType:uint):ICFurnitureModel
		{
			if(_modelsDict[furnitureType]==null)
			{
				switch(furnitureType)
				{
					case KitchenGlobalModel.instance.MESHTYPE_CABINET:
						_modelsDict[furnitureType]=new CabinetModel();
						break;
					case KitchenGlobalModel.instance.MESHTYPE_HANGING_CABINET:
//						_modelsDict[furnitureType]=new HangingCabinetModel();
						break;
					case KitchenGlobalModel.instance.MESHTYPE_SINK:
//						_modelsDict[furnitureType]=new KitchenPartModel();
						break;
					default:
						KitchenErrorModel.instance.throwErrorByMessage("CKithenModuleImp","getModel","furnitureType",String(furnitureType+" 没有获取到数据模型！ "));
						break;
				}
			}
			return _modelsDict[furnitureType];
		}
		public function start():void
		{
		}
		public function stop():void
		{
			
		}
		public function importWallPosition(ptl:Vector3D,ptr:Vector3D,pbl:Vector3D,pbr:Vector3D):void
		{
//			for each(var chainModel:BaseChainFurnitureModel in _modelsDict)
//			{
//				if(chainModel)
//				{
//					chainModel.topLeftWallPos.copyFrom(ptl);
//					chainModel.topRightWallPos.copyFrom(ptr);
//					chainModel.bottomLeftWallPos.copyFrom(pbl);
//					chainModel.bottomRightWallPos.copyFrom(pbr);
//				}
//			}
		}
		public function createKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void
		{
			getModel(furnitureType).createFurnitureVo(furnitureID,furnitureDirection,furnitureType,furnitureLength,furnitureWidth,furnitureHeight);
		}
		public function deleteKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint):void
		{
			getModel(furnitureType).deleteFurnitureVo(furnitureID,furnitureDirection);
		}
		public function updateFurnitureUniqueID(furnitureID:String,furnitureType:uint,uniqueID:String):void
		{
//			var vo:ICObject3DData=getModel(furnitureType).getFurnitureVOByID(furnitureID);
//			vo.uniqueID=uniqueID;
		}
		public function excuteMove(furnitureDir:int,furnitureType:uint,position:Vector3D):Vector.<ICData>
		{
			return getModel(furnitureType).excuteMove(furnitureDir,position);
		}
		public function excuteMouseDown(furnitureID:String,furnitureDir:int,furnitureType:uint):Boolean
		{
			return getModel(furnitureType).excuteMouseDown(furnitureID,furnitureDir);
		}
		public function excuteMouseUp(furnitureType:uint):Vector.<ICData>
		{
			return getModel(furnitureType).excuteMouseUp();
		}
		public function createTableBoard():ICFurnitureSet
		{
//			var cabinetModel:CabinetModel=getModel(KitchenGlobalModel.instance.MESHTYPE_CABINET) as CabinetModel;
//			if(cabinetModel.tableBoardVo==null)
//			{
//				var vo:TableBoardVO=cabinetModel.createTableBoardVO(cabinetModel.length,cabinetModel.width,KitchenGlobalModel.instance.TABLEBOARD_HEIGHT,cabinetModel.combinePos);
//				_tableBoard=new CTableBoardView();
//				_tableBoard.createTableBoardMesh(vo);
//				return _tableBoard;
//			}
			return null;	
		}
		public function createShelter(ptl:Vector3D,ptr:Vector3D,pbl:Vector3D,pbr:Vector3D):ICFurnitureSet
		{
//			if(_shelter==null)
//			{
//				var cabinetModel:CabinetModel=getModel(KitchenGlobalModel.instance.MESHTYPE_CABINET) as CabinetModel;
//				cabinetModel.topLeftWallPos.copyFrom(ptl);
//				cabinetModel.topRightWallPos.copyFrom(ptr);
//				cabinetModel.bottomLeftWallPos.copyFrom(pbl);
//				cabinetModel.bottomRightWallPos.copyFrom(pbr);
//				var vos:Vector.<ShelterVO>=cabinetModel.createShelterVOs();
//				if(vos)
//				{
//					_shelter=new CShelterView();
//					_shelter.createShelter(vos);
//				}
//			}
			return _shelter;
		}
		public function clear():void
		{
			var cabinetModel:CabinetModel;
			cabinetModel=getModel(KitchenGlobalModel.instance.MESHTYPE_CABINET) as CabinetModel;
//			if(_tableBoard)
//			{
//				cabinetModel.deleteTableBoardVOs(_tableBoard.furnitureVos);
//				_tableBoard.dispose();
//				_tableBoard=null;
//			}
//			if(_shelter)
//			{
//				cabinetModel.deleteShelterVOs(_shelter.furnitureVos);
//				_shelter.dispose();
//				_shelter=null;
//			}
		}
		public function getQuotes():void
		{
			trace("CKithenModuleImp->getQuotes()");
		}
	}
}