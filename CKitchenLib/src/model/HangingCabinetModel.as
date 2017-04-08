package model
{
	import flash.geom.Vector3D;
	
	import cloud.core.collections.IDoubleList;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	
	import collection.Furniture3DList;
	
	import interfaces.ICFurnitureModel;
	
	import model.vo.CFurnitureVO;
	import model.vo.CObject3DVO;
	
	import ns.cloudLib;

	use namespace cloudLib;
	/**
	 *  
	 * @author cloud
	 */
	public class HangingCabinetModel implements ICFurnitureModel
	{
		private var _furnitureVos:Vector.<CObject3DVO>;
		private var _selectVo:CObject3DVO;
		private var _isDirectionChanged:Boolean;
		private var _state:uint;
		private var _selectVoPosition:Vector3D;
		private var _rootList:Furniture3DList;
		private var _floorID:String;
		
		public function HangingCabinetModel()
		{
			_furnitureVos=new Vector.<CObject3DVO>();
		}
		
		private function getFurnitureVo(uniqueID:String):CObject3DVO
		{
			var vo:CObject3DVO;
			for each(vo in _furnitureVos)
			{
				if(vo.uniqueID==uniqueID)
					return vo;
			}
			return null;
		}
		private function getFurnitureVoList(mark:String):Furniture3DList
		{
			for(var list:Furniture3DList=_rootList; list!=null; list=list.next as Furniture3DList)
			{
				if(list.listVo.uniqueID==mark)
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
		public function excuteMove(furnitureDir:int,position:Vector3D):Boolean
		{
			if(_selectVo==null) return false;
			_state=KitchenGlobalModel.instance.STATE_MOUSEMOVE;
			_selectVo.rotation=furnitureDir;
			_selectVo.x=position.x;
			_selectVo.y=position.y;
			_selectVo.z=position.z;
			var list:Furniture3DList=KitchenGlobalModel.instance.getBestFurnitureList(_selectVo,_rootList);
			if(_selectVo.rotation!=furnitureDir)
			{
				//如果方向发生变化，打开最优链表中的吸附开关
				list.canSorption=true;
			}
			return list.excuteSorption(_selectVo);
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
			var vo:CFurnitureVO=getFurnitureVo(furnitureID) as CFurnitureVO;
			if(vo==null) KitchenErrorModel.instance.throwErrorForNull("CabinetModel2","excuteMouseDown","vo");
			if(vo.ownerID)
			{
				//选中已加入链表的数据,然后移除
				getFurnitureVoList(vo.ownerID).remove(vo);
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
			var list:Furniture3DList=getFurnitureVoList(_selectVo.ownerID);
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
			var list:Furniture3DList=getFurnitureVoList(_selectVo.ownerID);
			switch(_state)
			{
				case KitchenGlobalModel.instance.STATE_MOUSEMOVE:
				case KitchenGlobalModel.instance.STATE_MOUSEUP:
					list.clearCalculationData();
					(list.prev as Furniture3DList).clearCalculationData();
					(list.next as Furniture3DList).clearCalculationData();
					break;
			}
			_selectVo=null;
			_state=KitchenGlobalModel.instance.STATE_DEFAULT;
		}
		public function createFurnitureVo(furnitureID:String,furnitureDirection:int,furnitureType:uint,length:uint,width:uint,height:uint):void
		{
			var vo:CObject3DVO = new CObject3DVO();
			vo.uniqueID = furnitureID;
			vo.rotation = furnitureDirection;
			vo.type = furnitureType;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			_furnitureVos.push(vo);
		}
		
		public function deleteFurnitureVo(furnitureID:String):void
		{
			var vo:CFurnitureVO=getFurnitureVo(furnitureID) as CFurnitureVO;
			if(vo.ownerID)
			{
				getFurnitureVoList(vo.ownerID).remove(vo);
			}
			vo.clear();
		}
		
		public function initModel(floorID:String):void
		{
			//初始化单循环双向链表结构
			_floorID=floorID;
			_rootList=KitchenGlobalModel.instance.initKitchenListByWall(KitchenGlobalModel.instance.OBJECT3D_HANGING_CABINET,_floorID);
		}
		
		public function clear():void
		{
			_selectVo=null;
			var num:int;
			for(var child:IDoubleNode=_rootList; num==0 || child!=_rootList; child=child.next)
			{
				child.unlink();
				(child as IDoubleList).clear();
				num++;
			}
			_selectVoPosition=null;
			for each(var vo:CObject3DVO in _furnitureVos)
			{
				vo.clear();
			}
			_furnitureVos.length=0;
		}
	}
}


