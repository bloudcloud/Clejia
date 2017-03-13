package dic
{
	import main.FurnitureInputData;
	import main.FurnitureOutputData;

	/**
	 *	全局类型定义类
	 * @author cloud
	 */
	public class KitchenGlobalDic
	{
		public static const DIR_FRONT:int = 0;
		public static const DIR_BACK:int = 180;
		public static const DIR_LEFT:int = 90;
		public static const DIR_RIGHT:int = -90;
		/**
		 * 橱柜单柜 
		 */		
		public static const MESHTYPE_DEFAULT:uint = 0;
		public static const MESHTYPE_CABINET:uint = 23;
		public static const MESHTYPE_TABLEBOARD:uint = 201;
		public static const MESHTYPE_SHELTER:uint = 202;
		/**
		 * 橱柜吊柜 
		 */		
		public static const MESHTYPE_HANGING_CABINET:uint = 24;
		/**
		 * 判断是否吸附距离 
		 */		
		public static const SORPTION_DISTANCE:uint = 50;
		/**
		 * 吊柜的设置高度 
		 */		
		public static const HANGING_HEIGH_NUM:uint = 500;
		/**
		 * 台面的厚度 
		 */		
		public static const TABLEBOARD_HEIGHT:uint = 20;
		/**
		 * 挡板的厚度 
		 */		
		public static const SHELTER_WIDTH:uint=20;
		
		public static const FURNITURE_INPUTDATA:FurnitureInputData = new FurnitureInputData();
		public static const FURNITURE_OUTPUTDATA:FurnitureOutputData = new FurnitureOutputData();
		
		public function KitchenGlobalDic()
		{
		}
	}
}