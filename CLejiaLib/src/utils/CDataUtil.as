package utils
{
	import flash.geom.Point;
	
	import cloud.core.interfaces.ICObject3DData;

	/**
	 * 数据工具类
	 * @author cloud
	 */
	public class CDataUtil
	{
		public function CDataUtil()
		{
		}
		/**
		 *  根据区域围点设置3D物体数据对象的尺寸信息
		 * @param sourceVo	物体数据对象
		 * @param regionPoints	区域围点
		 * @param thickness	物体数据对象的厚度
		 * 
		 */		
		public static function setObject3DVoSizeByRegion(sourceVo:ICObject3DData,regionPoints:Array,thickness:Number=0):void
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
	}
}