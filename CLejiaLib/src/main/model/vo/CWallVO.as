package main.model.vo
{
	import cloud.core.interfaces.ICPoolObject;

	/**
	 *  墙体数据
	 * @author cloud
	 */
	public class CWallVO extends CObject3DListVO implements ICPoolObject
	{
		public var indexIn2DMode:int;
		public var roomIndex:int;
		
		public function CWallVO()
		{
			super();
			indexIn2DMode=-1;
			roomIndex=-1;
		}
		public function initObject(initParam:Object=null):void
		{
		}
		public function dispose():void
		{
			indexIn2DMode=-1;
			roomIndex=-1;
		}
	}
}