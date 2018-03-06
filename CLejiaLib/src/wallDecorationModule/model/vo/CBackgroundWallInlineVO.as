package wallDecorationModule.model.vo
{
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParam9GridRectangleVO;
	
	/**
	 * 背景墙内框矩形数据类
	 * @author cloud
	 */
	public class CBackgroundWallInlineVO extends CParam9GridRectangleVO
	{
		private var _lineVo:CBackgroundWallInlineLineVO;
		private var _cornerVo:CBackgroundWallInlineCornerVO;
		private var _bottomVo:CBackgroundWallInlineColumnVO;
		
		public var cornerBoardCode:String;
		public var cornerBoardMaterial:String;

		public function get bottomVo():CBackgroundWallInlineColumnVO
		{
			return _bottomVo;
		}
		public function get lineVo():CBackgroundWallInlineLineVO
		{
			return _lineVo;
		}
		public function get cornerVo():CBackgroundWallInlineCornerVO
		{
			return _cornerVo;
		}
		
		public function CBackgroundWallInlineVO(clsType:String)
		{
			super(clsType);
		}
		override protected function doCreateLineVO():CBaseTaskObject3DVO
		{
			_lineVo=super.doCreateLineVO() as CBackgroundWallInlineLineVO;
			return _lineVo;
		}
		override protected function doCreateCorner():CBaseTaskObject3DVO
		{
			_cornerVo=super.doCreateCorner() as CBackgroundWallInlineCornerVO;
			_cornerVo.cornerBoardCode=cornerBoardCode;
			_cornerVo.cornerBoardMaterial=cornerBoardMaterial;
			if(_cornerVo.cornerBoardCode.length>0)
			{
				var cornerBoard:CBackgroundWallInlineCornerVO=super.doCreateCorner() as CBackgroundWallInlineCornerVO;
				cornerBoard.code=_cornerVo.cornerBoardCode;
				cornerBoard.material=_cornerVo.cornerBoardMaterial;
			}
			return _cornerVo;
		}
		override protected function doCreateBottom():CBaseTaskObject3DVO
		{
			_bottomVo=super.doCreateBottom() as CBackgroundWallInlineColumnVO;
			return _bottomVo;
		}
		override protected function doDeserializeCorner(xml:XML):void
		{
			cornerBoardCode=xml.@cornerBoardCode;
			cornerBoardMaterial=xml.@cornerBoardMaterial;
			super.doDeserializeCorner(xml);
		}
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CBackgroundWallInlineVO=super.clone() as CBackgroundWallInlineVO;
			clone.cornerBoardCode=cornerBoardCode;
			clone.cornerBoardMaterial=cornerBoardMaterial;
			return clone;
		}
	}
}