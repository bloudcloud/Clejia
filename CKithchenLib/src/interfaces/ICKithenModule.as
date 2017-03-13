package interfaces 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Mesh;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;

	/**
	 *  厨房模块接口
	 * @author cloud
	 */
	public interface ICKithenModule
	{
		/**
		 * 创建单柜可视对象数据 
		 * @param furnitureID	家具唯一id
		 * @param furnitureType	家具类型
		 * @param furnitureLength	家具的长
		 * @param furnitureWidth	家具的宽
		 * @param furnitureHeight	家具的高
		 * 
		 */
		function createCabinet(furnitureID:String,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void;
		/**
		 * 创建吊柜可视对象数据 
		 * @param furnitureID	家具唯一id
		 * @param furnitureType	家具类型
		 * @param furnitureLength	家具的长
		 * @param furnitureWidth	家具的宽
		 * @param furnitureHeight	家具的高
		 * 
		 */
		function createHangingCabinet(furnitureID:String,furnitureType:uint,furnitureLength:uint,furnitureWidth:uint,furnitureHeight:uint):void
		/**
		 * 删除3D家具可视对象数据 
		 * @param furnitureID	家具唯一id
		 * @param furnitureType	家具类型
		 * 
		 */	
		function deleteCabinet(furnitureID:String,furnitureType:uint):void;
		/**
		 *	执行数据模型的移动逻辑 
		 * @param furnitureID	家具的唯一id
		 * @param furnitureType	家具的类型
		 * @param furnitureRotationZ 家具的方向
		 * @param outputPos	家具的位置
		 * @return Boolean
		 * 
		 */				
		function excuteMove(furnitureID:String,furnitureType:uint,furnitureRotationZ:Number,outputPos:Vector3D):Boolean;
		/**
		 * 创建挡板 
		 * @param points	房间4个角落的点坐标
		 * 
		 */		
		function createShelter(ptl:Vector3D,ptr:Vector3D,pbl:Vector3D,pbr:Vector3D):Mesh;
		/**
		 * 创建台面 
		 * 
		 */		
		function createTableBoard():Mesh;
		/**
		 * 清除
		 * 
		 */		
		function clear():void;
		/**
		 * 报价 
		 * 
		 */		
		function getQuotes():void;
	}
}