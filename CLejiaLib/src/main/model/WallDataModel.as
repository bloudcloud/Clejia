package main.model
{
	
	import cloud.core.datas.base.CVector;
	import cloud.core.datas.containers.CVectorContainer;
	import cloud.core.interfaces.ICData;
	import cloud.core.utils.CDebugUtil;
	import cloud.core.utils.CUtil;
	import cloud.core.utils.CVectorUtil;
	
	import main.dict.CDataTypeDict;
	import main.model.vo.CRoom3DVO;
	import main.model.vo.CWallVO;
	
	/**
	 * 墙体数据模型
	 * @author cloud
	 */
	public class WallDataModel extends BaseObject3DDataModel
	{
		private var _walls:Vector.<ICData>;
		private var _curRoomID:String;

		public function get curRoomID():String
		{
			return _curRoomID;
		}
		public function get walls():Vector.<ICData>
		{
			return _walls;
		}
		
		public function WallDataModel()
		{
		}

		override protected function initDataCache():void
		{
//			_walls=getDatasByTypeAndParentID(Object3DDict.OBJECT3D_WALL,parentID);
		}
		public function createRoomVo(uniqueID:String):void
		{
			var roomVo:CRoom3DVO=new CRoom3DVO();
			roomVo.uniqueID=uniqueID;
			roomVo.type=CDataTypeDict.OBJECT3D_ROOM;
			addShareData(roomVo);
			_curRoomID=uniqueID;
		}
		
		/**
		 *	根据地面围点，创建房间内的墙体数据集合 
		 * @param wallPoses
		 * @param parentID
		 * 
		 */		
		public function createWallVOs(wallThickness:uint,wallHeight:uint,parentID:String,dataContainer:CVectorContainer):void
		{
			if(_walls==null)
			{
				_walls=new Vector.<ICData>();
				var wallVo:CWallVO;
				var len:int=dataContainer.size;
				var next:int;
				var caculationVec:CVector=CVector.CreateOneInstance();
				for(var i:int=0; i<len; i++)
				{
					next=i+1==len?0:i+1;
					wallVo=new CWallVO();
					wallVo.parentID=parentID;
					wallVo.roomID=parentID;
					wallVo.uniqueID=CUtil.Instance.createUID();
					wallVo.type=CDataTypeDict.OBJECT3D_WALL;
					wallVo.indexIn2DMode=i;
					dataContainer.getByIndex(i,wallVo.startPos);
					dataContainer.getByIndex(next,wallVo.endPos);
					caculationVec=CVector.Substract(wallVo.endPos,wallVo.startPos);
					wallVo.length=caculationVec.length;
					wallVo.width=1;
					wallVo.height=wallHeight;
					wallVo.rotationHeight=CVectorUtil.Instance.calculateRotationByAxis(caculationVec,CVector.X_AXIS);
					CVectorUtil.Instance.calculateDirectionByRotation(wallVo.rotationHeight,wallVo.direction);
					CVector.Scale(caculationVec,.5);
					CVector.Increase(caculationVec,wallVo.startPos);
					wallVo.x=caculationVec.x;
					wallVo.y=caculationVec.y;
					wallVo.z=caculationVec.z+wallVo.height*.5;
					wallVo.isLife=true;
					addShareData(wallVo);
					_walls.push(wallVo);
					CDebugUtil.Instance.traceStr("rotation:",wallVo.rotationHeight);
				}
				caculationVec.back();
			}
		}
		/**
		 *	获取墙面上的家具数据对象集合 
		 * @param wallID	墙面的唯一ID
		 * @return Vector.<ICObject3DData>
		 * 
		 */		
		public function getFurnituresByTypeAndWallID(type:uint,wallID:String):Vector.<ICData>
		{
			return wallID==null ? null : getDatasByTypeAndParentID(type,wallID);
		}
		/**
		 * 获取父ID为墙面ID的所有家具数据对象 
		 * @param parentID
		 * @return Vector.<ICData>
		 * 
		 */		
		public function getFurnituresByWallID(parentID:String):Vector.<ICData>
		{
			return parentID==null ? null : getDatasByParentID(parentID);
		}
		
		override public function clearAll():void
		{
			super.clearAll();
			_walls.length=0;
			_walls=null;
			_curRoomID=null;
		}
	}
}