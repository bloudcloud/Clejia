package model
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import mx.utils.UIDUtil;
	
	import cloud.core.collections.DoubleListNode;
	import cloud.core.collections.IDoubleNode;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.utils.CDebug;
	import cloud.core.utils.Geometry3DUtil;
	import cloud.core.utils.Vector3DUtil;
	
	import collection.Furniture3DList;
	
	import interfaces.ICFurnitureModel;
	
	import dict.Object3DDict;
	
	import model.vo.CObject3DListVO;
	import model.vo.CObject3DVO;
	import model.vo.CRoomCornerVO;
	import model.vo.CWallVO;
	
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
		
		public var wallVos:Vector.<CWallVO>;
		/**
		 * 地面字典
		 */		
		private var _floorDic:Dictionary;
		private var _caculationVec:Vector3D;

		public function KitchenGlobalModel(enforcer:SingleEnforce)
		{
			wallVos=new Vector.<CWallVO>();
			_floorDic = new Dictionary(true);
			_caculationVec=new Vector3D();
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
		 * 是否拥有地面ID 
		 * @param floorID		地面ID
		 * @return Boolean
		 * 
		 */		
		public function hasFloorID(floorID:String):Boolean
		{
			return _floorDic.hasOwnProperty(floorID);
		}
		/**
		 * 解析一个房间内的所有墙的位置数据 
		 * @param wallPoses
		 * 
		 */		
		public function parseWalls(wallPoses:Vector.<Vector3D>,floorID:String):void
		{
			var wallVo:CWallVO;
			var len:int=wallPoses.length;
			var next:int;
			for(var i:int=0; i<len; i++)
			{
				next=i+1==len?0:i+1;
				wallVo=new CWallVO();
				wallVo.parentID=floorID;  
				wallVo.uniqueID=UIDUtil.createUID();
				wallVo.type=Object3DDict.OBJECT3D_WALL;
				wallVo.startPos=new Vector3D(wallPoses[i].x,wallPoses[i].y,0);
				wallVo.endPos=new Vector3D(wallPoses[next].x,wallPoses[next].y,0);
				_caculationVec=wallVo.endPos.subtract(wallVo.startPos);
				wallVo.length=_caculationVec.length;
				wallVo.width=0;
				wallVo.height=wallPoses[i].z;
				wallVo.direction=_caculationVec;
				wallVo.rotation=Vector3DUtil.calculateRotationByAxis(_caculationVec,Vector3D.X_AXIS);
				_caculationVec.scaleBy(.5);
				_caculationVec.incrementBy(wallVo.startPos);
				wallVo.x=_caculationVec.x;
				wallVo.y=_caculationVec.y;
				wallVo.z=0;
				wallVo.direction.normalize();
				wallVo.isLife=true;
				wallVos.push(wallVo);
				CDebug.instance.traceStr("rotation:",wallVo.rotation);
			}
			_floorDic[floorID]=wallVos;
		}
		
		public function getModerByDic(type:uint,dic:Dictionary):ICFurnitureModel
		{
			if(dic[type]==null)
			{
				switch(type)
				{
					case Object3DDict.OBJECT3D_BASIN:
					case Object3DDict.OBJECT3D_CABINET:
						dic[type]=new CabinetModel();
						break;
					case Object3DDict.OBJECT3D_HANGING_CABINET:
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
			var currentPos:Vector3D=Geometry3DUtil.transformVectorByTransform3D(currentVo.position,list.listVo.inverseTransform);
			var sourcePos:Vector3D=Geometry3DUtil.transformVectorByTransform3D(sourceVo.position,list.listVo.inverseTransform);
			var position:Vector3D=new Vector3D();
			_caculationVec=currentPos.subtract(sourcePos);
			
			if(isForcedUpdate || Math.abs(Vector3D.X_AXIS.dotProduct(_caculationVec))<=dis)
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
			
			position=Geometry3DUtil.transformVectorByTransform3D(position,list.listVo.transform);
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
			var furnitureVo:ICObject3DData=vo as ICObject3DData;
			var otherList:Furniture3DList;
			if(isNext)
			{
				_caculationVec=list.listVo.endPos;
				otherList=list.next as Furniture3DList;
			}
			else
			{
				_caculationVec=list.listVo.startPos;
				otherList=list.prev as Furniture3DList;
			}
			_caculationVec=_caculationVec.subtract(furnitureVo.position);
			return tmpLength+otherList.width-furnitureVo.length*.5>Math.abs(list.listVo.direction.dotProduct(_caculationVec));
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
			var minLimit:Number;
			var maxLimit:Number;
			var isChanged:Boolean;
			var startPos:Vector3D=Geometry3DUtil.transformVectorByTransform3D(list.listVo.startPos,list.listVo.inverseTransform);
			var endPos:Vector3D=Geometry3DUtil.transformVectorByTransform3D(list.listVo.endPos,list.listVo.inverseTransform);
			var position:Vector3D=Geometry3DUtil.transformVectorByTransform3D(objectVo.position,list.listVo.inverseTransform);
			
			minLimit=startPos.x+(list.prev as Furniture3DList).width+objectVo.length*.5;
			maxLimit=endPos.x-(list.next as Furniture3DList).width-objectVo.length*.5;
			if(position.x<minLimit)
				position.x=minLimit;
			else if(position.x>maxLimit)
				position.x=maxLimit;
			position.y=startPos.y-list.width+objectVo.width*.5;
			position=Geometry3DUtil.transformVectorByTransform3D(position,list.listVo.transform);
			
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
		public function initKitchenListByWall(type:uint,floorID:String):Furniture3DList
		{
			//根据厨房墙面，初始化单循环双向链表
			var list:DoubleListNode;
			var rootList:DoubleListNode;
			for(var i:int=0; i<wallVos.length; i++)
			{
				if(list==null)
				{
					rootList=list=createFurnitureListVOByWallVO(wallVos[i],type,floorID);
				}
				else
				{
					list.addAfter(createFurnitureListVOByWallVO(wallVos[i],type,floorID));
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
		private function createRoomCorner(list:Furniture3DList,corners:Vector.<ICObject3DData>):void
		{
			var nextList:Furniture3DList=list.next as Furniture3DList;
			if(!list.isEmpty && !nextList.isEmpty)
			{
				var startVo:ICObject3DData=list.endNode.nodeData as ICObject3DData;
				var endVo:ICObject3DData=nextList.startNode.nodeData as ICObject3DData;
				var startPos:Vector3D=Geometry3DUtil.transformVectorByTransform3D(startVo.position,list.listVo.inverseTransform);
				startPos.x+=startVo.length*.5;
				startPos.y+=startVo.width*.5;
				startPos.z=startVo.height*.5;
				var endPos:Vector3D=Geometry3DUtil.transformVectorByTransform3D(endVo.position,list.listVo.inverseTransform);
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
				startPos=Geometry3DUtil.transformVectorByTransform3D(startPos,list.listVo.transform);
				endPos=Geometry3DUtil.transformVectorByTransform3D(endPos,list.listVo.transform);
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
		public function createRoomCorners(list:Furniture3DList,corners:Vector.<ICObject3DData>):void
		{
			for(var current:Furniture3DList=list; current!=null; current=current.next!=list ? current.next as Furniture3DList : null)
			{
				createRoomCorner(current,corners);
			}
		}
	}
}
class SingleEnforce{}