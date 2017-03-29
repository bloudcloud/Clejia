package model
{
	import flash.geom.Vector3D;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.utils.CDebug;
	
	import collection.Furniture3DList;
	
	import interfaces.ICFurnitureModel;
	
	import model.vo.CFurnitureVO;
	
	import ns.cloudLib;

	use namespace cloudLib;
	/**
	 *  
	 * @author cloud
	 */
	public class HangingCabinetModel implements ICFurnitureModel
	{
		private var _furnitureVos:Vector.<CFurnitureVO>;
		private var _selectVo:CFurnitureVO;
		private var _isDirectionChanged:Boolean;
		private var _state:uint;
		private var _selectVoPosition:Vector3D;
		private var _rootList:Furniture3DList;
		
		public function HangingCabinetModel()
		{
			_furnitureVos=new Vector.<CFurnitureVO>();
		}
		
		private function getFurnitureVo(uniqueID:String,direction:int):CFurnitureVO
		{
			var vo:CFurnitureVO;
			for each(vo in _furnitureVos)
			{
				if(vo.uniqueID==uniqueID)
					return vo;
			}
			return null;
		}
		private function getFurnitureVoList(direction:int):Furniture3DList
		{
			for(var list:Furniture3DList=_rootList; list!=null; list=list.next as Furniture3DList)
			{
				if(list.direction==direction)
					return list;
			}
			return null;
		}
		
		/**
		 * 执行移动处理
		 * @param furnitureDir 家具的方向
		 * @param position	家具的最新坐标
		 * @return Vector.<ICData>
		 * 
		 */		
		public function excuteMove(furnitureDir:int,position:Vector3D):Vector.<ICData>
		{
			_state=KitchenGlobalModel.instance.STATE_MOUSEMOVE;
			var vos:Vector.<ICData>;
			var list:Furniture3DList=getFurnitureVoList(furnitureDir);
			if(_selectVo.direction!=furnitureDir)
			{
				list.canSorption=true;
				_selectVo.direction=furnitureDir;
			}
			_selectVo.position.copyFrom(position);
			_selectVo.position.z=KitchenGlobalModel.instance.HANGING_Z;
			CDebug.instance.traceStr("_selectVo.position.z",_selectVo.position.z);
			vos=list.excuteSorption(_selectVo,true);
			if(list.isFull)
			{
				vos=list.addByMapList(_selectVo);
			}
			return vos;
		}
		/**
		 * 执行鼠标按下处理  
		 * @param furnitureID
		 * @param furnitureDir
		 * @return Boolean
		 * 
		 */	 		
		public function excuteMouseDown(furnitureID:String,furnitureDir:int):Boolean
		{
			_state=KitchenGlobalModel.instance.STATE_MOUSEDOWN;
			var vo:CFurnitureVO=getFurnitureVo(furnitureID,furnitureDir);
			if(vo==null) KitchenErrorModel.instance.throwErrorForNull("CabinetModel2","excuteMouseDown","vo");
			var list:Furniture3DList=getFurnitureVoList(vo.direction);
			if(vo.mark)
			{
				//选中已加入链表的数据,然后移除
				list.remove(vo);
			}
			_selectVo=vo;
			_selectVoPosition=_selectVo.position;
			return true;
		}
		/**
		 * 执行鼠标释放处理 
		 * @return Vector.<ICData>
		 * 
		 */		
		public function excuteMouseUp():Vector.<ICData>
		{
			_state=KitchenGlobalModel.instance.STATE_MOUSEUP;
			var list:Furniture3DList=getFurnitureVoList(_selectVo.direction);
			var vos:Vector.<ICData>;
			if(!list.judgeFull(_selectVo))
			{
				vos=list.add(_selectVo);
			}
			else 
			{
				vos=list.addByMapList(_selectVo);
			}
			return vos;
		}
		
		public function excuteEnd():void
		{
			var list:Furniture3DList=getFurnitureVoList(_selectVo.direction);
			switch(_state)
			{
				case KitchenGlobalModel.instance.STATE_MOUSEMOVE:
				case KitchenGlobalModel.instance.STATE_MOUSEUP:
					list.clear();
					(list.prev as Furniture3DList).clear();
					(list.next as Furniture3DList).clear();
					break;
			}
			_selectVo=null;
			_state=KitchenGlobalModel.instance.STATE_DEFAULT;
		}
		public function createFurnitureVo(furnitureID:String,furnitureDirection:int,furnitureType:uint,length:uint,width:uint,height:uint):void
		{
			var vo:CFurnitureVO = new CFurnitureVO();
			vo.uniqueID = furnitureID;
			vo.direction = furnitureDirection;
			vo.type = furnitureType;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			_furnitureVos.push(vo);
		}
		
		public function deleteFurnitureVo(furnitureID:String,furnitureDirection:int):void
		{
			var vo:CFurnitureVO=getFurnitureVo(furnitureID,furnitureDirection);
			if(vo.mark)
			{
				getFurnitureVoList(vo.direction).remove(vo);
			}
			vo.clear();
		}
		
		public function initModel():void
		{
			//初始化单循环双向链表结构
			_rootList=new Furniture3DList(0);
			KitchenGlobalModel.instance.initKitchen(_rootList);
		}
	}
}


