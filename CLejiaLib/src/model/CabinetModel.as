package model
{
	import flash.geom.Vector3D;
	
	import mx.utils.UIDUtil;
	
	import cloud.core.collections.IDoubleList;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.interfaces.ICObject3DListData;
	import cloud.core.utils.Geometry3DUtil;
	
	import collection.Furniture3DList;
	
	import interfaces.ICFurnitureModel;
	
	import dict.Object3DDict;
	
	import model.vo.CFurnitureVO;
	import model.vo.CObject3DVO;
	import model.vo.CRoomCornerVO;
	
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
		private var _shelters:Vector.<ICObject3DData>;
		private var _tableBoards:Vector.<ICObject3DData>;
		private var _kitchenParts:Vector.<ICObject3DData>;
		private var _floorID:String;
		private var _selectList:Furniture3DList;
		private var _selectPos:Vector3D=new Vector3D();
		private var _selectRotation:Number;

		public function CabinetModel()
		{
			furnitureVos=new Vector.<ICObject3DData>();
			_corners=new Vector.<ICObject3DData>();
			_shelters=new Vector.<ICObject3DData>();
			_tableBoards=new Vector.<ICObject3DData>();
			_kitchenParts=new Vector.<ICObject3DData>();
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
				if((vo as CObject3DVO).parentID)
				{
					getFurnitureVoListByID((vo as CObject3DVO).parentID).remove(vo);
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
		private function createObject3DVo(length:Number,width:Number,height:Number,position:Vector3D,rotation:int,direction:Vector3D):ICObject3DData
		{
			var vo:ICObject3DData=new CObject3DVO();
			vo.uniqueID=UIDUtil.createUID();
			vo.type=Object3DDict.OBJECT3D_SHELTER;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.direction=direction;
			vo.rotation=rotation;
			vo.x=position.x;
			vo.y=position.y;
			vo.z=position.z;
			return vo;
		}
		/**
		 * 创建补板 
		 * @return Vector.<ICObject3DData>
		 * 
		 */		
		public function createShelterVos():Vector.<ICObject3DData>
		{
			var vo:CObject3DVO;
			getRoomCorners();
			for each(var cornerVo:CRoomCornerVO in _corners)
			{
				var length:Number,width:Number,height:Number,rotation:Number;
				var position:Vector3D=new Vector3D();
				if(cornerVo.prevLength>0)
				{
					length=cornerVo.prevLength;
					width=KitchenGlobalModel.instance.SHELTER_WIDTH;
					height=cornerVo.height;
					position.x=-cornerVo.length*.5+length*.5;
					position.y=cornerVo.width*.5-cornerVo.prevWidth+width*.5;
					position.z=0;
					position=Geometry3DUtil.transformVectorByTransform3D(position,cornerVo.transform);
					vo=createObject3DVo(length,width,height,position,cornerVo.rotation,cornerVo.direction) as CObject3DVO;
					vo.parentID=cornerVo.parentID;
					_shelters.push(vo);
				}
				if(cornerVo.nextLength>0)
				{
					length=KitchenGlobalModel.instance.SHELTER_WIDTH;
					width=cornerVo.nextLength;
					height=cornerVo.height;
					position.x=cornerVo.length*.5-cornerVo.nextWidth+length*.5;
					position.y=-cornerVo.width*.5+width*.5;
					position.z=0;
					position=Geometry3DUtil.transformVectorByTransform3D(position,cornerVo.transform);
					vo=createObject3DVo(length,width,height,position,cornerVo.rotation,cornerVo.direction) as CObject3DVO;
					vo.parentID=cornerVo.parentID;
					_shelters.push(vo);
				}
			}
			return _shelters.length>0 ? _shelters : null;
		}
		private function createTableBoardByCorner(cornerVo:CRoomCornerVO):void
		{
			var length:Number,width:Number,height:Number;
			var position:Vector3D=new Vector3D();
			if(cornerVo.prevLength>0)
			{
				length=cornerVo.length;
				width=cornerVo.prevWidth;
				height=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
				position.x=-cornerVo.length*.5+length*.5;
				position.y=cornerVo.width*.5-width*.5;
				position.z=cornerVo.height*.5+height*.5;
				position=Geometry3DUtil.transformVectorByTransform3D(position,cornerVo.transform);
				_tableBoards.push(createObject3DVo(length,width,height,position,cornerVo.rotation,cornerVo.direction));
			}
			if(cornerVo.nextLength>0)
			{
				if(_tableBoards.length>0)
				{
					width=cornerVo.nextLength;
				}
				else
				{
					width=cornerVo.width;
				}
				length=cornerVo.nextWidth;
				height=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
				position.x=cornerVo.length*.5-length*.5;
				position.y=-cornerVo.width*.5+width*.5;
				position.z=cornerVo.height*.5+height*.5;
				position=Geometry3DUtil.transformVectorByTransform3D(position,cornerVo.transform);
				_tableBoards.push(createObject3DVo(length,width,height,position,cornerVo.rotation,cornerVo.direction));
			}
		}
		private function createTableBoardByCabinet(furnitureVo:CFurnitureVO):void
		{
			var height:Number=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
			var position:Vector3D=furnitureVo.position.clone();
			position.z+=furnitureVo.height+height*.5;
			_tableBoards.push(createObject3DVo(furnitureVo.length,furnitureVo.width,height,position,furnitureVo.rotation,furnitureVo.direction));
		}
		/**
		 * 创建台面 
		 * @return Vector.<ICObject3DData>
		 * 
		 */		
		public function createTableBoards():Vector.<ICObject3DData>
		{
			getRoomCorners();
			for each(var vo:ICObject3DData in _corners)
			{
				createTableBoardByCorner(vo as CRoomCornerVO);
			}
			var furnitures:Vector.<ICObject3DData>=getFurnituresInList();
			if(furnitures)
			{
				for each(vo in furnitures)
				{
					createTableBoardByCabinet(vo as CFurnitureVO);
				}
			}
			return _tableBoards.length>0 ? _tableBoards : null;
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
		public function deleteShelters():void
		{
			for each(var vo:ICObject3DData in _shelters)
			{
				vo.clear();
			}
			_shelters.length=0;
		}
		public function deleteTableBoards():void
		{
			for each(var vo:ICObject3DData in _tableBoards)
			{
				vo.clear();
			}
			_tableBoards.length=0;
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
			var bool:Boolean;
			switch(_selectVo.type)
			{
				case Object3DDict.OBJECT3D_CABINET:
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
					bool=list.excuteSorption(_selectVo);
					break;
				case Object3DDict.OBJECT3D_BASIN:
//					if(_tableBoards.length>0)
//					{
//						//在台面上移动
//						list=KitchenGlobalModel.instance.getBestFurnitureList(_selectVo,_rootList);
//						
//						for each(var vo:CObject3DVO in _tableBoards)
//						{
//							if(vo.parentID==list.listVo.uniqueID)
//							{
//								
//							}
//						}
//					}
//					
					break;
			}
			_state=KitchenGlobalModel.instance.STATE_MOUSEMOVE;
			
			return bool;
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
			switch(vo.type)
			{
				case Object3DDict.OBJECT3D_CABINET:
					if(vo==null) KitchenErrorModel.instance.throwErrorForNull("CabinetModel","excuteMouseDown","vo");
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
					_selectPos.copyFrom(vo.position);
					_selectRotation=vo.rotation;
					break;
			}
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
			var vos:Vector.<ICData>;
			switch(_selectVo.type)
			{
				case Object3DDict.OBJECT3D_CABINET:
					var list:Furniture3DList=KitchenGlobalModel.instance.getBestFurnitureList(_selectVo,_rootList);
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
					break;
			}
			_state=KitchenGlobalModel.instance.STATE_MOUSEUP;
			return vos;
		}
		/**
		 * 执行结束 
		 * 
		 */		
		public function excuteEnd():void
		{
			switch(_selectVo.type)
			{
				case Object3DDict.OBJECT3D_CABINET:
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
					_selectPos.setTo(0,0,0);
					break;
			}
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
			_selectList=null;
			_selectPos.setTo(0,0,0);
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
			_rootList=KitchenGlobalModel.instance.initKitchenListByWall(Object3DDict.OBJECT3D_CABINET,_floorID);
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
			for each(var vo:ICObject3DData in furnitureVos)
			{
				vo.clear();
			}
			furnitureVos.length=0;
			_corners.length=0;
		}
	}
}