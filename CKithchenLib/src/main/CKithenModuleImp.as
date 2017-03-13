package main
{

	import alternativa.engine3d.objects.Mesh;
	
	import dic.KitchenGlobalDic;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import interfaces.ICFurnitureModel;
	import interfaces.ICFurnitureVO;
	import interfaces.ICKithenModule;
	
	import model.BaseFurnitureSetModel;
	import model.CabinetModel;
	import model.HangingCabinetModel;
	import model.vo.ShelterVO;
	import model.vo.TableBoardVO;
	
	import utils.DatasEvent;
	
	import view.CShelterView;
	import view.CTableBoardView;

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

		private function getModel(furnitureType:uint):BaseFurnitureSetModel
		{
			if(_modelsDict[furnitureType]==null)
			{
				switch(furnitureType)
				{
					case KitchenGlobalDic.MESHTYPE_CABINET:
						_modelsDict[furnitureType]=new CabinetModel();
						break;
					case KitchenGlobalDic.MESHTYPE_HANGING_CABINET:
						_modelsDict[furnitureType]=new HangingCabinetModel();
						break;
					default:
						throw new Error(String("没有获取到数据模型！ furnitureType:"+furnitureType));
				}
			}
			return _modelsDict[furnitureType];
		}
		private function onCreateCabinet(evt:DatasEvent):void
		{
			var inputData:FurnitureInputData=evt.data as FurnitureInputData;
			createCabinet(inputData.furnitureID,inputData.furnitureType,inputData.furnitureLength,inputData.furnitureWidth,inputData.furnitureHeight);
		}
		private function onDeleteCabinet(evt:DatasEvent):void
		{
			var inputData:FurnitureInputData=evt.data as FurnitureInputData;
			deleteCabinet(inputData.furnitureID,inputData.furnitureType);
		}
		public function start():void
		{
			this.addEventListener(Event.ADDED,onCreateCabinet);
			this.addEventListener(Event.REMOVED,onDeleteCabinet);
		}
		public function stop():void
		{
			this.removeEventListener(Event.ADDED,onCreateCabinet);
			this.removeEventListener(Event.REMOVED,onDeleteCabinet);
			for (var str:String in _modelsDict)
			{
				(_modelsDict[str] as ICFurnitureModel).clear();
				delete _modelsDict[str];
			}
		}
		public function createCabinet(furnitureID:String,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void
		{
			(getModel(KitchenGlobalDic.MESHTYPE_CABINET) as CabinetModel).createCabinetVO(furnitureID,furnitureType,furnitureLength,furnitureWidth,furnitureHeight);
		}
		public function createHangingCabinet(furnitureID:String,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void
		{
			(getModel(KitchenGlobalDic.MESHTYPE_CABINET) as HangingCabinetModel).createHangingCabinet(furnitureID,furnitureType,furnitureLength,furnitureWidth,furnitureHeight);
		}
		public function deleteCabinet(furnitureID:String,furnitureType:uint):void
		{
			(getModel(KitchenGlobalDic.MESHTYPE_CABINET) as CabinetModel).deleteCabinetVO(furnitureID);
		}
		public function excuteMove(furnitureID:String,furnitureType:uint,furnitureRotationZ:Number,outputPos:Vector3D):Boolean
		{
			return getModel(furnitureType).excuteMove(furnitureID,furnitureRotationZ,outputPos);
		}
		public function createTableBoard():Mesh
		{
			if(_tableBoard==null)
			{
				var cabinetModel:CabinetModel=getModel(KitchenGlobalDic.MESHTYPE_CABINET) as CabinetModel;
				var vo:TableBoardVO=cabinetModel.createTableBoardVO(cabinetModel.length,cabinetModel.width,KitchenGlobalDic.TABLEBOARD_HEIGHT,cabinetModel.combinePos);
				_tableBoard=new CTableBoardView();
				_tableBoard.createTableBoard(vo);
			}
			return _tableBoard;
		}
		public function createShelter(ptl:Vector3D,ptr:Vector3D,pbl:Vector3D,pbr:Vector3D):Mesh
		{
			if(_shelter==null)
			{
				var cabinetModel:CabinetModel=getModel(KitchenGlobalDic.MESHTYPE_CABINET) as CabinetModel;
				var vos:Vector.<ShelterVO>=cabinetModel.createShelterVOs();
				if(vos)
				{
					_shelter=new CShelterView();
					_shelter.createShelter(vos);
				}
			}
			return _shelter;
		}
		public function clear():void
		{
			var cabinetModel:CabinetModel;
			cabinetModel=getModel(KitchenGlobalDic.MESHTYPE_CABINET) as CabinetModel;
			if(_tableBoard)
			{
				cabinetModel.deleteTableBoardVO(_tableBoard.getTableBoardID());
				_tableBoard=null;
			}
			if(_shelter)
			{
				var ids:Vector.<String>=_shelter.getShelterIDs();
				cabinetModel.deleteShelterVOs(ids);
				_shelter=null;
			}
			trace("CKithenModuleImp->clear()");
		}
		public function getQuotes():void
		{
			trace("CKithenModuleImp->getQuotes()");
		}
	}
}