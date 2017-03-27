package model
{
	import flash.geom.Vector3D;
	
	import cloud.core.collections.DoubleListNode;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.interfaces.ICObject3DListData;
	
	import collection.Furniture3DList;
	
	import model.vo.CFurnitureVO;
	
	import ns.cloudLib;
	
	use namespace cloudLib;
	/**
	 *  厨房全局数据模型类
	 * @author cloud
	 */
	public class KitchenGlobalModel
	{
		private static var _instance:KitchenGlobalModel;
		cloudLib static function get instance():KitchenGlobalModel
		{
			return _instance ||= new KitchenGlobalModel(new SingleEnforce());
		}
		public const STATE_DEFAULT:uint = 0;
		public const STATE_MOUSEDOWN:uint = 1;
		public const STATE_MOUSEMOVE:uint = 2;
		public const STATE_MOUSEUP:uint = 3;
		
		public const DIR_FRONT:int = 0;
		public const DIR_BACK:int = 180;
		public const DIR_LEFT:int = 90;
		public const DIR_RIGHT:int = -90;
		
		public const MESHTYPE_DEFAULT:uint = 0;
		public const MESHTYPE_TABLEBOARD:uint = 201;
		public const MESHTYPE_SHELTER:uint = 202;
		/**
		 *	单柜 
		 */		
		public const MESHTYPE_CABINET:uint = 23;
		/**
		 * 吊柜 
		 */		
		public const MESHTYPE_HANGING_CABINET:uint = 24;
		/**
		 * 厨房部件 
		 */		
		public const MESHTYPE_SINK:uint = 25;
		/**
		 * 判断是否吸附距离 
		 */		
		public const SORPTION_RADIUS:uint = 600;
		/**
		 * 吊柜的设置高度 
		 */		
		public const HANGING_Z:uint =1500;
		/**
		 * 台面的厚度 
		 */		
		public const TABLEBOARD_HEIGHT:uint = 20;
		/**
		 * 挡板的厚度 
		 */		
		public const SHELTER_WIDTH:uint=20;
		
		private var _invalidWallPos:Boolean;
		private var _leftTopWallPos:Vector3D;
		private var _rightTopWallPos:Vector3D;
		private var _leftBottomWallPos:Vector3D;
		private var _rightBottomWallPos:Vector3D;
		private var _leftWallPos:Vector3D;
		private var _rightWallPos:Vector3D;
		private var _upWallPos:Vector3D;
		private var _downWallPos:Vector3D;
		
		public function KitchenGlobalModel(enforcer:SingleEnforce)
		{
			_leftTopWallPos=new Vector3D();
			_rightTopWallPos=new Vector3D();
			_leftBottomWallPos=new Vector3D();
			_rightBottomWallPos=new Vector3D();
			_leftWallPos=new Vector3D();
			_rightWallPos=new Vector3D();
			_upWallPos=new Vector3D();
			_downWallPos=new Vector3D();
		}
		/**
		 * 比较两个家具数据的大小 
		 * @param thisVo	当前数据
		 * @param sourceVo		比较数据
		 * @return int 
		 * 
		 */		
		public function compareFurnitureVo(thisVo:CFurnitureVO,compareVo:CFurnitureVO):Number
		{
			var compare1:Number;
			var compare2:Number;
			switch(compareVo.direction)
			{
				case DIR_FRONT:
				case DIR_BACK:
					compare1=thisVo.position.x;
					compare2=compareVo.position.x;
					break;
				case DIR_LEFT:
				case DIR_RIGHT:
					compare1=thisVo.position.y;
					compare2=compareVo.position.y;
					break;
			}
			if(compare1>compare2)
				return 1/Vector3D.distance(thisVo.position,compareVo.position);
			else if(compare1<compare2)
				return -(1/Vector3D.distance(thisVo.position,compareVo.position));
			else
				return 0;
		}
		/**
		 * 更新一条链表中从某一节点到根节点的，所有节点的数据位置 
		 * @param startNode	起始节点
		 * @param	list	节点所在的链表对象
		 * @param isNext		遍历顺序是否向下遍历
		 * @param isIgnoreCondition	是否忽略更新条件
		 * @return 
		 * 
		 */		
		public function mapNodeToUpdatePosition(startNode:IDoubleNode,list:Furniture3DList,isNext:Boolean,isIgnoreCondition:Boolean=false):void
		{
			for(var child:IDoubleNode=startNode; child!=null; child=isNext?child.next:child.prev)
			{
				var otherNode:IDoubleNode=isNext ? child.prev : child.next;
				if(child==null)
				{
					//节点为空，中断更新
					break;
				}
				else if(otherNode!=null)
				{
					if(doUpdatePosition(child.nodeData,otherNode.nodeData,isNext,isIgnoreCondition))
						list.addChangedVo(child.nodeData);
				}
				else
				{
					//根节点，修正坐标
					doUpdateRootPostion(child.nodeData,list,isNext)
				}
			}
		}
		private function doUpdateRootPostion(vo:ICData,list:Furniture3DList,isNext:Boolean):void
		{
			var rootVo:ICObject3DData=vo as ICObject3DData;
			var posX:Number;
			var posY:Number;
			posX=rootVo.position.x;
			posY=rootVo.position.y;
			switch(list.direction)
			{
				case DIR_FRONT:
					if(isNext)
					{
						rootVo.position.x=list.listVo.headPos.x-(list.prev as Furniture3DList).width-rootVo.length*.5;
					}
					else
					{
						rootVo.position.x=list.listVo.endPos.x+(list.next as Furniture3DList).width+rootVo.length*.5;
					}
					rootVo.position.y=list.listVo.headPos.y-list.width+rootVo.width*.5;
					break;
				case DIR_RIGHT:
					if(isNext)
					{
						rootVo.position.y=list.listVo.endPos.y-(list.next as Furniture3DList).width-rootVo.length*.5;
					}
					else
					{
						rootVo.position.y=list.listVo.headPos.y+(list.prev as Furniture3DList).width+rootVo.length*.5;
					}
					rootVo.position.x=list.listVo.headPos.x-list.width+rootVo.width*.5;
					break;
				case DIR_BACK:
					if(isNext)
					{
						rootVo.position.x=list.listVo.endPos.x-(list.next as Furniture3DList).width-rootVo.length*.5;
					}
					else
					{
						rootVo.position.x=list.listVo.headPos.x+(list.prev as Furniture3DList).width+rootVo.length*.5;
					}
					rootVo.position.y=list.listVo.endPos.y+list.width-rootVo.width*.5;
					break;
				case DIR_LEFT:
					if(isNext)
					{
						rootVo.position.y=list.listVo.headPos.y-(list.prev as Furniture3DList).width-rootVo.length*.5;
					}
					else
					{
						rootVo.position.y=list.listVo.endPos.y+(list.next as Furniture3DList).width+rootVo.length*.5;
					}
					rootVo.position.x=list.listVo.endPos.x+list.width-rootVo.width*.5;
			}
			if(posX!=rootVo.position.x || posY!=rootVo.position.y)
				list.addChangedVo(vo);
		}
		/**
		 * 通过与其当前节点数据相邻的来源节点数据，来执行当前节点数据的位置更新，返回当前节点数据是否发生改变
		 * @param vo1		当前数据
		 * @param vo2		来源数据
		 * @param isNext		当前遍历顺序是否向下遍历
		 * @param isIgnore	是否忽略更新条件
		 * @return Boolean	当前节点数据是否发生改变
		 * 
		 */		
		private function doUpdatePosition(vo1:ICData,vo2:ICData,isNext:Boolean,isIgnoreCondition:Boolean):Boolean
		{
			var currentVo:CFurnitureVO=vo1 as CFurnitureVO;
			var sourceVo:CFurnitureVO=vo2 as CFurnitureVO;
			var dis:Number=(currentVo.length+sourceVo.length)*.5;
			var posDis:Number;
			var posX:Number;
			var posY:Number;
			posX=currentVo.position.x;
			posY=currentVo.position.y;
			switch(sourceVo.direction)
			{
				case DIR_FRONT:
				case DIR_BACK:
					posDis=Math.abs(sourceVo.position.x-currentVo.position.x);
					if(isIgnoreCondition ||
						posDis<dis //当前节点与前一节点位置过小
					)
					{
						currentVo.position.x=isNext ? sourceVo.position.x-dis : sourceVo.position.x+dis;
					}
					currentVo.position.y=sourceVo.position.y;
					break;
				case DIR_LEFT:
				case DIR_RIGHT:
					posDis=Math.abs(sourceVo.position.y-currentVo.position.y);
					if(isIgnoreCondition ||
						posDis<dis //当前节点与前一节点位置过小
					)
					{
						currentVo.position.y=isNext ? sourceVo.position.y-dis : sourceVo.position.y+dis;
					}
					currentVo.position.x=sourceVo.position.x;
					break;
			}
			return posX!=currentVo.position.x || posY!=currentVo.position.y;
		}
		/**
		 * 根据方向和遍历顺序，获取与当前列表一端相连的链表 
		 * @param list	当前列表
		 * @param isNext
		 * @return Furniture3DList
		 * 
		 */		
		public function getRootList(currentList:Furniture3DList,isNext:Boolean):Furniture3DList
		{
			var list:Furniture3DList;
			switch(currentList.direction)
			{
				case DIR_FRONT:
				case DIR_LEFT:
					list=isNext ? currentList.next as Furniture3DList : currentList.prev as Furniture3DList;
					break;
				case DIR_BACK:
				case DIR_RIGHT:
					list=isNext ? currentList.prev as Furniture3DList : currentList.next as Furniture3DList;
					break;
			}
			return list;
		}
		/**
		 * 判断是否需要反转遍历 
		 * @param furnitureVo	用于判断的节点数据
		 * @param tmpLength		当前遍历顺序下的这段链表的总长度
		 * @param list		当前链表对象
		 * @param isNext	是否向下遍历
		 * @return Boolean
		 * 
		 */				
		public function isNeedReverse(vo:ICData,tmpLength:Number,list:Furniture3DList,isNext:Boolean):Boolean
		{
			var needReverse:Boolean;
			var furnitureVo:CFurnitureVO=vo as CFurnitureVO;
			switch(furnitureVo.direction)
			{
				case DIR_FRONT:
					if(isNext)
					{
						needReverse=tmpLength+(list.next as Furniture3DList).width-furnitureVo.length*.5>furnitureVo.position.x-list.listVo.endPos.x;
					}
					else
					{
						needReverse=tmpLength+(list.prev as Furniture3DList).width-furnitureVo.length*.5>list.listVo.headPos.x-furnitureVo.position.x;
					}
					break;
				case DIR_LEFT:
					if(isNext)
					{
						needReverse=tmpLength+(list.next as Furniture3DList).width-furnitureVo.length*.5>furnitureVo.position.y-list.listVo.endPos.y;
					}
					else
					{
						needReverse=tmpLength+(list.prev as Furniture3DList).width-furnitureVo.length*.5>list.listVo.headPos.y-furnitureVo.position.y;
					}
					break;
				case DIR_BACK:
					if(isNext)
					{
						needReverse=tmpLength+(list.prev as Furniture3DList).width-furnitureVo.length*.5>furnitureVo.position.x-list.listVo.headPos.x;
					}
					else
					{
						needReverse=tmpLength+(list.next as Furniture3DList).width-furnitureVo.length*.5>list.listVo.endPos.x-furnitureVo.position.x;
					}
				case DIR_RIGHT:
					if(isNext)
					{
						needReverse=tmpLength+(list.prev as Furniture3DList).width-furnitureVo.length*.5>furnitureVo.position.y-list.listVo.headPos.y;
					}
					else
					{
						needReverse=tmpLength+(list.next as Furniture3DList).width-furnitureVo.length*.5>list.listVo.endPos.y-furnitureVo.position.y;
					}
					break; 
			}
			return needReverse;
		}
		/**
		 * 修正列表中的家具节点数据
		 * @param vo 需修正的厨房家具节点数据
		 * @param list	当前节点所在的链表对象
		 * 
		 */			
		public function fixPostion(vo:ICData,list:Furniture3DList):void
		{
			var objectVo:ICObject3DData=vo as ICObject3DData;
			var lastX:Number;
			var lastY:Number;
			var minLimit:Number;
			var maxLimit:Number;
			var isChanged:Boolean;
			switch(objectVo.direction)
			{
				case DIR_FRONT:
					minLimit=list.listVo.endPos.x+(list.next as Furniture3DList).width+objectVo.length*.5;
					maxLimit=list.listVo.headPos.x-(list.prev as Furniture3DList).width-objectVo.length*.5;
					lastX=objectVo.position.x;
					if(objectVo.position.x<minLimit)
						objectVo.position.x=minLimit;
					else if(objectVo.position.x>maxLimit)
						objectVo.position.x=maxLimit;
					lastY=objectVo.position.y;
					objectVo.position.y=leftTopWallPos.y-list.width+objectVo.width*.5;
					isChanged= lastX!=objectVo.position.x || lastY!=objectVo.position.y;
					break;
				case DIR_LEFT:
					minLimit=list.listVo.endPos.y+(list.next as Furniture3DList).width+objectVo.length*.5;
					maxLimit=list.listVo.headPos.y-(list.prev as Furniture3DList).width-objectVo.length*.5;
					lastY=objectVo.position.y;
					if(objectVo.position.y<minLimit)
						objectVo.position.y=minLimit;
					else if(objectVo.position.y>maxLimit)
						objectVo.position.y=maxLimit;
					lastX=objectVo.position.x;
					objectVo.position.x=leftTopWallPos.x+list.width-objectVo.width*.5;
					isChanged= lastX!=objectVo.position.x || lastY!=objectVo.position.y;
					break;
				case DIR_BACK:
					minLimit=list.listVo.headPos.x+(list.prev as Furniture3DList).width+objectVo.length*.5;
					maxLimit=list.listVo.endPos.x-(list.next as Furniture3DList).width-objectVo.length*.5;
					lastX=objectVo.position.x;
					if(objectVo.position.x<minLimit)
						objectVo.position.x=minLimit;
					else if(objectVo.position.x>maxLimit)
						objectVo.position.x=maxLimit;			
					lastY=objectVo.position.y;
					objectVo.position.y=leftBottomWallPos.y+list.width-objectVo.width*.5;
					isChanged= lastX!=objectVo.position.x || lastY!=objectVo.position.y;
					break;
				case DIR_RIGHT:
					minLimit=list.listVo.headPos.y+(list.prev as Furniture3DList).width+objectVo.length*.5;
					maxLimit=list.listVo.endPos.y-(list.next as Furniture3DList).width-objectVo.length*.5;
					lastY=objectVo.position.y;
					if(objectVo.position.y<minLimit)
						objectVo.position.y=minLimit;
					else if(objectVo.position.y>maxLimit)
						objectVo.position.y=maxLimit;
					lastX=objectVo.position.x;
					objectVo.position.x=rightTopWallPos.x-list.width+objectVo.width*.5;
					isChanged= lastX!=objectVo.position.x || lastY!=objectVo.position.y;
					break;
			}
			if(isChanged)
				list.addChangedVo(vo);
		}
		/**
		 * 墙的左上方顶点的位置 
		 */
		public function get leftTopWallPos():Vector3D
		{
			return _leftTopWallPos;
		}

		/**
		 * @private
		 */
		public function set leftTopWallPos(value:Vector3D):void
		{
			if(_leftTopWallPos.nearEquals(value,0.001)) return;
			_leftTopWallPos.copyFrom(value);
		}

		/**
		 * 墙的右上方顶点的位置 
		 */
		public function get rightTopWallPos():Vector3D
		{
			return _rightTopWallPos;
		}

		/**
		 * @private
		 */
		public function set rightTopWallPos(value:Vector3D):void
		{
			if(_rightTopWallPos.nearEquals(value,0.001)) return;
			_rightTopWallPos.copyFrom(value);
		}

		/**
		 * 墙的左下方顶点的位置 
		 */
		public function get leftBottomWallPos():Vector3D
		{
			return _leftBottomWallPos;
		}

		/**
		 * @private
		 */
		public function set leftBottomWallPos(value:Vector3D):void
		{
			if(_leftBottomWallPos.nearEquals(value,0.001)) return;
			_leftBottomWallPos.copyFrom(value);
		}

		/**
		 * 墙的右下方顶点的位置 
		 */
		public function get rightBottomWallPos():Vector3D
		{
			return _rightBottomWallPos;
		}

		/**
		 * @private
		 */
		public function set rightBottomWallPos(value:Vector3D):void
		{
			if(_rightBottomWallPos.nearEquals(value,0.001)) return;
			_rightBottomWallPos.copyFrom(value);
		}

		/////////////////////////////////////////////////		DoubleListNode		/////////////////////////////////////////////////
		private function setListData(listVo:ICData):void
		{
			if(listVo is ICObject3DListData)
			{
				//3D物体对象链表数据
				var listData:ICObject3DListData=listVo as ICObject3DListData;
				switch(listData.direction)
				{
					case DIR_FRONT:
						listData.headPos.copyFrom(rightTopWallPos);
						listData.endPos.copyFrom(leftTopWallPos);
						break;
					case DIR_LEFT:
						listData.headPos.copyFrom(leftTopWallPos);
						listData.endPos.copyFrom(leftBottomWallPos);
						break;
					case DIR_BACK:
						listData.headPos.copyFrom(leftBottomWallPos);
						listData.endPos.copyFrom(rightBottomWallPos);
						break;
					case DIR_RIGHT:
						listData.headPos.copyFrom(rightBottomWallPos);
						listData.endPos.copyFrom(rightTopWallPos);
						break;
				}
			}
			
		}
		/**
		 * 初始化厨房 
		 * @param rootList
		 * 
		 */		 
		public function initKitchen(rootList:DoubleListNode):void
		{
			//根据厨房墙面，初始化单循环双向链表
			setListData(rootList.nodeData);
			var list:DoubleListNode;
			var direction:int=0;
			list=rootList;
			for(var i:int=0; i<3; i++)
			{
				if(direction==180)
				{
					direction-=360;
				}
				direction+=360/4;
				list.addAfter(new Furniture3DList(direction));
				list=list.next as DoubleListNode;
				setListData(list.nodeData);
			}
			list.addAfter(rootList);
		}
		/**
		 * 修正竖直方向链表中的节点数据
		 * @param list	链表对象
		 * @param startNode	链表遍历的起始节点
		 * @param endNode		链表遍历的终止节点
		 * @param endListPos	链表遍历结束时这一端的端点位置
		 * @param endMinLimit		链表遍历终止节点与端点之间的最小限制距离
		 * @param isNext		链表的遍历顺序（是否向下遍历）
		 * 
		 */		
		private function doFixListNodeByY(list:Furniture3DList,startNode:IDoubleNode,endNode:IDoubleNode,endListPos:Vector3D,endMinLimit:Number,isNext:Boolean):void
		{
			if(!list.isEmpty)
			{
				mapNodeToUpdatePosition(startNode,list,isNext,true);
				if(Math.abs((endNode.nodeData as ICObject3DData).position.y-endListPos.y)<endMinLimit+(endNode.nodeData as ICObject3DData).length*.5)
				{
					//如果超出范围，删除尾部节点
					endNode.nodeData.isLife=false;
					list.addChangedVo(endNode.nodeData);
				}
			}
		}
		/**
		 * 修正水平方向链表中的节点数据
		 * @param list	链表对象
		 * @param startNode	链表遍历的起始节点
		 * @param endNode		链表遍历的终止节点
		 * @param endListPos	链表遍历结束时这一端的端点位置
		 * @param endMinLimit		链表遍历终止节点与端点之间的最小限制距离
		 * @param isNext		链表的遍历顺序（是否向下遍历）
		 * 
		 */		
		private function doFixListNodeByX(list:Furniture3DList,startNode:IDoubleNode,endNode:IDoubleNode,endListPos:Vector3D,endMinLimit:Number,isNext:Boolean):void
		{
			if(!list.isEmpty)
			{
				mapNodeToUpdatePosition(startNode,list,isNext,true);
				if(Math.abs((endNode.nodeData as ICObject3DData).position.x-endListPos.x)<endMinLimit)
				{
					//如果超出范围，删除尾部节点
					endNode.nodeData.isLife=false;
					list.addChangedVo(endNode.nodeData);
				}
			}
		}
		/**
		 * 修正一条链相关的节点坐标
		 * @param list	
		 * 
		 */		
		public function fixNodePostionByList(list:Furniture3DList):void
		{
			var prevList:Furniture3DList=list.prev as Furniture3DList;
			var nextList:Furniture3DList=list.next as Furniture3DList;
			var distance:Number;
			switch(list.direction)
			{
				case DIR_FRONT:
					doFixListNodeByY(prevList,prevList.headNode,prevList.endNode,prevList.listVo.headPos,(prevList.prev as Furniture3DList).width,true);
					doFixListNodeByY(nextList,nextList.headNode,nextList.endNode,nextList.listVo.endPos,(nextList.next as Furniture3DList).width,true);
					list.changedVos=list.changedVos.concat(prevList.changedVos,nextList.changedVos);
					break;
				case DIR_RIGHT:
					doFixListNodeByX(prevList,prevList.headNode,prevList.endNode,prevList.listVo.headPos,(prevList.prev as Furniture3DList).width,true);
					doFixListNodeByX(nextList,nextList.headNode,nextList.endNode,nextList.listVo.endPos,(nextList.next as Furniture3DList).width,true);
					list.changedVos=list.changedVos.concat(prevList.changedVos,nextList.changedVos);
					break;
				case DIR_LEFT:
					doFixListNodeByX(prevList,prevList.endNode,prevList.headNode,prevList.listVo.headPos,(prevList.prev as Furniture3DList).width,false);
					doFixListNodeByX(nextList,nextList.endNode,nextList.headNode,nextList.listVo.endPos,(nextList.next as Furniture3DList).width,false);
					list.changedVos=list.changedVos.concat(prevList.changedVos,nextList.changedVos);
					break;
				case DIR_BACK:
					doFixListNodeByY(prevList,prevList.endNode,prevList.headNode,prevList.listVo.headPos,(prevList.prev as Furniture3DList).width,false);
					doFixListNodeByY(nextList,nextList.endNode,nextList.headNode,nextList.listVo.endPos,(nextList.next as Furniture3DList).width,false);
					list.changedVos=list.changedVos.concat(prevList.changedVos,nextList.changedVos);
					break;
			}
		}
	}
}
class SingleEnforce{}