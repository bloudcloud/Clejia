package model
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import mx.utils.UIDUtil;
	
	import cloud.core.collections.DoubleListNode;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.interfaces.ICObject3DListData;
	
	import collection.Furniture3DList;
	
	import interfaces.ICFurnitureModel;
	
	import model.vo.CFurnitureVO;
	import model.vo.CShelterVO;
	
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
		
		public function getModerByDic(type:uint,dic:Dictionary):ICFurnitureModel
		{
			if(dic[type]==null)
			{
				switch(type)
				{
					case MESHTYPE_CABINET:
						dic[type]=new CabinetModel();
						break;
					case MESHTYPE_HANGING_CABINET:
						dic[type]=new HangingCabinetModel();
						break;
					default:
						KitchenErrorModel.instance.throwErrorByMessage("CKithenModuleImp","getModel","furnitureType",String(type+" 没有获取到数据模型！"));
						break;
				}
			}
			return dic[type];
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
		 * @param startNode	当前节点
		 * @param sourceNode	源节点
		 * @param	list	节点所在的链表对象
		 * @param isNext		遍历顺序是否向下遍历
		 * @param isIgnoreCondition	是否忽略更新条件
		 * @return 
		 * 
		 */		
		public function mapNodeToUpdatePosition(currenteNode:IDoubleNode,sourceNode:IDoubleNode,list:Furniture3DList,isNext:Boolean,isIgnoreCondition:Boolean=false):void
		{
			var current:IDoubleNode=currenteNode;
			var prev:IDoubleNode=sourceNode;
			while(current!=null)
			{
				if(prev==null)
				{
					fixPostion(current.nodeData,list);
				}
				else if(doUpdatePosition(current.nodeData,prev.nodeData,isNext,isIgnoreCondition))
				{
					list.addChangedVo(current.nodeData);
				}
				prev=current;
				current=isNext?current.next:current.prev;
			}
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
		private function doUpdatePosition(vo1:ICData,vo2:ICData,isNext:Boolean,isIgnoreCondition:Boolean=false):Boolean
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
				mapNodeToUpdatePosition(startNode,null,list,isNext);
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
				mapNodeToUpdatePosition(startNode,null,list,isNext);
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
		private function doCreateShelterVo(length:Number,width:Number,height:Number,direction:int,position:Vector3D,lengthOffset:Number,positionOffset:Number):ICData
		{
			var vo:CShelterVO;
			vo=new CShelterVO();
			vo.uniqueID=UIDUtil.createUID();
			vo.type=MESHTYPE_SHELTER;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.direction=direction;
			vo.position=position;
			vo.lengthOffset=lengthOffset;
			vo.positionOffset=positionOffset;
			return vo;
		}
		private function judgeAndCreateShelterByHorizontal(vo1:ICData,vo2:ICData,shelterXHeight:Number,shelterYHeight:Number,vos:Vector.<ICData>):void
		{
			var rootNodeVo:ICObject3DData=vo1 as ICObject3DData;
			var prevRootNodeVo:ICObject3DData=vo2 as ICObject3DData;
			var dis:Number;
			var position:Vector3D;
			var positionOffset:Number;
			var lengthOffset:Number;
			if(Math.abs(rootNodeVo.position.x-prevRootNodeVo.position.x)==(rootNodeVo.length+prevRootNodeVo.width)*.5)
			{
				dis=Math.abs(rootNodeVo.position.y-prevRootNodeVo.position.y)-(rootNodeVo.width+prevRootNodeVo.length)*.5;
				if(dis>0)
				{
					lengthOffset=rootNodeVo.width;
					position=prevRootNodeVo.position.clone();
					if(rootNodeVo.position.x<prevRootNodeVo.position.x)
					{
						position.y=rootNodeVo.position.y-(rootNodeVo.width+dis)*.5;
						position.x-=(prevRootNodeVo.width-SHELTER_WIDTH)*.5;
						position.z+=shelterYHeight*.5;
						positionOffset=lengthOffset;
					}
					else
					{
						position.y=rootNodeVo.position.y+(rootNodeVo.width+dis)*.5;
						position.x+=(prevRootNodeVo.width-SHELTER_WIDTH)*.5;
						position.z+=shelterYHeight*.5;
						positionOffset=-lengthOffset;
					}
					vos.push(doCreateShelterVo(dis,SHELTER_WIDTH,shelterYHeight,prevRootNodeVo.direction,position,lengthOffset,positionOffset));
				}
			}
			if(Math.abs(rootNodeVo.position.y-prevRootNodeVo.position.y)==(rootNodeVo.width+prevRootNodeVo.length)*.5)
			{
				dis=Math.abs(rootNodeVo.position.x-prevRootNodeVo.position.x)-(rootNodeVo.length+prevRootNodeVo.width)*.5;
				if(dis>0)
				{
					lengthOffset=prevRootNodeVo.width;
					position=rootNodeVo.position.clone();
					if(rootNodeVo.position.y<prevRootNodeVo.position.y)
					{
						position.x=prevRootNodeVo.position.x+(prevRootNodeVo.width+dis)*.5;
						position.y+=(rootNodeVo.width-SHELTER_WIDTH)*.5;
						position.z+=shelterYHeight*.5;
						positionOffset=-lengthOffset;
					}
					else
					{
						position.x=prevRootNodeVo.position.x-(prevRootNodeVo.width+dis)*.5;
						position.y-=(rootNodeVo.width-SHELTER_WIDTH)*.5;
						position.z+=shelterYHeight*.5;
						positionOffset=lengthOffset;
					}
					vos.push(doCreateShelterVo(dis,SHELTER_WIDTH,shelterXHeight,rootNodeVo.direction,position,lengthOffset,positionOffset));
				}
			}
		}
		private function JudgeAndCreateShelterByVertical(vo1:ICData,vo2:ICData,shelterXHeight:Number,shelterYHeight:Number,vos:Vector.<ICData>):void
		{
			var rootNodeVo:ICObject3DData=vo1 as ICObject3DData;
			var prevRootNodeVo:ICObject3DData=vo2 as ICObject3DData;
			var dis:Number;
			var position:Vector3D;
			var lengthOffset:Number;
			var positionOffset:Number;
			if(Math.abs(rootNodeVo.position.x-prevRootNodeVo.position.x)==(rootNodeVo.width+prevRootNodeVo.length)*.5)
			{
				dis=Math.abs(rootNodeVo.position.y-prevRootNodeVo.position.y)-(rootNodeVo.length+prevRootNodeVo.width)*.5;
				if(dis>0)
				{
					position=rootNodeVo.position.clone();
					lengthOffset=prevRootNodeVo.width;
					if(rootNodeVo.position.x<prevRootNodeVo.position.x)
					{
						position.y=prevRootNodeVo.position.y-(prevRootNodeVo.width+dis)*.5;
						position.x+=(rootNodeVo.width-SHELTER_WIDTH)*.5;
						position.z+=shelterYHeight*.5;
						positionOffset=lengthOffset;
					}
					else
					{
						position.y=prevRootNodeVo.position.y+(prevRootNodeVo.width+dis)*.5;
						position.x-=(rootNodeVo.width-SHELTER_WIDTH)*.5;
						position.z+=shelterYHeight*.5;
						positionOffset=-lengthOffset;
					}
					vos.push(doCreateShelterVo(dis,SHELTER_WIDTH,shelterYHeight,rootNodeVo.direction,position,lengthOffset,positionOffset));
				}
			}
			if(Math.abs(rootNodeVo.position.y-prevRootNodeVo.position.y)==(rootNodeVo.length+prevRootNodeVo.width)*.5)
			{
				dis=Math.abs(rootNodeVo.position.x-prevRootNodeVo.position.x)-(rootNodeVo.width+prevRootNodeVo.length)*.5;
				if(dis>0)
				{
					lengthOffset=rootNodeVo.width;
					position=prevRootNodeVo.position.clone();
					if(rootNodeVo.position.y<prevRootNodeVo.position.y)
					{
						position.x=rootNodeVo.position.x+(rootNodeVo.width+dis)*.5;
						position.y-=(prevRootNodeVo.width-SHELTER_WIDTH)*.5;
						position.z+=shelterYHeight*.5;
						positionOffset=-lengthOffset;
					}
					else
					{
						position.x=rootNodeVo.position.x-(rootNodeVo.width+dis)*.5;
						position.y+=(prevRootNodeVo.width-SHELTER_WIDTH)*.5;
						position.z+=shelterYHeight*.5;
						positionOffset=lengthOffset;
					}
					vos.push(doCreateShelterVo(dis,SHELTER_WIDTH,shelterXHeight,prevRootNodeVo.direction,position,lengthOffset,positionOffset));
				}
			}
		}
		private function doCreateShelter(list:Furniture3DList,shelterVos:Vector.<ICData>):void
		{
			var prevList:Furniture3DList=list.prev as Furniture3DList;
			var prevRootNodeFurnitureVo:ICObject3DData;
			var rootNodeFurnitureVo:ICObject3DData;
			if(!prevList.isEmpty && !list.isEmpty)
			{
				switch(list.direction)
				{
					case DIR_FRONT:
						prevRootNodeFurnitureVo=prevList.headNode.nodeData as ICObject3DData;
						rootNodeFurnitureVo=list.headNode.nodeData as ICObject3DData;
						judgeAndCreateShelterByHorizontal(list.headNode.nodeData,prevList.headNode.nodeData,list.height,prevList.height,shelterVos);
						break;
					case DIR_RIGHT:
						prevRootNodeFurnitureVo=prevList.headNode.nodeData as ICObject3DData;
						rootNodeFurnitureVo=list.endNode.nodeData as ICObject3DData;
						JudgeAndCreateShelterByVertical(list.endNode.nodeData,prevList.headNode.nodeData,prevList.height,list.height,shelterVos);
						break;
					case DIR_BACK:
						prevRootNodeFurnitureVo=prevList.endNode.nodeData as ICObject3DData;
						rootNodeFurnitureVo=list.endNode.nodeData as ICObject3DData;
						judgeAndCreateShelterByHorizontal(list.endNode.nodeData,prevList.endNode.nodeData,list.height,prevList.height,shelterVos);
						break;
					case DIR_LEFT:
						prevRootNodeFurnitureVo=prevList.endNode.nodeData as ICObject3DData;
						rootNodeFurnitureVo=list.headNode.nodeData as ICObject3DData;
						JudgeAndCreateShelterByVertical(list.headNode.nodeData,prevList.endNode.nodeData,prevList.height,list.height,shelterVos);
						break;
				}
			}
			
		}
		private function doCreateTableBoardVo(length:Number,width:Number,height:Number,direction:int,position:Vector3D,vos:Vector.<ICData>):CFurnitureVO
		{
			var vo:CFurnitureVO;
			vo=new CFurnitureVO();
			vo.uniqueID=UIDUtil.createUID();
			vo.type=MESHTYPE_TABLEBOARD;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.direction=direction;
			vo.position=position;
			vos.push(vo);
			return vo;
		}
		private function judgeAndCreateTableBoard(vo1:ICData,vo2:ICData,direction:int,tableBoardLength:Number,listWidth:Number,listHeight:Number,headVo:CFurnitureVO,isIgnore:Boolean,vos:Vector.<ICData>):Boolean
		{
			var furnitureVo:CFurnitureVO=vo1 as CFurnitureVO;
			var nextFurnitureVo:CFurnitureVO=vo2 as CFurnitureVO;
			var newPosition:Vector3D;
			switch(direction)
			{
				case DIR_FRONT:
					if(isIgnore || furnitureVo.position.x-nextFurnitureVo.position.x-(furnitureVo.length+nextFurnitureVo.length)*.5>0)
					{ 
						newPosition=new Vector3D(headVo.position.x+(headVo.length-tableBoardLength)*.5,furnitureVo.position.y+Math.abs(listWidth-furnitureVo.width),furnitureVo.position.z+listHeight+TABLEBOARD_HEIGHT*.5);
						if(headVo is CShelterVO)
						{
							newPosition.x+=(headVo as CShelterVO).positionOffset;
						}
					}
					break;
				case DIR_BACK:
					if(isIgnore || furnitureVo.position.x-nextFurnitureVo.position.x>(furnitureVo.length+nextFurnitureVo.length)*.5)
					{
						newPosition=new Vector3D(headVo.position.x+(headVo.length-tableBoardLength)*.5,furnitureVo.position.y-Math.abs(listWidth-furnitureVo.width),furnitureVo.position.z+listHeight+TABLEBOARD_HEIGHT*.5);
						if(headVo is CShelterVO)
						{
							newPosition.x+=(headVo as CShelterVO).positionOffset;
						}
					}
					break;
				case DIR_RIGHT:
					if(isIgnore || furnitureVo.position.y-nextFurnitureVo.position.y>(furnitureVo.length+nextFurnitureVo.length)*.5)
					{
						newPosition=new Vector3D(furnitureVo.position.x-Math.abs(listWidth-furnitureVo.width),headVo.position.y+(headVo.length-tableBoardLength)*.5,furnitureVo.position.z+listHeight+TABLEBOARD_HEIGHT*.5);
						if(headVo is CShelterVO)
						{
							newPosition.y+=(headVo as CShelterVO).positionOffset;
						}
					}
					break;
				case DIR_LEFT:
					if(isIgnore || furnitureVo.position.y-nextFurnitureVo.position.y>(furnitureVo.length+nextFurnitureVo.length)*.5)
					{
						newPosition=new Vector3D(furnitureVo.position.x+Math.abs(listWidth-furnitureVo.width),headVo.position.y+(headVo.length-tableBoardLength)*.5,furnitureVo.position.z+listHeight+TABLEBOARD_HEIGHT*.5);
						if(headVo is CShelterVO)
						{
							newPosition.y+=(headVo as CShelterVO).positionOffset;
						}
					}
					break;
			}
			if(newPosition!=null)
			{
				doCreateTableBoardVo(tableBoardLength,listWidth,TABLEBOARD_HEIGHT,direction,newPosition,vos);
				return true;
			}
			return false;
		}
		private function doCreateTableBoard(list:Furniture3DList,shelterVos:Vector.<ICData>,tableBoardVos:Vector.<ICData>):void
		{
			var child:IDoubleNode;
			var headVo:CFurnitureVO;
			var endVo:CFurnitureVO;
			var tableBoardLength:Number=0;
			var headLengthOffset:Number;
			var headPositionOffset:Number;
			for each(var vo:CFurnitureVO in shelterVos)
			{
				if(list.direction==vo.direction)
				{
					//当前链表中有补板
					if(list.headNode.nodeData.compare(vo)<0)
					{
						headVo=vo;
					}
					else
					{
						endVo=vo;
					}
				}
			}
			if(headVo!=null)
			{
				//链表头部有补板
				tableBoardLength+=headVo.length+(headVo as CShelterVO).lengthOffset;
			}
			else
			{
				headVo=list.headNode.nodeData as CFurnitureVO;
			}
			child=list.headNode;
			
			while(child!=null)
			{
				tableBoardLength+=(child.nodeData as CFurnitureVO).length;
				if(child.next!=null)
				{
					if(judgeAndCreateTableBoard(child.nodeData,child.next.nodeData,list.direction,tableBoardLength,list.width,list.height,headVo,false,tableBoardVos))
					{
						headVo=child.next.nodeData as CFurnitureVO;
						tableBoardLength=0;
					}
				}
				else
				{
					if(endVo!=null)
					{
						tableBoardLength+=endVo.length+(endVo as CShelterVO).lengthOffset;
					}
					judgeAndCreateTableBoard(child.nodeData,null,list.direction,tableBoardLength,list.width,list.height,headVo,true,tableBoardVos)
				}
				child=child.next;
			}
		}
		
		/**
		 *  创建挡板数据集合
		 * @param list	遍历开始链表
		 * @param shelterVos	创建的挡板数据集合
		 * 
		 */		
		public function createShelterVos(list:Furniture3DList,shelterVos:Vector.<ICData>):void
		{
			var currentList:Furniture3DList=list;
			var currentIndex:int=0;
			while(!(currentIndex>0 && currentList==list))
			{
				if(!currentList.isEmpty)
				{
					doCreateShelter(currentList,shelterVos);
				}
				currentIndex++;
				currentList=currentList.next as Furniture3DList;
			}
		}
		
		public function createTableBoard(list:Furniture3DList,shelterVos:Vector.<ICData>,tableBoardVos:Vector.<ICData>):void
		{
			var currentList:Furniture3DList=list;
			var currentIndex:int=0;
			while(!(currentIndex>0 && currentList==list))
			{
				if(!currentList.isEmpty)
				{
					doCreateTableBoard(currentList,shelterVos,tableBoardVos);
				}
				currentIndex++;
				currentList=currentList.next as Furniture3DList;
			}
		}
	}
}
class SingleEnforce{}