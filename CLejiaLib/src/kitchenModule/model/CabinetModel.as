package kitchenModule.model
{

	import flash.geom.Vector3D;
	
	import mx.utils.UIDUtil;
	
	import cloud.core.collections.IDoubleList;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.datas.base.CVector;
	import cloud.core.interfaces.ICData;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CDebugUtil;
	import cloud.core.utils.CGeometry3DUtil;
	import cloud.core.utils.CVectorUtil;
	
	import kitchenModule.interfaces.ICFurnitureModel;
	import kitchenModule.model.vo.CRoomCornerVO;
	
	import main.dict.CDataTypeDict;
	import main.dict.CParamDict;
	import main.model.TaskDataModel;
	import main.model.collection.Furniture3DList;
	import main.model.vo.task.CObject3DVO;
	
	import ns.cloudLib;

	use namespace cloudLib
	/**
	 *  基础家具链表数据模型类
	 * @author cloud
	 */
	public class CabinetModel extends TaskDataModel implements ICFurnitureModel
	{
		cloudLib var furnitureVos:Vector.<CBaseObject3DVO>;
		private var _selectVo:CBaseObject3DVO;
		private var _isDirectionChanged:Boolean;
		private var _state:uint;
		private var _rootList:Furniture3DList;
		private var _corners:Vector.<CBaseObject3DVO>;
		private var _shelters:Vector.<CBaseObject3DVO>;
		private var _tableBoards:Vector.<CBaseObject3DVO>;
		private var _kitchenParts:Vector.<CBaseObject3DVO>;
		private var _floorID:String;
		private var _selectList:Furniture3DList;
		private var _selectPos:CVector;
		private var _selectDirection:CVector;
		private var _selectRotation:Number;

		public function set rootList(value:Furniture3DList):void
		{
			_rootList = value;
		}
		/**
		 * 获取房间ID 
		 * @return String
		 * 
		 */		
		public function get floorID():String
		{
			return _floorID;
		}
		public function CabinetModel()
		{
			furnitureVos=new Vector.<CBaseObject3DVO>();
			_corners=new Vector.<CBaseObject3DVO>();
			_shelters=new Vector.<CBaseObject3DVO>();
			_tableBoards=new Vector.<CBaseObject3DVO>();
			_kitchenParts=new Vector.<CBaseObject3DVO>();
			_selectPos=CVector.CreateOneInstance();
		}
		
		private function getFurnitureVo(uniqueID:String):CBaseObject3DVO
		{
			var vo:CBaseObject3DVO;
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
		private function deleteFurnitureVoByValue(vo:CBaseObject3DVO):void
		{
			if(vo.parentID)
			{
				getFurnitureVoListByID(vo.parentID).remove(vo);
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
		public function getRoomCorners():Vector.<CBaseObject3DVO>
		{
			if(_corners.length==0)
			{
				KitchenGlobalModel.instance.createRoomCorners(_rootList,_corners);
				for each(var vo:CBaseObject3DVO in _corners)
				{
					furnitureVos.push(vo);
				}
			}
			return _corners;
		}
		private function createObject3DVo(length:Number,width:Number,height:Number,posX:Number,posY:Number,posZ:Number,rotation:int):CObject3DVO
		{
			var vo:CObject3DVO=new CObject3DVO();
			vo.uniqueID=UIDUtil.createUID();
			vo.type=CDataTypeDict.OBJECT3D_SHELTER;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.rotationHeight=rotation;
			vo.x=posX;
			vo.y=posY;
			vo.z=posZ;
			return vo;
		}
		/**
		 * 创建补板 
		 * @return Vector.<ICObject3DData>
		 * 
		 */		
		public function createShelterVos():Vector.<CBaseObject3DVO>
		{
			var vo:CBaseObject3DVO;
			getRoomCorners();
			var position:CVector=CVector.CreateOneInstance();
			for each(var cornerVo:CRoomCornerVO in _corners)
			{
				var length:Number,width:Number,height:Number,rotation:Number;
				if(cornerVo.prevLength>0)
				{
					length=cornerVo.prevLength;
					width=KitchenGlobalModel.instance.SHELTER_WIDTH;
					height=cornerVo.height;
					position.x=-cornerVo.length*.5+length*.5;
					position.y=cornerVo.width*.5-cornerVo.prevWidth+width*.5;
					position.z=0;
					CGeometry3DUtil.Instance.transformVectorByCTransform3D(position,cornerVo.transform,false);
					vo=createObject3DVo(length,width,height,position.x,position.y,position.z,cornerVo.rotationHeight);
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
					CGeometry3DUtil.Instance.transformVectorByCTransform3D(position,cornerVo.transform,false);
					vo=createObject3DVo(length,width,height,position.x,position.y,position.z,cornerVo.rotationHeight);
					vo.parentID=cornerVo.parentID;
					_shelters.push(vo);
				}
			}
			position.back();
			return _shelters.length>0 ? _shelters : null;
		}
		private function createTableBoardByCorner(cornerVo:CRoomCornerVO):void
		{
			var length:Number,width:Number,height:Number;
			var position:CVector=CVector.CreateOneInstance();
			if(cornerVo.prevLength>0)
			{
				length=cornerVo.length;
				width=cornerVo.prevWidth;
				height=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
				position.x=-cornerVo.length*.5+length*.5;
				position.y=cornerVo.width*.5-width*.5;
				position.z=cornerVo.height*.5+height*.5;
				position=CGeometry3DUtil.Instance.transformVectorByCTransform3D(position,cornerVo.transform);
				_tableBoards.push(createObject3DVo(length,width,height,position.x,position.y,position.z,cornerVo.rotationHeight));
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
				position=CGeometry3DUtil.Instance.transformVectorByCTransform3D(position,cornerVo.transform);
				_tableBoards.push(createObject3DVo(length,width,height,position.x,position.y,position.z,cornerVo.rotationHeight));
			}
			position.back();
		}
		private function createTableBoardByCabinet(furnitureVo:CBaseObject3DVO):void
		{
			var height:Number=KitchenGlobalModel.instance.TABLEBOARD_HEIGHT;
			_tableBoards.push(createObject3DVo(furnitureVo.length,furnitureVo.width,height,furnitureVo.position.x,furnitureVo.position.y,furnitureVo.position.z+furnitureVo.height+height*.5,furnitureVo.rotationHeight));
		}
		/**
		 * 创建台面 
		 * @return Vector.<ICObject3DData>
		 * 
		 */		
		public function createTableBoards():Vector.<CBaseObject3DVO>
		{
			getRoomCorners();
			for each(var vo:CBaseObject3DVO in _corners)
			{
				createTableBoardByCorner(vo as CRoomCornerVO);
			}
			var furnitures:Vector.<CBaseObject3DVO>=getFurnituresInList();
			if(furnitures)
			{
				for each(vo in furnitures)
				{
					createTableBoardByCabinet(vo);
				}
			}
			return _tableBoards.length>0 ? _tableBoards : null;
		}
		/**
		 * 获取家具列表 
		 * @return Vector.<ICObject3DData>
		 * 
		 */		
		public function getFurnituresInList():Vector.<CBaseObject3DVO>
		{
			var vos:Vector.<CBaseObject3DVO>=new Vector.<CBaseObject3DVO>();
			var func:Function=function(node:IDoubleNode):void
			{
				vos.push(node.nodeData as CBaseObject3DVO);
			}
			for(var list:Furniture3DList=_rootList; list!=null; list=list.next!=_rootList ? list.next as Furniture3DList : null)
			{
				if(list.isEmpty) continue;
				list.forEachNode(func);
			}
			return vos.length>0 ? vos : null;
		}
		public function getDatasByTypeAndID(type:uint,id:String):Vector.<ICData>
		{
			return getDatasByTypeAndParentID(type,id);
		}
		/**
		 * 删除拐角数据 
		 * 
		 */		
		public function deleteRoomCorners():void
		{
			for each(var vo:CBaseObject3DVO in _corners)
			{
				deleteFurnitureVoByValue(vo);
			}
			_corners.length=0;
		}
		public function deleteShelters():void
		{
			for each(var vo:CBaseObject3DVO in _shelters)
			{
				vo.clear();
			}
			_shelters.length=0;
		}
		public function deleteTableBoards():void
		{
			for each(var vo:CBaseObject3DVO in _tableBoards)
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
				case CDataTypeDict.OBJECT3D_CABINET:
					_selectVo.rotationHeight=furnitureDir;
					_selectVo.x=position.x;
					_selectVo.y=position.y;
					_selectVo.z=position.z;
					var list:Furniture3DList=KitchenGlobalModel.instance.getBestFurnitureList(_selectVo,_rootList);
					if(_selectVo.rotationHeight!=furnitureDir)
					{
						//如果方向发生变化，打开最优链表中的吸附开关
						list.canSorption=true;
					}
					bool=list.excuteSorption(_selectVo);
					break;
				case CDataTypeDict.OBJECT3D_BASIN:
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
			var vo:CBaseObject3DVO=getFurnitureVo(furnitureID);
			switch(vo.type)
			{
				case CDataTypeDict.OBJECT3D_CABINET:
					if(vo==null) CDebugUtil.Instance.throwError("CabinetModel","excuteMouseDown","vo","为空!");
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
					CVector.Copy(_selectPos,vo.position);
					_selectRotation=vo.rotationHeight;
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
				case CDataTypeDict.OBJECT3D_CABINET:
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
						_selectVo.rotationHeight=_selectRotation;
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
				case CDataTypeDict.OBJECT3D_CABINET:
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
					CVector.Copy(_selectPos,CVector.ZERO);
					break;
			}
			_state=KitchenGlobalModel.instance.STATE_DEFAULT;
		}
		public function createFurnitureVo(furnitureID:String,furnitureDirection:int,furnitureType:uint,length:uint,width:uint,height:uint):CBaseObject3DVO
		{
			var cls:Class=CParamDict.Instance.getParamDataTypeCls(CParamDict.Instance.getTypeClassName(furnitureType));
			var vo:CBaseObject3DVO=new cls();
			vo.uniqueID = furnitureID;
			vo.type = furnitureType;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			CVectorUtil.Instance.calculateDirectionByRotation(furnitureDirection,vo.direction);
			furnitureVos.push(vo);
			_selectVo=vo;
			_selectRotation
			_selectList=null;
			CVector.Copy(_selectPos,CVector.ZERO);
			return vo;
		}
		
		public function deleteFurnitureVo(furnitureID:String):void
		{
			var vo:CBaseObject3DVO=getFurnitureVo(furnitureID);
			deleteFurnitureVoByValue(vo);
		}
		public function clear():void
		{
			_selectList=null;
			_selectPos.back();
			_selectPos=null;
			_selectVo=null;
			for(var child:IDoubleNode=_rootList; child!=null; child=child.next!=_rootList ? child.next : null)
			{
				child.unlink();
				(child as IDoubleList).clear();
			}
			for each(var vo:CBaseObject3DVO in furnitureVos)
			{
				vo.clear();
			}
			furnitureVos.length=0;
			_corners.length=0;
		}
	}
}