package kitchenModule.model.vo
{
	import alternativa.engine3d.core.Transform3D;
	import main.model.vo.CObject3DListVO;

	/**
	 * 房间拐角数据类
	 * @author cloud
	 */
	public class CRoomCornerVO extends CObject3DListVO
	{
		public var prevWidth:Number;
		public var prevLength:Number;
		public var nextWidth:Number;
		public var nextLength:Number;
		public var parentTransform:Transform3D;
		public var parentInverseTransform:Transform3D;
		
		public function CRoomCornerVO()
		{
			super();
			prevWidth=prevLength=nextWidth=nextLength=0;
		}
	}
}