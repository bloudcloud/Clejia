package main.dict
{
	/**
	 * 3D对象定义类
	 * @author cloud
	 */
	public class Object3DDict
	{
		public static const OBJECT3D_DEFAULT:uint = 0;
		public static const OBJECT3D_WALL:uint = 200;
		public static const OBJECT3D_TABLEBOARD:uint = 201;
		public static const OBJECT3D_SHELTER:uint = 202;
		public static const OBJECT3D_ROOMCORNER:uint = 203;
		public static const OBJECT3D_WAIST:uint = 204;
		public static const OBJECT3D_CLAPBOARD:uint = 205;
		public static const OBJECT3D_DOOR:uint=3|8|9|14|15|16|17;
		public static const OBJECT3D_WINDOW:uint = 4|10|11|30;
		public static const OBJECT3D_FLOOR:uint = 207;
		public static const OBJECT3D_ROOM:uint = 208;
		/**
		 *	单柜 
		 */		
		public static const OBJECT3D_CABINET:uint = 23;
		/**
		 * 吊柜 
		 */		
		public static const OBJECT3D_HANGING_CABINET:uint = 24;
		/**
		 * 厨房部件 (水盆，燃气灶等)
		 */		
		public static const OBJECT3D_BASIN:uint = 25;
		
		/**
		 * 2D区域数据 
		 */		
		public static const DATA_REGION2D:uint = 1000;

		public function Object3DDict()
		{
		}
	}
}