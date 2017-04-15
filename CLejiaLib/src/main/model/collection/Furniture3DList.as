package main.model.collection
{
	import flash.geom.Vector3D;
	
	import cloud.core.collections.DoubleListNode;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	
	import kitchenModule.model.KitchenGlobalModel;
	import kitchenModule.model.vo.CFurnitureVO;
	import main.model.vo.CObject3DListVO;
	import main.model.vo.CObject3DVO;
	
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
		
		public function get listVo():CObject3DListVO
		{
			return _data as CObject3DListVO;
		}
		
		public function get canSorption():Boolean
		{
			return _canSorption;
		}
		public function set canSorption(value:Boolean):void
		{
			_canSorption=value;
		}
		public function get rotation():int
		{
			return listVo.rotation;
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
		
		public function Furniture3DList(listVo:CObject3DListVO)
		{
			super(listVo);
		}
		/**
		 * map回调函数，计算一段链表中的节点总长度
		 * @param node	当前的节点
		 * 
		 */		
		private function doCalculateLength(node:IDoubleNode):void
		{
			_tmpLength+=(node.nodeData as CObject3DVO).length;
		}
		private function doUpdateNodeSize(node:IDoubleNode):void
		{
			var vo:ICObject3DData=node.nodeData as ICObject3DData;
			listVo.length+=vo.length;
			if(_lastWidth<vo.width) 
				_lastWidth=vo.width;
			if(_lastHeight<vo.height) 
				_lastHeight=vo.height;
		}
		/**
		 * 修正某一家具节点数据 
		 * @param node
		 * 
		 */		
		private function doFixNodePosition(node:IDoubleNode):void
		{
			KitchenGlobalModel.instance.fixPostion(node.nodeData,this);
		}
		/**
		 * 判断当前节点与源节点数据的距离，决定是否执行吸附操作   
		 * @param opreateVo	
		 * @param node
		 * @return FurnitureNode	返回吸附节点
		 * 
		 */						
		private function doJudgeSorption(source:ICData,node:IDoubleNode):IDoubleNode
		{
			if(Math.abs(source.compare(node.nodeData))<=KitchenGlobalModel.instance.SORPTION_RADIUS)
			{
				if(_canSorption)
				{
					_canSorption=false;
					return node;
				}
			}
			else if(!_canSorption)
			{
				//距离达不到吸附要求,开启吸附开关
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
				listVo.width=_lastWidth;width
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
			var nodeData:ICData
			if(node==null)
			{
				nodeData=isNext?startNode.nodeData:endNode.nodeData;
				forEachNode(doCalculateLength,isNext);
			}
			else
			{
				nodeData=node.nodeData;
				mapFromNode(node,doCalculateLength,isNext);
			}
			return KitchenGlobalModel.instance.isNeedReverse(nodeData,_tmpLength,this,isNext);
		}
		/**
		 * 更新位置 
		 * 
		 */		
		protected function updateNodePosition(node:IDoubleNode,isNext:Boolean):void
		{
			_invalidPosition=false;
			
			var reverseNode:IDoubleNode;
			var orderNode:IDoubleNode;

			var isNeedReverse:Boolean;
			if(node!=null)
			{
				if(isNext)
				{
					reverseNode=node.prev;
					orderNode=node.next;
				}
				else
				{
					reverseNode=node.next;
					orderNode=node.prev;
				}
				if(reverseNode==orderNode)
				{
					fixNodePosition(isNext);
				}
				else if(!judgeNeedReverse(reverseNode,isNext))
				{
					//不需要反转，按照当前遍历顺序，刷新坐标
					KitchenGlobalModel.instance.mapNodeToUpdatePosition(node,reverseNode,this,isNext);
				}
				else if(!judgeNeedReverse(orderNode,!isNext))
				{
					//需要反转，按照相反方向遍历，刷新坐标
					KitchenGlobalModel.instance.mapNodeToUpdatePosition(node,orderNode,this,!isNext);
				}
				else
				{
					//都需要反转，说明整条链从根节点开始，所有节点需要重排
					KitchenGlobalModel.instance.mapNodeToUpdatePosition(isNext?endNode:startNode,null,this,!isNext,true);
				}
			}
		}
		protected function fixNodePosition(isNext:Boolean):void
		{
			//修正所有家具位置坐标
			_invalidFix=false;
			forEachNode(doFixNodePosition,isNext);
			//修正相连链表的节点位置
			KitchenGlobalModel.instance.fixNodePostionByList(this);
		}
		/**
		 * 链表是否已满 
		 * @param sourceVo
		 * @return Boolean
		 * 
		 */		
		public function judgeFull(sourceVo:CObject3DVO):Boolean
		{
			return headList.width+endList.width+sourceVo.length+length>=Vector3D.distance(listVo.startPos,listVo.endPos);
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
		public function excuteSorption(sourceVo:ICData):Boolean
		{
			//只有根节点时，不执行吸附，返回空
			if(startNode==null || (numberChildren==1 && sourceVo==startNode.nodeData)) return false;
			if(numberChildren>0)
			{
				return doJudgeSorption(sourceVo,searchFromNowByCondition(sourceVo,bestCondition))!=null;
			}
			return false;
		}
		/**
		 * 遍历所有相连链表，添加家具数据，如果添加成功，返回发生变动的所有家具数据集合
		 * @param sourceVo
		 * @return Vector.<ICData> 发生变动的所有家具数据集合
		 * 
		 */		
		public function addByMapList(sourceVo:CObject3DVO):Vector.<ICData>
		{
			var isNext:Boolean=Vector3D.distance(this.listVo.endPos,sourceVo.position)<Vector3D.distance(this.listVo.startPos,sourceVo.position);
			var vos:Vector.<ICData>;
			for(var list:Furniture3DList=isNext?this.endList:this.headList;list!=this; list=isNext?list.endList:list.headList)
			{
				if(!list.isFull)
				{
					//找到链表，自动添加
					vos=list.add(sourceVo);
					break;
				}
			}
			return vos;
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
			}
		}
		override protected function doAddNode(opreateData:ICData, node:IDoubleNode):Boolean
		{
			_invalidPosition=true;
			var furnitureVo:CFurnitureVO=opreateData as CFurnitureVO;
			furnitureVo.direction=listVo.direction;
			furnitureVo.rotation=listVo.rotation;
			furnitureVo.parentID=listVo.uniqueID;
			furnitureVo.isLife=true;
			return super.doAddNode(opreateData,node);
		}
		override protected function doRemoveNode(opreateData:ICData):void
		{
			(opreateData as CFurnitureVO).parentID=null;
			super.doRemoveNode(opreateData);
		}
		override public function clearCalculationData():void
		{
			super.clearCalculationData();
			_tmpLength=0;
			_canSorption=false;
		}
		
	}
}