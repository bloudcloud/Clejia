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
		
		public function CKithenModuleImp()
		{
			_modelsDict=new Dictionary();
		}

		public function start():void
		{
			
		}
		public function stop():void
		{
			
		}
		public function importWallPosition(ptl:Vector3D,ptr:Vector3D,pbl:Vector3D,pbr:Vector3D):void
		{
			KitchenGlobalModel.instance.leftTopWallPos=ptl;
			KitchenGlobalModel.instance.rightTopWallPos=ptr;
			KitchenGlobalModel.instance.leftBottomWallPos=pbl;
			KitchenGlobalModel.instance.rightBottomWallPos=pbr;
			KitchenGlobalModel.instance.getModerByDic(KitchenGlobalModel.instance.MESHTYPE_CABINET,_modelsDict).initModel();
			KitchenGlobalModel.instance.getModerByDic(KitchenGlobalModel.instance.MESHTYPE_HANGING_CABINET,_modelsDict).initModel();
		}
		public function createKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void
		{
			KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).createFurnitureVo(furnitureID,furnitureDirection,furnitureType,furnitureLength,furnitureWidth,furnitureHeight);
		}
		public function deleteKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint):void
		{
			KitchenGlobalModel.instance.getModerByDic(furnitureType,_modelsDict).deleteFurnitureVo(furnitureID,furnitureDirection);
		}
		public function updateFurnitureUniqueID(furnitureID:String,furnitureType:uint,uniqueID:String):void
		{
//			var vo:ICObject3DData=getModel(furnitureType).getFurnitureVOByID(furnitureID);
//			vo.uniqueID=uniqueID;
		}
		public function excuteMove(furnitureDir:int,furnitureType:uint,position:Vector3D):Vector.<ICData>
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
			var vos:Vector.<ICData>=(KitchenGlobalModel.instance.getModerByDic(KitchenGlobalModel.instance.MESHTYPE_CABINET,_modelsDict) as CabinetModel).createTableBoard();
			if(vos)
			{
				_tableBoard=new CTableBoardView();
				_tableBoard.createTableBoard(vos);
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
			var vos:Vector.<ICData>=(KitchenGlobalModel.instance.getModerByDic(KitchenGlobalModel.instance.MESHTYPE_CABINET,_modelsDict) as CabinetModel).createShelter();
			if(vos)
			{
				_shelter=new CShelterView();
				_shelter.createShelter(vos);
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
			var cabinetModel:CabinetModel=KitchenGlobalModel.instance.getModerByDic(KitchenGlobalModel.instance.MESHTYPE_CABINET,_modelsDict) as CabinetModel;
			if(_tableBoard)
			{
				cabinetModel.deleteTableBoardVos();
				_tableBoard.dispose();
				_tableBoard=null;
			}
			if(_shelter)
			{
				cabinetModel.deleteShelterVos();
				_shelter.dispose();
				_shelter=null;
			}
		}
		public function getQuotes():void
		{
			trace("CKithenModuleImp->getQuotes()");
		}
	}
}