package main.model
{
	import flash.geom.Vector3D;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.singleton.CUtil;
	import cloud.core.singleton.CVector3DUtil;
	import cloud.core.utils.CDebug;
	
	import main.dict.Object3DDict;
	import main.model.vo.CRoom3DVO;
	import main.model.vo.CWallVO;
	
	/**
	 * 墙体数据模型
	 * @author cloud
	 */
	public class WallDataModel extends BaseObject3DDataModel
	{
		private var _walls:Vector.<ICData>;

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
			roomVo.type=Object3DDict.OBJECT3D_ROOM;
			addData(roomVo);
		}
		/**
		 *	根据地面围点，创建房间内的墙体数据集合 
		 * @param wallPoses
		 * @param parentID
		 * 
		 */		
		public function createWallVOs(wallThickness:uint,wallHeight:uint,parentID:String,wallPoses:Vector.<Vector3D>):void
		{
			if(_walls==null)
			{
				_walls=new Vector.<ICData>();
				var wallVo:CWallVO;
				var len:int=wallPoses.length;
				var next:int;
				var caculationVec:Vector3D;
				var startPos:Vector
				for(var i:int=0; i<len; i++)
				{
					next=i+1==len?0:i+1;
					wallVo=new CWallVO();
					wallVo.parentID=parentID;  
					wallVo.uniqueID=CUtil.instance.createUID();
					wallVo.type=Object3DDict.OBJECT3D_WALL;
					wallVo.indexIn2DMode=i;
					wallVo.startPos=new Vector3D(wallPoses[i].x,wallPoses[i].y,0);
					wallVo.endPos=new Vector3D(wallPoses[next].x,wallPoses[next].y,0);
					caculationVec=wallVo.endPos.subtract(wallVo.startPos);
					wallVo.length=caculationVec.length;
					wallVo.width=1;
					wallVo.height=wallHeight;
					wallVo.direction=caculationVec;
					wallVo.rotation=CVector3DUtil.instance.calculateRotationByAxis(caculationVec,Vector3D.X_AXIS);
					caculationVec.scaleBy(.5);
					caculationVec.incrementBy(wallVo.startPos);
					wallVo.x=caculationVec.x;
					wallVo.y=caculationVec.y;
					wallVo.z=caculationVec.z+wallVo.height*.5;
					wallVo.direction.normalize();
					wallVo.isLife=true;
					addData(wallVo);
					_walls.push(wallVo);
					CDebug.instance.traceStr("rotation:",wallVo.rotation);
				}
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
		}
	}
}