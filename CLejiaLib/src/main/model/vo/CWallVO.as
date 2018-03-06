package main.model.vo
{
	/**
	 *  墙体数据
	 * @author cloud
	 */
	public class CWallVO extends CObject3DListVO
	{
		public var indexIn2DMode:int;
		public var roomID:String;
		/**
		 * 墙面起始点方向角的偏移缩放值（值为正表示内向缩进，值为负表示外向延伸）
		 */	
		public var startOffsetScale:Number;
		/**
		 * 墙面终止点方向角的偏移 （值为正表示内向缩进，值为负表示外向延伸）
		 */	
		public var endOffsetScale:Number;
		
		public function CWallVO(clsName:String="CWallVO")
		{
			super(clsName);
			indexIn2DMode=-1;
			startOffsetScale=endOffsetScale=0;
		}
		public function initObject(initParam:Object=null):void
		{
		}
		public function dispose():void
		{
			startOffsetScale=0;
			endOffsetScale=0;
			indexIn2DMode=-1;
			roomID=null;
		}
	}
}