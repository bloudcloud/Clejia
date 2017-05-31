package wallDecorationModule.dict
{
	import cloud.core.dataStruct.map.CHashMap;

	/**
	 * 装修模块参数化定义类
	 * @author cloud
	 */
	public class CDecorationParamDict
	{
		private static const _START:uint = 2000;
		/**
		 * 阵列模式：单方案不变（不改变方案的布局，不足的不使用方案） 
		 */		
		public static const TILING_NORMAL:int = 2;
		/**
		 * 阵列模式：单方案缩小
		 */		
		public static const TILING_INCREASE:int = 0;
		/**
		 * 阵列模式：单方案放大
		 */		
		public static const TILING_DECREASE:int = 1;
		
		public static const PARAM_UNIT_ONE:uint = 1;
		public static const PARAM_UNIT_TWO:uint = 2;
		public static const PARAM_UNIT_THREE:uint = 3;
		public static const PARAM_UNIT_FOUR:uint = 4;
		public static const PARAM_UNIT_FIVE:uint = 5;
		public static const PARAM_UNIT_NORMAL:uint = 100;
		
		public static const PARAM_LINE_TOP:uint = 6;
		public static const PARAM_LINE_BOTTOM:uint = 7;
		public static const PARAM_LINE_WAIST:uint = 8;
		
		public static const PARAM_RECTANGLE_BOARD:uint = 9;
		public static const PARAM_RECTANGLE_NOBOARD:uint = 10;
		public static const PARAM_RECTANGLE_CORNER:uint = 11;
		
		public static const PARAM_PANEL_LINE:uint = 12;
		public static const PARAM_PANEL_CORNER:uint = 13;
		/**
		 * 单元件背板默认厚度 
		 */		
		public static const DEFAULT_UINT_BOARD_THICKNESS:uint = 8;
		
		public static const WALL_DISPLAY_FIX_WIDTH:uint=10;
		
		private static var _instance:CDecorationParamDict;
		
		public static function get instance():CDecorationParamDict
		{
			return _instance ||= new CDecorationParamDict();
		}
		
		private var _paramType:CHashMap;
		
		public function CDecorationParamDict()
		{
			_paramType=new CHashMap();
			_paramType.put("三段单框",PARAM_UNIT_ONE);
			_paramType.put("两段单框",PARAM_UNIT_TWO);
			_paramType.put("两段双框",PARAM_UNIT_THREE);
			_paramType.put("两段单框加角花",PARAM_UNIT_FOUR);
			_paramType.put("两段双框加雕花",PARAM_UNIT_FIVE);
			_paramType.put("面板",PARAM_RECTANGLE_BOARD);
			_paramType.put("嵌板",PARAM_RECTANGLE_NOBOARD);
			_paramType.put("顶线",PARAM_LINE_TOP);
			_paramType.put("地脚线",PARAM_LINE_BOTTOM);
			_paramType.put("腰线",PARAM_LINE_WAIST);
			_paramType.put("嵌板线",PARAM_PANEL_LINE);
			_paramType.put("角花",PARAM_PANEL_CORNER);
			_paramType.put("自定义单元件",PARAM_UNIT_NORMAL);
		}
		/**
		 * 根据中文字符串判断是否是放样线条类型 
		 * @param str
		 * @return Boolean
		 * 
		 */		
		public function isLoftingLineByStr(str:String):Boolean
		{
			var type:uint=uint(_paramType.get(str));
			return type==PARAM_LINE_TOP || type==PARAM_LINE_BOTTOM || type==PARAM_LINE_WAIST || type==PARAM_PANEL_LINE;
		}
		/**
		 * 获取类型名 
		 * @param type
		 * @return 
		 * 
		 */		
		public function getTypeName(type:uint):String
		{
			for each(var key:String in _paramType.keys)
			{
				if(uint(_paramType.get(key))==type-_START)
					return key;
			}
			return null;
		}
		/**
		 * 根据字符串获取大类型定义值 
		 * @param str
		 * @return uint
		 * 
		 */		
		public function getTypeByString(str:String):uint
		{
			return uint(_paramType.get(str))+_START;
		}
		/**
		 * 获取参数化数据对象类型 
		 * @param type
		 * @return uint
		 * 
		 */		
		public function getParamType(type:uint):uint
		{
			return type-_START;
		}
	}
}