package utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	
	import main.model.vo.CWallVO;

	/**
	 * 数据工具类
	 * @author cloud
	 */
	public class CDataUtil
	{
		private static var _instance:CDataUtil;
		
		public static function get instance():CDataUtil
		{
			return _instance ||= new CDataUtil();
		}
		
		private var _groupCount:uint;
		private var _rectangle:Rectangle;
		
		public function CDataUtil()
		{
			_rectangle=new Rectangle();
		}
		/**
		 * 创建组ID 
		 * @return uint
		 * 
		 */		
		public function createGroupID():uint
		{
			return ++_groupCount;
		}
		/**
		 *  根据区域围点设置3D物体数据对象的尺寸信息
		 * @param sourceVo	物体数据对象
		 * @param regionPoints	区域围点
		 * @param thickness	物体数据对象的厚度
		 * 
		 */		
		public function setObject3DVoSizeByRegion(sourceVo:ICObject3D,regionPoints:Array,thickness:Number=0):void
		{
			var maxX:Number=int.MIN_VALUE,minX:Number=int.MAX_VALUE,maxY:Number=int.MIN_VALUE,minY:Number=int.MAX_VALUE;
			for each(var point:Point in regionPoints)
			{
				if(maxX<point.x)	maxX=point.x;
				if(minX>point.x)	minX=point.x;
				if(maxY<point.y)	maxY=point.y;
				if(minY>point.y)	minY=point.y;
			}
			sourceVo.length=maxX-minX;
			sourceVo.width=thickness;
			sourceVo.height=maxY-minY;
		}
		/**
		 * 根据相邻的两个3D围点Point,获取墙体数据对象
		 * @param wallVos
		 * @param pointA		
		 * @param pointB
		 * @return CWallVO
		 * 
		 */		
		public function getWallVoByRoundPoint3D(wallVos:Vector.<ICData>,pointA:Point,pointB:Point,is2DMode:Boolean=true):CWallVO
		{
			if(wallVos==null || wallVos.length==0) return null;
			var ya:Number;
			var yb:Number;
			if(is2DMode)
			{
				ya=-pointA.y;
				yb=-pointB.y;
			}
			else
			{
				ya=pointA.y;
				yb=pointB.y;
			}
			for each(var wallVo:CWallVO in wallVos)
			{
				if((wallVo.startPos.x==pointA.x && wallVo.startPos.y==ya && wallVo.endPos.x==pointB.x && wallVo.endPos.y==yb) ||
					(wallVo.startPos.x==pointB.x && wallVo.startPos.y==yb && wallVo.endPos.x==pointA.x && wallVo.endPos.y==ya))
					return wallVo;
			}
			return null;
		}
		/**
		 *  根据墙面索引获取墙面数据
		 * @param wallVos	墙面数据集合
		 * @param index	墙面索引
		 * @return 
		 * 
		 */		
		public function getWallVoByIndex(wallVos:Vector.<ICData>,index:int):CWallVO
		{
			for each(var wallVo:CWallVO in wallVos)
			{
				if(wallVo.indexIn2DMode>=0 && wallVo.indexIn2DMode==index)
				{
					return wallVo;
				}
			}
			return null;
		}
		/**
		 *	根据围点集合获取矩形区域 
		 * @param roundPoints	围点集合
		 * @return Rectangle
		 * 
		 */		
		public function getRectangleByRoundPoints(roundPoints:Array):Rectangle
		{
			var minX:Number=int.MAX_VALUE,minY:Number=int.MAX_VALUE;
			var maxX:Number=int.MIN_VALUE,maxY:Number=int.MIN_VALUE;
			for each(var pos:Vector3D in roundPoints)
			{
				if(minX>pos.x) minX=pos.x;
				if(minY>pos.y) minY=pos.y;
				if(maxX<pos.x) maxX=pos.x;
				if(maxY<pos.y) maxY=pos.y;
			}
			_rectangle.x=minX;
			_rectangle.y=minY;
			_rectangle.width=maxX-minX;
			_rectangle.height=maxY-minY;
			return _rectangle;
		}
		/**
		 * 计算单元件长度的缩放比例 
		 * @param unitLength
		 * @param wallLength
		 * @return Number
		 * 
		 */		
		public function calculationUnitScaleRate(unitLength:Number,wallLength:uint):Number
		{
			var scaleRate:Number;
			var value:Number=wallLength/unitLength;
			var num:int=wallLength/unitLength;
			if(value>num)
			{
				num++
				scaleRate=wallLength/num/unitLength;
			}
			else
			{
				scaleRate=1;
			}
			return scaleRate;
		}
	}
}