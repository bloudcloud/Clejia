package kitchenModule.model.vo
{
	import cloud.core.datas.base.CTransform3D;
	
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
		public var parentTransform:CTransform3D;
		public var parentInverseTransform:CTransform3D;
		
		public function CRoomCornerVO(clsName:String="CRoomCornerVO")
		{
			super(clsName);
			prevWidth=prevLength=nextWidth=nextLength=0;
		}
	}
}