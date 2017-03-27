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
		 * map回调函数，计算一段链表中的节点总长度
		 * @param node	当前的节点
		 * 
		 */		
		private function doCalculateLength(nodeData:ICData):void
		{
			_tmpLength+=(nodeData as CFurnitureVO).length;
		}
		private function doUpdateNodeSize(vo:CFurnitureVO):void
		{
			listVo.length+=vo.length;
			if(_lastWidth<vo.width) 
			{
				_lastWidth=vo.width;
			}
			if(_lastHeight<vo.height) _lastHeight=vo.height;
		}
		/**
		 * 修正某一家具节点数据 
		 * @param vo
		 * 
		 */		
		private function doFixNodePosition(vo:ICData):void
		{
			KitchenGlobalModel.instance.fixPostion(vo,this);
		}
		/**
		 *  通过节点之间的距离判断是否能够执行吸附
		 * @param sourceVo		源节点
		 * @param targetVo		目标节点
		 * @return Boolean
		 * 
		 */		
		private function judgeSorptionByDistance(sourceVo:CFurnitureVO,targetVo:CFurnitureVO):Boolean
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
			if(judgeSorptionByDistance(source,node.furnitureVo))
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
		private function judgeNeedReverse(node:IDoubleNode,isNext:Boolean):Boolean
		{
			_tmpLength=0;
			mapFromNode(node,doCalculateLength,isNext);
			return KitchenGlobalModel.instance.isNeedReverse(node.nodeData,_tmpLength,this,isNext);
		}
		/**
		 * 更新位置 
		 * 
		 */		
		protected function updateNodePosition(node:IDoubleNode,isNext:Boolean):void
		{
			_invalidPosition=false;
			
			var negativeNode:IDoubleNode;
			var positiveNode:IDoubleNode;
			
			var isNeedReverse:Boolean;
			if(node!=null)
			{
				if(isNext)
				{
					negativeNode=node.prev;
					positiveNode=node.next;
				}
				else
				{
					negativeNode=node.next;
					positiveNode=node.prev;
				}
				if(negativeNode==null && positiveNode==null)
				{
					//链表只有一个节点，不处理位置更新
					return;
				}
				if(negativeNode!=null && !judgeNeedReverse(negativeNode,isNext))
				{
					//按照当前遍历顺序，刷新坐标
					KitchenGlobalModel.instance.mapNodeToUpdatePosition(node,this,isNext);
				}
				else if(positiveNode!=null && !judgeNeedReverse(positiveNode,!isNext))
				{
					//按照相反方向遍历，刷新坐标
					KitchenGlobalModel.instance.mapNodeToUpdatePosition(node,this,!isNext);
				}
				else
				{
					//都需要反转，说明整条链从根节点开始，所有节点需要重排
					KitchenGlobalModel.instance.mapNodeToUpdatePosition(isNext?endNode:headNode,this,!isNext,true);
				}
			}
		}
		protected function fixNodePosition(isNext:Boolean):void
		{
			//修正所有家具位置坐标
			_invalidFix=false;
			forEachNode(doFixNodePosition,isNext);
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
			if(headNode==null || (numberChildren==1 && sourceVo==headNode.nodeData)) return null;
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
			return changedVos.length>0 ? changedVos : null;
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
				updateNodePosition(_currentNode,isNext);
			if(_invalidFix)
			{
				//宽度发生改变，修正链表中所有节点的坐标
				fixNodePosition(isNext);
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
		override public function clear():void
		{
			super.clear();
			_tmpLength=0;
			_canSorption=false;
		}
	}
}