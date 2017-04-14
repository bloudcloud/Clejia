package model
{
	import flash.geom.Vector3D;
	
	import cloud.core.interfaces.ICData;
	
	import interfaces.ICFurnitureModel;
	
	/**
	 *  厨房部件数据模型类(洗盆，煤气灶等)
	 * @author cloud
	 */
	public class CKitchenPartModel implements ICFurnitureModel
	{
		public function CKitchenPartModel()
		{
		}
		
		public function initModel(floorID:String):void
		{
			
		}
		
		public function createFurnitureVo(furnitureID:String, furnitureDirection:int, furnitureType:uint, length:uint, width:uint, height:uint):void
		{
			
		}
		
		public function deleteFurnitureVo(furnitureID:String):void
		{
		}
		
		public function excuteMove(furnitureDir:int, position:Vector3D):Boolean
		{
			//贴在桌面移动
			
			return false;
		}
		
		public function excuteMouseDown(furnitureID:String, furnitureDir:int):Boolean
		{
			return false;
		}
		
		public function excuteMouseUp():Vector.<ICData>
		{
			return null;
		}
		
		public function excuteEnd():void
		{
		}
		
		public function clear():void
		{
		}
	}
}