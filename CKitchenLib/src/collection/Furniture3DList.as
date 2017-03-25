package collection
{
	import flash.geom.Vector3D;
	
	import cloud.core.collections.DoubleListNode;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	
	import model.KitchenGlobalModel;
	import model.vo.CFurnitureListVO;
	import model.vo.CFurnitureVO;
	
	import ns.cloudLib;
	
	use namespace cloudLib;
	/**
	 *  家具数据对象双向链表
	 * @author cloud
	 */
	public class Furniture3DList extends DoubleListNode
	{
		private var _invalidFix:Boolean;
		private var _invalidPosition:Boolean;
		private var _canSorption:Boolean;
//		private var _direction:int;
//		private var _length:Number=0;
//		private var _width:Number=0;
//		private var _height:Number=0;
		private var _lastWidth:Number=0;
		private var _lastHeight:Number=0;
		//一段节点的长度
		private var _tmpLength:Number=0;
		
		public function get listVo():CFurnitureListVO
		{
			return _data as CFurnitureListVO;
		}
		
		public function get canSorption():Boolean
		{
			return _canSorption;
		}
		public function set canSorption(value:Boolean):void
		{
			_canSorption=value;
		}
		public function get direction():int
		{
			return listVo.direction;
		}
		public function get width():Number
		{
			if(_invalidChildren)
			{
				updateNodeSize();
			}
			return listVo.width;
		}
		public function get length():Number
		{
			if(_invalidChildren)
			{
				updateNodeSize();
			}
			return listVo.length;
		}
		public function get height():Number
		{
			if(_invalidChildren)
			{
				updateNodeSize();
			}
			return listVo.height;
		}
		private function get headList():Furniture3DList
		{
			return _prev as Furniture3DList
		}
		
		private function get endList():Furniture3DList
		{
			return _next as Furniture3DList;
		}

		final private function get currentFurniture():FurnitureNode
		{
			return _currentNode as FurnitureNode;
		}
		
		public function Furniture3DList(direction:int)
		{
			_data=new CFurnitureListVO();
			listVo.direction=direction;
		}
		/**
		 * map回调函数，计算一段链表中的节点总长度，返回值为true就中断遍历 
		 * @param node	当前的节点
		 * @param isNext	遍历顺序是否向下
		 * @return Boolean
		 * 
		 */		
		private function doCalculateLength(node:FurnitureNode,isNext:Boolean):Boolean
		{
			_tmpLength+=node.furnitureVo.length;
			return false;
		}
		private function doUpdateNodeSize(vo:CFurnitureVO):void
		{
			listVo.length+=vo.length;
			if(_lastWidth<vo.width) 
			{
//				_invalidFix=true;
				_lastWidth=vo.width;
			}
			if(_lastHeight<vo.height) _lastHeight=vo.height;
		}
		private function doFixPosition(vo:CFurnitureVO):void
		{
			if(KitchenGlobalModel.instance.fixPostion(vo,this) && _changedVos.indexOf(vo)<0)
				_changedVos.push(vo);
		}
		private function doUpdatePosition(node:FurnitureNode,isNext:Boolean):Boolean
		{
			var otherNode:FurnitureNode=isNext ? node.prev as FurnitureNode : node.next as FurnitureNode;
			
			if(node==null)
			{
				//节点为空，中断更新
				return true;
			}
			else if(otherNode==null)
			{
				KitchenGlobalModel.instance.setRootPosition(node.furnitureVo,this,isNext);
				_changedVos.push(node.furnitureVo);
			}
			else if(KitchenGlobalModel.instance.doUpdatePosByDistance(node.furnitureVo,otherNode.furnitureVo,isNext))
			{
				_changedVos.push(node.furnitureVo);
			}
			else if(KitchenGlobalModel.instance.fixPostion(node.furnitureVo,this) && _changedVos.indexOf(node.furnitureVo)<0)
			{
				_changedVos.push(node.furnitureVo);
			}
			return false;
		}
		private function canSorptionByDistance(sourceVo:CFurnitureVO,targetVo:CFurnitureVO):Boolean
		{
			var distance:Number;
			var dis:Number;
			distance=Vector3D.distance(sourceVo.position,targetVo.position);
			dis=KitchenGlobalModel.instance.SORPTION_RADIUS;
			return distance<=dis;
		}
		/**
		 * 判断当前节点与源节点数据的距离，决定是否执行吸附操作   
		 * @param opreateVo	
		 * @param node
		 * @param isNext
		 * @return FurnitureNode	返回吸附节点
		 * 
		 */						
		private function doJudgeSorption(source:CFurnitureVO,node:FurnitureNode,isNext:Boolean):FurnitureNode
		{
			if(canSorptionByDistance(source,node.furnitureVo))
			{
				if(_canSorption)
				{
					_canSorption=false;
					return node;
				}
			}
			else if(!_canSorption)
			{
				//距离达不到吸附要求,吸附标记为true
				_canSorption=true;
			}
			return null;
		}
		protected function updateNodeSize():void
		{
			_invalidChildren=false;
			listVo.length=0;
			_lastWidth=0;
			_lastHeight=0;
			forEachNode(doUpdateNodeSize);
			if(width!=_lastWidth)
			{
				//最大宽度发生改变
				_invalidFix=true;
				listVo.width=_lastWidth;
			}
			if(height!=_lastHeight)
			{
				//最大高度发生改变
				listVo.height=_lastHeight;
			}
		}
		/**
		 * 更新位置 
		 * 
		 */		
		protected function updateNodePosition(isNext:Boolean):void
		{
			_invalidPosition=false;
			var isNeedReverse:Boolean;
			var otherNode:FurnitureNode;
			if(_currentNode!=null)
			{
				otherNode=isNext?_currentNode.prev as FurnitureNode:_currentNode.next as FurnitureNode;
				if(otherNode!=null)
				{
					mapNode(otherNode,doCalculateLength,isNext);
					//在当前添加顺序下不能添加节点数据时（家具在该位置放不下），需反向遍历，更新家具数据的坐标
					isNeedReverse=KitchenGlobalModel.instance.isNeedReverse(otherNode.furnitureVo,_tmpLength,this,isNext);
					if(!isNeedReverse)
						//按照当前遍历顺序，刷新坐标
						mapNode(_currentNode,doUpdatePosition,isNext);
					else
						//反向遍历，刷新坐标
						mapNode(isNext?_endNode:_headNode,doUpdatePosition,!isNext);
				}
			}
		}
		cloudLib function updateNodeFixPosition(isNext:Boolean):void
		{
			//修正所有家具位置坐标
			_invalidFix=false;
			forEachNode(doFixPosition,isNext);
		}
		/**
		 * 链表是否已满 
		 * @param sourceVo
		 * @return Boolean
		 * 
		 */		
		public function judgeFull(sourceVo:CFurnitureVO):Boolean
		{
			return headList.width+endList.width+sourceVo.length+length>=Vector3D.distance(listVo.headPos,listVo.endPos);
		}
		private var updatePosNum:uint;
		private var clearNum:uint;
		public function clearStore():void
		{
			_changedVos.length=0;
			_tmpLength=0;
			 _canSorption=false;
		}
		/**
		 * 执行吸附逻辑 
		 * @param sourceVo
		 * @param isDirectionChanged	源数据的方向是否发生过改变
		 * @return Vector.<ICData>
		 * 
		 */		
		public function excuteSorption(sourceVo:CFurnitureVO,isDirectionChanged:Boolean):Vector.<ICData>
		{
			_canSorption=isDirectionChanged;
			//只有根节点时，不执行吸附，返回空
			if(_headNode==null || (numberChildren==1 && sourceVo==_headNode.nodeData)) return null;
			if(numberChildren>0)
			{
				var isNext:Boolean=sourceVo.compare(_currentNode.nodeData)<0;
				var targetNode:FurnitureNode=compareFromNow(sourceVo,doJudgeSorption,isNext);
				if(targetNode!=null)
				{
					//执行吸附操作,更新链表
					if(!judgeFull(sourceVo))
					{
						//开启吸附的状态下，执行吸附操作
						isNext=sourceVo.compare(targetNode.nodeData)<0;
						doAddNode(sourceVo,targetNode,isNext);
						currentFurniture.furnitureVo.isSorpted=true;
						updateList(isNext);
					}
					else
					{
						//链表已满
						_isFullState=true;
					}
				}
			}
			return _changedVos.length>0 ? _changedVos : null;
		}
		/**
		 * 遍历所有相连链表，添加家具数据，如果添加成功，返回发生变动的所有家具数据集合
		 * @param sourceVo
		 * @return Vector.<ICData> 发生变动的所有家具数据集合
		 * 
		 */		
		public function addByMapList(sourceVo:CFurnitureVO):Vector.<ICData>
		{
			var isNext:Boolean=Vector3D.distance(this.listVo.endPos,sourceVo.position)<Vector3D.distance(this.listVo.headPos,sourceVo.position);
			var list:Furniture3DList=isNext?this.endList:this.headList;
			for(;list!=this; list=isNext?list.endList:list.headList)
			{
				if(!list.isFull)
				{
					//找到链表，自动添加
					sourceVo.direction=list.direction;
					return list.add(sourceVo);
				}
			}
			return null;
		}
		override protected function createNode(nodeData:ICData):IDoubleNode
		{
			return new FurnitureNode(nodeData);
		}
		/**
		 * 更新家具链表 
		 * @param isNext
		 * 
		 */		
		override protected function updateList(isNext:Boolean=true):void
		{
			updateNodeSize();
			if(_invalidPosition)
				updateNodePosition(isNext);
			if(_invalidFix)
			{
				updateNodeFixPosition(isNext);
				KitchenGlobalModel.instance.fixNodePostionByList(this);
			}
		}
		override protected function doAddNode(opreateData:ICData, node:IDoubleNode, isNext:Boolean):Boolean
		{
			_invalidPosition=true;
			(opreateData as CFurnitureVO).mark=(opreateData as CFurnitureVO).direction.toString();
			return super.doAddNode(opreateData,node,isNext);
		}
		override protected function doRemoveNode(opreateData:ICData):void
		{
			(opreateData as CFurnitureVO).mark=null;
			super.doRemoveNode(opreateData);
		}

	}
}