package kitchenModule
{

	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CDebugUtil;
	
	import kitchenModule.interfaces.ICFurnitureSet;
	import kitchenModule.interfaces.ICKitchenModule;
	import kitchenModule.service.CCabinetService;
	import kitchenModule.view.CBox;
	import kitchenModule.view.CShelterView;
	import kitchenModule.view.CTableBoardView;
	
	import ns.cloudLib;

	use namespace cloudLib
	/**
	 *  厨房模块接口实现类
	 * @author cloud
	 */
	public class CKitchenModuleImp extends EventDispatcher implements ICKitchenModule
	{
		private var _isRunning:Boolean;
		private var _cabinetService:CCabinetService;
		private var _tableBoard:CTableBoardView;
		private var _shelter:CShelterView;
		
		public function CKitchenModuleImp()
		{
		}

		public function createKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void
		{
			_cabinetService.createFurnitureVo(furnitureID,furnitureDirection,furnitureType,furnitureLength,furnitureWidth,furnitureHeight);
		}
		public function deleteKitchenFurniture(furnitureID:String,furnitureDirection:int,furnitureType:uint):void
		{
			_cabinetService.deleteFurnitureVo(furnitureID);
		}
		public function excuteMove(furnitureDir:int,furnitureType:uint,position:Vector3D):Boolean
		{
			return _cabinetService.excuteMove(furnitureDir,position);
		}
		public function excuteMouseDown(furnitureID:String,furnitureDir:int,furnitureType:uint):Boolean
		{
			return _cabinetService.excuteMouseDown(furnitureID,furnitureDir);
		}
		public function excuteMouseUp(furnitureType:uint):Vector.<ICData>
		{
			return _cabinetService.excuteMouseUp();
		}
		public function excuteEnd(furnitureType:uint):void
		{
			_cabinetService.excuteEnd();
		}
		public function createTableBoard():ICFurnitureSet
		{		
			var vos:Vector.<CBaseObject3DVO>=_cabinetService.createTableBoards();
			if(vos)
			{
				_tableBoard=new CTableBoardView();
				_tableBoard.createTableBoards(vos);
				var furniturevos:Vector.<CBaseObject3DVO>=_cabinetService.getFurnituresInList();
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
		public function createShelter():ICFurnitureSet
		{
			var vos:Vector.<CBaseObject3DVO>=_cabinetService.createShelterVos();
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
			if(_tableBoard)
			{
				_tableBoard.dispose();
				_tableBoard=null;
				_cabinetService.deleteTableBoards();
			}
			if(_shelter)
			{
				_shelter.dispose();
				_shelter=null;
				_cabinetService.deleteShelters();
			}
			_cabinetService.deleteRoomCorners();
		}
		public function getQuotes():void
		{
			CDebugUtil.Instance.traceStr("CKithenModuleImp->getQuotes()");
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
			}
		}
		public function stop():void
		{
			if(_isRunning)
			{
				_isRunning=false;
				clear();
			}
		}
		public function updateByFrame(startTime:Number=0,frameTime:Number=0):void
		{
			if(getTimer()-startTime<frameTime)
			{
				//TODO:
			}
		}
	}
}