package kitchenModule.model
{
	import flash.geom.Vector3D;
	
	import mx.utils.UIDUtil;
	
	import cloud.core.collections.DoubleListNode;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	import cloud.core.utils.Geometry3DUtil;
	
	import kitchenModule.model.vo.CRoomCornerVO;
	
	import main.dict.Object3DDict;
	import main.model.collection.Furniture3DList;
	import main.model.vo.CObject3DListVO;
	import main.model.vo.CObject3DVO;
	import main.model.vo.CWallVO;
	
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

		public function KitchenGlobalModel(enforcer:SingleEnforce)
		{
		}
		/**
		 * 根据当前家具数据，获取最优双向链表 
		 * @param furnitureVo	当前家具数据
		 * @param rootList	循环双向链表对象
		 * @return Furniture3DList
		 * 
		 */		
		public function getBestFurnitureList(furnitureVo:CObject3DVO,rootList:Furniture3DList):Furniture3DList
		{
			var bestList:Furniture3DList;
			var bestDistance:Number=int.MAX_VALUE;
			var distance:Number;
			for(var list:Furniture3DList=rootList; list!=null; list=list.next!=rootList ? list.next as Furniture3DList : null)
			{
				if(list.listVo.rotation==furnitureVo.rotation)
				{
					distance=Math.abs(furnitureVo.compare(list.listVo));
					if(distance==0) return list;
					if(distance<bestDistance)
					{
						bestDistance=distance;
						bestList=list;
					}
				}
			}
			return bestList;
		}
		/**
		 * 更新一条链表中从某一节点到根节点的，所有节点的数据位置 
		 * @param currenteNode	当前节点
		 * @param sourceNode	源节点
		 * @param	list	节点所在的链表对象
		 * @param isNext		遍历顺序是否向下遍历
		 * @param isForcedUpdate	是否忽略更新条件
		 * 
		 */		
		public function mapNodeToUpdatePosition(currenteNode:IDoubleNode,sourceNode:IDoubleNode,list:Furniture3DList,isNext:Boolean,isForcedUpdate:Boolean=false):void
		{
			var current:IDoubleNode=currenteNode;
			var other:IDoubleNode=sourceNode;
			while(current!=null)
			{
				if(other==null)
				{
					//从根节点开始修正坐标
					fixPostion(current.nodeData,list);
				}
				else
				{
					doUpdatePosition(current.nodeData,other.nodeData,list,isNext,isForcedUpdate)
				}
				other=current;
				current=isNext?current.next:current.prev;
			}
		}
		/**
		 * 通过与其当前节点数据相邻的来源节点数据，来执行当前节点数据的位置更新，返回当前节点数据是否发生改变
		 * @param vo1		当前数据
		 * @param vo2		来源数据
		 * @param list	节点所在的双向链表对象
		 * @param isNext		当前遍历顺序是否向下遍历
		 * @param isForcedUpdate	是否强制更新
		 * @return Boolean	当前节点数据是否发生改变
		 * 
		 */		
		private function doUpdatePosition(vo1:ICData,vo2:ICData,list:Furniture3DList,isNext:Boolean,isForcedUpdate:Boolean=false):Boolean
		{
			var currentVo:CObject3DVO=vo1 as CObject3DVO;
			var sourceVo:CObject3DVO=vo2 as CObject3DVO;
			var dis:Number=(currentVo.length+sourceVo.length)*.5;
			var currentPos:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(currentVo.position,list.listVo.inverseTransform);
			var sourcePos:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(sourceVo.position,list.listVo.inverseTransform);
			var position:Vector3D=new Vector3D();
			var caculationVec:Vector3D;
			caculationVec=currentPos.subtract(sourcePos);
			
			if(isForcedUpdate || Math.abs(Vector3D.X_AXIS.dotProduct(caculationVec))<=dis)
			{
				position.x=isNext ? sourcePos.x+dis : sourcePos.x-dis;
			}
			else 
			{
				dis=Vector3D.distance(list.listVo.startPos,list.listVo.endPos);
				if(currentPos.x<-dis*.5+(list.prev as Furniture3DList).width+currentVo.length*.5)
					position.x=-dis*.5+(list.prev as Furniture3DList).width+currentVo.length*.5;
				else if(currentPos.x>dis*.5-(list.next as Furniture3DList).width-currentVo.length*.5)
					position.x=dis*.5-(list.next as Furniture3DList).width-currentVo.length*.5;
			}
			position.y=sourcePos.y-list.width*.5+currentVo.width*.5;
			
			position=Geometry3DUtil.instance.transformVectorByCTransform3D(position,list.listVo.transform);
			currentVo.x=position.x;
			currentVo.y=position.y;
			if(currentVo.invalidPosition)
			{
				list.addChangedVo(currentVo);
				return true;
			}
			return false;
		}
		/**
		 * 判断是否需要反转遍历 
		 * @param furnitureVo	用于判断的节点数据
		 * @param tmpLength		当前遍历顺序下的这段链表的总长度
		 * @param list		当前链表对象
		 * @param isNext	是否向下遍历
		 * @return Boolean 是否需要反转
		 * 
		 */				
		public function isNeedReverse(vo:ICData,tmpLength:Number,list:Furniture3DList,isNext:Boolean):Boolean
		{
			var furnitureVo:CObject3DVO=vo as CObject3DVO;
			var otherList:Furniture3DList;
			var caculationVec:Vector3D;
			if(isNext)
			{
				caculationVec=list.listVo.endPos;
				otherList=list.next as Furniture3DList;
			}
			else
			{
				caculationVec=list.listVo.startPos;
				otherList=list.prev as Furniture3DList;
			}
			caculationVec=caculationVec.subtract(furnitureVo.position);
			return tmpLength+otherList.width-furnitureVo.length*.5>Math.abs(list.listVo.direction.dotProduct(caculationVec));
		}
		/**
		 * 修正列表中的家具节点数据
		 * @param vo 需修正的厨房家具节点数据
		 * @param list	当前节点所在的链表对象
		 * 
		 */			
		public function fixPostion(vo:ICData,list:Furniture3DList):void
		{
			var objectVo:CObject3DVO=vo as CObject3DVO;
			var minLimit:Number;
			var maxLimit:Number;
			var isChanged:Boolean;
			var startPos:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(list.listVo.startPos,list.listVo.inverseTransform);
			var endPos:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(list.listVo.endPos,list.listVo.inverseTransform);
			var position:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(objectVo.position,list.listVo.inverseTransform);
			
			minLimit=startPos.x+(list.prev as Furniture3DList).width+objectVo.length*.5;
			maxLimit=endPos.x-(list.next as Furniture3DList).width-objectVo.length*.5;
			if(position.x<minLimit)
				position.x=minLimit;
			else if(position.x>maxLimit)
				position.x=maxLimit;
			position.y=startPos.y-list.width+objectVo.width*.5;
			position=Geometry3DUtil.instance.transformVectorByCTransform3D(position,list.listVo.transform);
			
			objectVo.x=position.x;
			objectVo.y=position.y;
			objectVo.z=position.z;
			if(objectVo.invalidPosition)
				list.addChangedVo(vo);
		}
		/////////////////////////////////////////////////		DoubleListNode		/////////////////////////////////////////////////
		/**
		 * 通过墙数据创建家具双向链表 
		 * @param wallVo
		 * @param type
		 * @param floorID
		 * @return Furniture3DList
		 * 
		 */		
		private function createFurnitureListVOByWallVO(wallVo:CWallVO,type:uint,floorID:String):Furniture3DList
		{
			var listData:CObject3DListVO=new CObject3DListVO();
			listData.isLife=true;
			listData.parentID=floorID;
			listData.uniqueID=UIDUtil.createUID();
			listData.type=type;
			listData.length=0;
			listData.width=0;
			listData.height=0;
			listData.startPos=wallVo.startPos;
			listData.endPos=wallVo.endPos;
			listData.direction=wallVo.direction;
			listData.rotation=wallVo.rotation;
			listData.x=wallVo.x;
			listData.y=wallVo.y;
			listData.z=wallVo.z;
			return new Furniture3DList(listData);
		}
		/**
		 * 根据家具类型，初始化厨房模块内的双向链表
		 * @param type	家具类型
		 * @param floorID	地面ID
		 * @return Furniture3DList
		 * 
		 */		 
		public function initKitchenListByWalls(type:uint,walls:Vector.<ICData>):Furniture3DList
		{
			//根据厨房墙面，初始化单循环双向链表
			var list:DoubleListNode;
			var rootList:DoubleListNode;
			for(var i:int=0; i<walls.length; i++)
			{
				if(list==null)
				{
					rootList=list=createFurnitureListVOByWallVO(walls[i] as CWallVO,type,walls[i].parentID);
				}
				else
				{
					list.addAfter(createFurnitureListVOByWallVO(walls[i] as CWallVO,type,walls[i].parentID));
					list=list.next as DoubleListNode;
				}
			}
			list.addAfter(rootList);
			return rootList as Furniture3DList;
		}
		
		private function doFixListAllNode(list:Furniture3DList,startNode:IDoubleNode,endNode:IDoubleNode,isNext:Boolean):void
		{
			if(!list.isEmpty)
			{
				if(!isNeedReverse(startNode.nodeData,list.length,list,isNext))
				{
					//不需要反转,能够更新
					mapNodeToUpdatePosition(startNode,null,list,isNext);
				}
				else if(isNeedReverse(endNode.nodeData,list.length,list,!isNext))
				{
					//需要反转,反向后能够更新
					mapNodeToUpdatePosition(endNode,null,list,!isNext);
				}
				else
				{
					//如果超出范围，删除尾部节点
					(endNode.nodeData as CObject3DVO).isLife=false;
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
			doFixListAllNode(prevList,prevList.endNode,prevList.startNode,false);
			doFixListAllNode(nextList,nextList.startNode,nextList.endNode,true);
			list.changedVos=list.changedVos.concat(prevList.changedVos,nextList.changedVos);
		}

		private function doCreateRoomCornerVO(length:Number,width:Number,height:Number,prevLength:Number,prevWidth:Number,nextLength:Number,nextWidth:Number,rotation:int,direction:Vector3D,startPos:Vector3D,endPos:Vector3D):CRoomCornerVO
		{
			var vo:CRoomCornerVO;
			vo=new CRoomCornerVO();
			vo.uniqueID=UIDUtil.createUID();
			vo.type=Object3DDict.OBJECT3D_ROOMCORNER;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.prevLength=prevLength;
			vo.prevWidth=prevWidth;
			vo.nextLength=nextLength;
			vo.nextWidth=nextWidth;
			vo.rotation=rotation;
			vo.direction=direction;
			vo.startPos=startPos;
			vo.endPos=endPos;
			var vec:Vector3D=endPos.subtract(startPos);
			vec.scaleBy(.5);
			vec.incrementBy(startPos);
			vo.x=vec.x;
			vo.y=vec.y;
			vo.z=vec.z;
			return vo;
		}
		private function createRoomCorner(list:Furniture3DList,corners:Vector.<CObject3DVO>):void
		{
			var nextList:Furniture3DList=list.next as Furniture3DList;
			if(!list.isEmpty && !nextList.isEmpty)
			{
				var startVo:CObject3DVO=list.endNode.nodeData as CObject3DVO;
				var endVo:CObject3DVO=nextList.startNode.nodeData as CObject3DVO;
				var startPos:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(startVo.position,list.listVo.inverseTransform);
				startPos.x+=startVo.length*.5;
				startPos.y+=startVo.width*.5;
				startPos.z=startVo.height*.5;
				var endPos:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(endVo.position,list.listVo.inverseTransform);
				endPos.x+=endVo.width*.5;
				endPos.y+=endVo.length*.5;
				endPos.z=endVo.height*.5;
				//创建拐角数据对象
				var length:Number=endPos.x-startPos.x;
				var width:Number=startPos.y-endPos.y;
				var height:Number=Math.max(startVo.height,endVo.height);
				var prevWidth:Number=startVo.width;
				var nextWidth:Number=endVo.width;
				var prevLength:Number=length-nextWidth;
				var nextLength:Number=width-prevWidth;
				//转换成真实坐标
				startPos=Geometry3DUtil.instance.transformVectorByCTransform3D(startPos,list.listVo.transform);
				endPos=Geometry3DUtil.instance.transformVectorByCTransform3D(endPos,list.listVo.transform);
				var cornerVo:CRoomCornerVO=doCreateRoomCornerVO(length,width,height,prevLength,prevWidth,nextLength,nextWidth,startVo.rotation,startVo.direction,startPos,endPos);
				cornerVo.parentID=list.listVo.uniqueID;
				cornerVo.parentTransform=list.listVo.transform;
				cornerVo.parentInverseTransform=list.listVo.inverseTransform;
				corners.push(cornerVo);
			}
		}
		/**
		 * 遍历一次循环双向链表,创建拐角数据对象集合
		 * @param list	循环双向链表对象
		 * @param corners	房间拐角数据对象集合
		 * 
		 */		
		public function createRoomCorners(list:Furniture3DList,corners:Vector.<CObject3DVO>):void
		{
			for(var current:Furniture3DList=list; current!=null; current=current.next!=list ? current.next as Furniture3DList : null)
			{
				createRoomCorner(current,corners);
			}
		}
	}
}
class SingleEnforce{}