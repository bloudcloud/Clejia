package wallDecorationModule.model.vo
{
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParam9GridRectangleVO;
	
	/**
	 * 参数化门板矩形区域数据类
	 * @author cloud
	 * @2017-8-28
	 */
	public class CDoorRectangleVO extends CParam9GridRectangleVO
	{
		/**
		 * 线条拐角路径
		 */		
		public var lineCornerPaths:String;
		
		public function CDoorRectangleVO(clsType:String="CDoorRectangleVO")
		{
			super(clsType);
			_isXYZ=true;
		}
		override protected function doDeserializeLine(xml:XML):void
		{
			lineCornerPaths=xml.@lineCornerPaths;
			super.doDeserializeLine(xml);
		}

		override protected function doCreateLineVO():CBaseTaskObject3DVO
		{
			var lineVo:CDoorLineVO = super.doCreateLineVO() as CDoorLineVO;
			lineVo.cornerPaths=lineCornerPaths;
			return lineVo;
		}
	}
}