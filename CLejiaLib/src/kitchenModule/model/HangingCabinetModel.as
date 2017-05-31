package kitchenModule.model
{
	import flash.geom.Vector3D;
	
	import cloud.core.collections.IDoubleList;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	
	import kitchenModule.interfaces.ICFurnitureModel;
	import kitchenModule.model.vo.CFurnitureVO;
	
	import main.model.BaseObject3DDataModel;
	import main.model.collection.Furniture3DList;
	import main.model.vo.CObject3DVO;
	
	import ns.cloudLib;

	use namespace cloudLib;
	/**
	 *  
	 * @author cloud
	 */
	public class HangingCabinetModel extends BaseObject3DDataModel implements ICFurnitureModel
	{
		private var _furnitureVos:Vector.<CObject3DVO>;
		private var _state:uint;
		private var _rootList:Furniture3DList;
		private var _floorID:String;
		private var _selectVo:CObject3DVO;
		private var _selectList:Furniture3DList;
		private var _selectPos:Vector3D;
		private var _selectRotation:int;
		
		public function set rootList(value:Furniture3DList):void
		{
			_rootList = value;
		}
		
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
		private function getFurnitureVoListByID(listID:String):Furniture3DList
		{
			for(var list:Furniture3DList=_rootList; list!=null; list=list.next as Furniture3DList)
			{
				if(list.listVo.uniqueID==listID)
					return list;
			}
			return null;
		}
		/**
		 * 通过数据对象删除家具数据 
		 * @param vo
		 * 
		 */		
		private function deleteFurnitureVoByValue(vo:CObject3DVO):void
		{
			if(vo.parentID)
			{
				getFurnitureVoListByID(vo.parentID).remove(vo);
			}
			var index:int=_furnitureVos.indexOf(vo);
			if(index>=0)
			{
				_furnitureVos.removeAt(index);
				vo.clear();
			}
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
			_selectVo.z=position.z+KitchenGlobalModel.instance.HANGING_Z;
			var list:Furniture3DList=KitchenGlobalModel.instance.getBestFurnitureList(_selectVo,_rootList);
			if(_selectVo.rotation!=furnitureDir)
			{
				//如果方向发生变化，打开最优链表中的吸附开关
				list.canSorption=true;
			}
			else
			{
				position.copyFrom(_selectVo.position);
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
			if(vo.parentID)
			{
				//选中已加入链表的数据
				_selectList=getFurnitureVoListByID(vo.parentID);
				_selectList.remove(vo);
			}
			else
			{
				_selectList=null;
			}
			_selectPos=vo.position.clone();
			_selectRotation=vo.rotation;
			_selectVo=vo;
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
			var list:Furniture3DList=KitchenGlobalModel.instance.getBestFurnitureList(_selectVo,_rootList);
			var vos:Vector.<ICData>;
			if(!list.judgeFull(_selectVo))
			{
				vos=list.add(_selectVo);
			}
			else 
			{
				vos=list.addByMapList(_selectVo);
			}
			if(vos==null && _selectList)
			{
				//检测如果没法放置家具，恢复到初始状态
				_selectVo.rotation=_selectRotation;
				_selectVo.x=_selectPos.x;
				_selectVo.y=_selectPos.y;
				_selectVo.z=_selectPos.z;
				_selectList.add(_selectVo);
			}
			return vos;
		}
		
		public function excuteEnd():void
		{
			var list:Furniture3DList=getFurnitureVoListByID(_selectVo.parentID);
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
			_selectList=null;
			_selectPos=null;
			_state=KitchenGlobalModel.instance.STATE_DEFAULT;
		}
		public function createFurnitureVo(furnitureID:String,furnitureDirection:int,furnitureType:uint,length:uint,width:uint,height:uint):void
		{
			var vo:CFurnitureVO = new CFurnitureVO();
			vo.uniqueID = furnitureID;
			vo.type = furnitureType;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.rotation = furnitureDirection;
			_furnitureVos.push(vo);
			_selectVo=vo;
		}
		
		public function deleteFurnitureVo(furnitureID:String):void
		{
			var vo:CObject3DVO=getFurnitureVo(furnitureID);
			deleteFurnitureVoByValue(vo);
		}
		public function clear():void
		{
			_selectList=null;
			_selectPos=null;
			_selectVo=null;
			for(var child:IDoubleNode=_rootList; child!=null; child=child.next!=_rootList ? child.next : null)
			{
				child.unlink();
				(child as IDoubleList).clear();
			}
			for each(var vo:CObject3DVO in _furnitureVos)
			{
				vo.clear();
			}
			_furnitureVos.length=0;
		}
	}
}


