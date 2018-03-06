package wallDecorationModule.model.vo
{
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParamCornerVO;
	
	/**
	 * 背景墙内区域的拐角数据类
	 * @author cloud
	 */
	public class CBackgroundWallInlineCornerVO extends CParamCornerVO
	{
		public var cornerBoardCode:String;
		public var cornerBoardMaterial:String;
		
		public function CBackgroundWallInlineCornerVO(clsType:String)
		{
			super(clsType);
		}
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			cornerBoardCode=xml.@cornerBoardCode;
			cornerBoardMaterial=xml.@cornerBoardMaterial;
		}
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CBackgroundWallInlineCornerVO=super.clone() as CBackgroundWallInlineCornerVO;
			clone.cornerBoardCode=cornerBoardCode;
			clone.cornerBoardMaterial=cornerBoardMaterial;
			return clone;
		}
	}
}