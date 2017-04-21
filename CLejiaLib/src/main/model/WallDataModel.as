package main.model
{
	import flash.geom.Vector3D;
	
	import mx.utils.UIDUtil;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.utils.CDebug;
	import cloud.core.utils.Vector3DUtil;
	
	import main.dict.Object3DDict;
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
		/**
		 * 根据父数据对象的唯一ID，过滤数据 
		 * @param data		数据对象
		 * @return Boolean	过滤结果，true不需要过滤掉该数据，false需要过滤掉该数据
		 * 
		 */		
		protected function filterDataByParentID(data:ICObject3DData):Boolean
		{
			return _parentID ? data.parentID==_parentID : true;
		}
		override protected function initDataCache():void
		{
			_walls=getDatasByTypeAndParentID(Object3DDict.OBJECT3D_WALL,parentID);
		}
		/**
		 *	根据地面围点，创建房间内的墙体数据集合 
		 * @param wallPoses
		 * @param parentID
		 * 
		 */		
		public function createWalls(wallPoses:Vector.<Vector3D>,parentID:String):void
		{
			this.parentID=parentID;
			if(_walls==null)
			{
				_walls=new Vector.<ICData>();
				var wallVo:CWallVO;
				var len:int=wallPoses.length;
				var next:int;
				var caculationVec:Vector3D;
				for(var i:int=0; i<len; i++)
				{
					next=i+1==len?0:i+1;
					wallVo=new CWallVO();
					wallVo.parentID=parentID;  
					wallVo.uniqueID=UIDUtil.createUID();
					wallVo.type=Object3DDict.OBJECT3D_WALL;
					wallVo.startPos=new Vector3D(wallPoses[i].x,wallPoses[i].y,0);
					wallVo.endPos=new Vector3D(wallPoses[next].x,wallPoses[next].y,0);
					caculationVec=wallVo.endPos.subtract(wallVo.startPos);
					wallVo.length=caculationVec.length;
					wallVo.width=0;
					wallVo.height=wallPoses[i].z>>1;
					wallVo.direction=caculationVec;
					wallVo.rotation=Vector3DUtil.calculateRotationByAxis(caculationVec,Vector3D.X_AXIS);
					caculationVec.scaleBy(.5);
					caculationVec.incrementBy(wallVo.startPos);
					wallVo.x=caculationVec.x;
					wallVo.y=caculationVec.y;
					wallVo.z=0;
					wallVo.direction.normalize();
					wallVo.isLife=true;
					addCacheData(wallVo);
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
	}
}