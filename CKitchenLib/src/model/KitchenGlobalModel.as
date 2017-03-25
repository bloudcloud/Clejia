package model
{
	import flash.geom.Vector3D;
	
	import cloud.core.collections.DoubleListNode;
	import cloud.core.interfaces.ICData;
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
		 * 通过源节点数据与其相邻的节点数据，执行更新位置，返回是否需要更新
		 * @param sourceVo		源家具数据
		 * @param targetVo		吸附目标家具数据
		 * @param isNext		吸附目标数据是否在源数据下方
		 * @return Boolean	
		 * 
		 */		
		public function doUpdatePosByDistance(sourceVo:CFurnitureVO,targetVo:CFurnitureVO,isNext:Boolean):Boolean
		{
			var dis:Number=(sourceVo.length+targetVo.length)*.5;
			var posDis:Number;
			var newPos:Number;
			
			switch(targetVo.direction)
			{
				case DIR_FRONT:
				case DIR_BACK:
					posDis=Math.abs(targetVo.position.x-sourceVo.position.x);
					if(sourceVo.isSorpted==true || //当前节点已吸附
						posDis<dis //当前节点与前一节点位置过小
					)
					{
						sourceVo.position.copyFrom(targetVo.position);
						sourceVo.position.x=isNext ? targetVo.position.x-dis : targetVo.position.x+dis;
						sourceVo.isSorpted=false;
						return true;
					}
					return false;
				case DIR_LEFT:
				case DIR_RIGHT:
					posDis=Math.abs(targetVo.position.y-sourceVo.position.y);
					if(sourceVo.isSorpted==true || //当前节点已吸附
						posDis<dis //当前节点与前一节点位置过小
					)
					{
						sourceVo.position.copyFrom(targetVo.position);
						sourceVo.position.y=isNext ? targetVo.position.y-dis : targetVo.position.y+dis;
						sourceVo.isSorpted=false;
						return true;
					}
					return false;
			}
			return false;
		}
//		/**
//		 * 根据遍历顺序，获取链表两端中，某一端的限制长度 
//		 * @param list	链表
//		 * @param isNext	遍历顺序
//		 * @return Number
//		 * 
//		 */		
//		public function getLimitLength(list:Furniture3DList,isNext:Boolean):Number
//		{
//			var limitLength:Number;
//			switch(list.direction)
//			{
//				case DIR_FRONT:
//				case DIR_LEFT:
//					limitLength=isNext?(list.next as Furniture3DList).width:(list.prev as Furniture3DList).width;
//					break;
//				case DIR_BACK:
//				case DIR_RIGHT:
//					limitLength=isNext?(list.prev as Furniture3DList).width:(list.next as Furniture3DList).width;
//					break;
//			}
//			return limitLength;
//		}
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
		public function isNeedReverse(furnitureVo:CFurnitureVO,tmpLength:Number,list:Furniture3DList,isNext:Boolean):Boolean
		{
			var needReverse:Boolean;
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
		 * @param isNext
		 * @return Boolean
		 * 
		 */			
		public function fixPostion(vo:CFurnitureVO,list:Furniture3DList):Boolean
		{
			var lastX:Number;
			var lastY:Number;
			var minLimit:Number;
			var maxLimit:Number;
			switch(vo.direction)
			{
				case DIR_FRONT:
					minLimit=list.listVo.endPos.x+(list.next as Furniture3DList).width+vo.length*.5;
					maxLimit=list.listVo.headPos.x-(list.prev as Furniture3DList).width-vo.length*.5;
					lastX=vo.position.x;
					if(vo.position.x<minLimit)
						vo.position.x=minLimit;
					else if(vo.position.x>maxLimit)
						vo.position.x=maxLimit;
					lastY=vo.position.y;
					vo.position.y=leftTopWallPos.y-list.width+vo.width*.5;
					return lastX!=vo.position.x || lastY!=vo.position.y;
				case DIR_LEFT:
					minLimit=list.listVo.endPos.y+(list.next as Furniture3DList).width+vo.length*.5;
					maxLimit=list.listVo.headPos.y-(list.prev as Furniture3DList).width-vo.length*.5;
					lastY=vo.position.y;
					if(vo.position.y<minLimit)
						vo.position.y=minLimit;
					else if(vo.position.y>maxLimit)
						vo.position.y=maxLimit;
					lastX=vo.position.x;
					vo.position.x=leftTopWallPos.x+list.width-vo.width*.5;
					return lastX!=vo.position.x || lastY!=vo.position.y;
				case DIR_BACK:
					minLimit=list.listVo.headPos.x+(list.prev as Furniture3DList).width+vo.length*.5;
					maxLimit=list.listVo.endPos.x-(list.next as Furniture3DList).width-vo.length*.5;
					lastX=vo.position.x;
					if(vo.position.x<minLimit)
						vo.position.x=minLimit;
					else if(vo.position.x>maxLimit)
						vo.position.x=maxLimit;			
					lastY=vo.position.y;
					vo.position.y=leftBottomWallPos.y+list.width-vo.width*.5;
					return lastX!=vo.position.x || lastY!=vo.position.y;
				case DIR_RIGHT:
					minLimit=list.listVo.headPos.y+(list.prev as Furniture3DList).width+vo.length*.5;
					maxLimit=list.listVo.endPos.y-(list.next as Furniture3DList).width-vo.length*.5;
					lastY=vo.position.y;
					if(vo.position.y<minLimit)
						vo.position.y=minLimit;
					else if(vo.position.y>maxLimit)
						vo.position.y=maxLimit;
					lastX=vo.position.x;
					vo.position.x=rightTopWallPos.x-list.width+vo.width*.5;
					return lastX!=vo.position.x || lastY!=vo.position.y;
			}
			return true;
		}
		/**
		 * 设置根部节点的位置 
		 * @param rootVo	根部节点数据
		 * @param list	当前链表
		 * @param listWidth 链表的宽度
		 * @param isHead		是否是链表中的头节点
		 * 
		 */		
		public function setRootPosition(rootVo:CFurnitureVO,list:Furniture3DList,isHead:Boolean):void
		{
			rootVo.isSorpted=false;
			switch(rootVo.direction)
			{
				case DIR_FRONT:
					if(isHead)
					{
						rootVo.position.x=list.listVo.headPos.x-(list.prev as Furniture3DList).width-rootVo.length*.5;
					}
					else
					{
						rootVo.position.x=list.listVo.endPos.x+(list.next as Furniture3DList).width+rootVo.length*.5;
					}
					rootVo.position.y=list.listVo.endPos.y-list.width+rootVo.width*.5;
					break;
				case DIR_LEFT:
					if(isHead)
					{
						rootVo.position.y=list.listVo.headPos.y-(list.prev as Furniture3DList).width-rootVo.length*.5;
					}
					else
					{
						rootVo.position.y=list.listVo.endPos.y+(list.next as Furniture3DList).width+rootVo.length*.5;
					}
					rootVo.position.x=list.listVo.endPos.x+list.width-rootVo.width*.5;
					break;
				case DIR_BACK:
					if(isHead)
					{
						rootVo.position.x=list.listVo.endPos.x-(list.next as Furniture3DList).width-rootVo.length*.5;
					}
					else
					{
						rootVo.position.x=list.listVo.headPos.x+(list.prev as Furniture3DList).width+rootVo.length*.5;
					}
					rootVo.position.y=list.listVo.headPos.y+list.width-rootVo.width*.5;
					break;
				case DIR_RIGHT:
					if(isHead)
					{
						rootVo.position.y=list.listVo.endPos.y-(list.prev as Furniture3DList).width-rootVo.length*.5;
					}
					else
					{
						rootVo.position.y=list.listVo.headPos.y+(list.next as Furniture3DList).width+rootVo.length*.5;
					}
					rootVo.position.x=list.listVo.headPos.x-list.width+rootVo.width*.5;
					break;
			}
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
		 * 修正一条链相关的节点坐标
		 * @param list	
		 * 
		 */		
		public function fixNodePostionByList(list:Furniture3DList):void
		{
			switch(list.direction)
			{
				case DIR_FRONT:
				case DIR_RIGHT:
					(list.prev as Furniture3DList).updateNodeFixPosition(true);
					(list.next as Furniture3DList).updateNodeFixPosition(true);
					break;
				case DIR_LEFT:
				case DIR_BACK:
					(list.prev as Furniture3DList).updateNodeFixPosition(false);
					(list.next as Furniture3DList).updateNodeFixPosition(false);
					break;
			}
		}
	}
}
class SingleEnforce{}