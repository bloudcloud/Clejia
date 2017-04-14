package model
{
	import flash.geom.Vector3D;
	
	import cloud.core.interfaces.ICObject3DData;
	
	import model.vo.CWallVO;
	
	/**
	 * 墙体数据模型
	 * @author cloud
	 */
	public class CWallModel extends BaseObject3DVOModel
	{
		private var _walls:Vector.<CWallVO>;
		private var _furnitures:Vector.<ICObject3DData>;
		
		public function CWallModel()
		{
			_walls=new Vector.<CWallVO>();
			_furnitures=new Vector.<ICObject3DData>();
		}
		
		public function createWallVo(uniqueID:String,length:Number,width:Number,height:Number,direction:Vector3D,position:Vector3D):void
		{
			
		}
		
	}
}