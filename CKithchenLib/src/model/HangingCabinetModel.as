package model
{
	import model.vo.HangingCabinetVO;

	/**
	 *  吊柜数据模型类
	 * @author cloud
	 */
	public class HangingCabinetModel extends BaseChainFurnitureModel
	{
		public function HangingCabinetModel()
		{
			super();
		}
		/**
		 * 创建吊柜数据 
		 * @param furnitureID
		 * @param furnitureType
		 * @param length
		 * @param width
		 * @param height
		 * 
		 */		
		public function createHangingCabinet(furnitureID:String,furnitureType:uint,length:uint,width:uint,height:uint):void
		{
			var vo:HangingCabinetVO = new HangingCabinetVO();
			vo.uniqueID = furnitureID;
			vo.type = furnitureType;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.direction=_direction;

			addFurnitureVO(vo);
			updateChainState(vo);
		}
		/**
		 * 删除吊柜数据 
		 * @param furnitureID
		 * 
		 */		
		public function deleteCabinetVO(furnitureID:String):void
		{
			var vo:HangingCabinetVO=getFurnitureVOByID(furnitureID) as HangingCabinetVO;
			if(vo && vo is HangingCabinetVO && _root!=vo)
				removeChainNode(vo);
			removeFurnitureVO(vo);
			updateCanSorption();
		}
	}
}