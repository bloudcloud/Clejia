package model
{
	import flash.geom.Vector3D;
	
	import cloud.core.collections.IDoubleList;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.interfaces.ICObject3DListData;
	
	import collection.Furniture3DList;
	
	import interfaces.ICFurnitureModel;
	
	import model.vo.CFurnitureVO;
	import model.vo.CObject3DVO;
	
	import ns.cloudLib;

	use namespace cloudLib
	/**
	 *  基础家具链表数据模型类
	 * @author cloud
	 */
	public class CabinetModel implements ICFurnitureModel
	{
		cloudLib var furnitureVos:Vector.<ICObject3DData>;
		private var _selectVo:CObject3DVO;
		private var _isDirectionChanged:Boolean;
		private var _state:uint;
		private var _rootList:Furniture3DList;
		private var _corners:Vector.<ICObject3DData>;
		private var _floorID:String;
		private var _selectList:Furniture3DList;
		private var _selectPos:Vector3D;
		private var _selectRotation:Number;

		public function CabinetModel()
		{
			furnitureVos=new Vector.<ICObject3DData>();
			_corners=new Vector.<ICObject3DData>();
			
		}
		
		private function getFurnitureVo(uniqueID:String):CObject3DVO
		{
			var vo:CObject3DVO;
			for each(vo in furnitureVos)
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
		private function deleteFurnitureVoByValue(vo:ICObject3DData):void
		{
			if(vo is CObject3DVO)
			{
				if((vo as CObject3DVO).ownerID)
				{
					getFurnitureVoListByID((vo as CObject3DVO).ownerID).remove(vo);
				}
			}
			var index:int=furnitureVos.indexOf(vo);
			if(index>=0)
			{
				furnitureVos.removeAt(index);
				vo.clear();
			}
		}
		/**
		 * 获取房间拐角数据集合 
		 * @return Vector.<ICObject3DListData>
		 * 
		 */		
		public function getRoomCorners():Vector.<ICObject3DData>
		{
			if(_corners.length==0)
			{
				KitchenGlobalModel.instance.createRoomCorners(_rootList,_corners);
				for each(var vo:ICObject3DData in _corners)
				{
					furnitureVos.push(vo);
				}
			}
			return _corners;
		}
		/**
		 * 获取家具列表 
		 * @return Vector.<ICObject3DData>
		 * 
		 */		
		public function getFurnituresInList():Vector.<ICObject3DData>
		{
			var vos:Vector.<ICObject3DData>=new Vector.<ICObject3DData>();
			var func:Function=function(node:IDoubleNode):void
			{
				vos.push(node.nodeData as ICObject3DData);
			}
			for(var list:Furniture3DList=_rootList; list!=null; list=list.next!=_rootList ? list.next as Furniture3DList : null)
			{
				if(list.isEmpty) continue;
				list.forEachNode(func);
			}
			return vos.length>0 ? vos : null;
		}
		/**
		 * 删除拐角数据 
		 * 
		 */		
		public function deleteRoomCorners():void
		{
			for each(var vo:ICObject3DListData in _corners)
			{
				deleteFurnitureVoByValue(vo);
			}
			_corners.length=0;
		}
		/**
		 * 执行移动处理
		 * @param furnitureDir 家具的方向
		 * @param position	家具的最新坐标
		 * @return Boolean
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
				//选中已加入链表的数据
				_selectList=getFurnitureVoListByID(vo.ownerID);
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
		/**
		 * 执行结束 
		 * 
		 */		
		public function excuteEnd():void
		{
			var list:Furniture3DList=getFurnitureVoListByID(_selectVo.ownerID);
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
			furnitureVos.push(vo);
			_selectVo=vo;
		}
		
		public function deleteFurnitureVo(furnitureID:String):void
		{
			var vo:CObject3DVO=getFurnitureVo(furnitureID);
			deleteFurnitureVoByValue(vo);
		}
		public function initModel(floorID:String):void
		{
			//初始化单循环双向链表结构
			_floorID=floorID;
			_rootList=KitchenGlobalModel.instance.initKitchenListByWall(KitchenGlobalModel.instance.OBJECT3D_CABINET,_floorID);
		}
		
		public function clear():void
		{
			_selectList=null;
			_selectPos=null;
			_selectVo=null;
			var num:int;
			for(var child:IDoubleNode=_rootList; num==0 || child!=_rootList; child=child.next)
			{
				child.unlink();
				(child as IDoubleList).clear();
				num++;
			}
			for each(var vo:CObject3DVO in furnitureVos)
			{
				vo.clear();
			}
			furnitureVos.length=0;
			_corners.length=0;
		}
	}
}