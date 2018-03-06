package main.dict
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import cloud.core.datas.base.CTransform3D;
	import cloud.core.datas.base.CVector;
	import cloud.core.datas.containers.CVectorContainer;
	import cloud.core.datas.maps.CHashMap;
	
	import kitchenModule.model.vo.CParamCabinetVO;
	import kitchenModule.model.vo.CParamHangingCabinetVO;
	import kitchenModule.model.vo.CParamTableboardVO;
	
	import main.model.vo.configs.ClapboardCornerConfig;
	import main.model.vo.configs.ClapboardLineConfig;
	import main.model.vo.configs.ConfigProperties;
	import main.model.vo.plans.CParamPlanVO;
	import main.model.vo.task.CDoorSetsBodyBoardVO;
	import main.model.vo.task.CParamAssembleVO;
	import main.model.vo.task.CParamBoardVO;
	import main.model.vo.task.CParamColumnVO;
	import main.model.vo.task.CParamCornerVO;
	import main.model.vo.task.CParamDoorVO;
	import main.model.vo.task.CParamLineVO;
	import main.model.vo.task.CParamPartVO;
	import main.model.vo.task.CParamRectangleVO;
	import main.model.vo.task.CParamRoundLineVO;
	
	import wallDecorationModule.model.vo.CBackgroundWallBoardVO;
	import wallDecorationModule.model.vo.CBackgroundWallInlineColumnVO;
	import wallDecorationModule.model.vo.CBackgroundWallInlineCornerVO;
	import wallDecorationModule.model.vo.CBackgroundWallInlineLineVO;
	import wallDecorationModule.model.vo.CBackgroundWallInlineVO;
	import wallDecorationModule.model.vo.CBackgroundWallPlanVO;
	import wallDecorationModule.model.vo.CClapboardLineVO;
	import wallDecorationModule.model.vo.CClapboardRectangleCornerVO;
	import wallDecorationModule.model.vo.CClapboardRectangleVO;
	import wallDecorationModule.model.vo.CClapboardUnitVO;
	import wallDecorationModule.model.vo.CDoorHandleVO;
	import wallDecorationModule.model.vo.CDoorLineVO;
	import wallDecorationModule.model.vo.CDoorLockVO;
	import wallDecorationModule.model.vo.CDoorRectangleVO;
	import wallDecorationModule.model.vo.CDoorSetsBottomVO;
	import wallDecorationModule.model.vo.CDoorSetsLineVO;
	import wallDecorationModule.model.vo.CDoorUnitVO;

	/**
	 * 装修模块参数化定义类
	 * @author cloud
	 */
	public class CParamDict
	{
		private static const _START:uint = 2000;
		/**
		 * 阵列模式：单方案不变（不改变方案的布局，不足的不使用方案） 
		 */		
		public static const TILING_NORMAL:int = 2;
		/**
		 * 阵列模式：单方案缩小
		 */		
		public static const TILING_DECREASE:int = 0;
		/**
		 * 阵列模式：单方案放大
		 */		
		public static const TILING_INCREASE:int = 1;
		
		/**
		 * 背景墙计划数据
		 */		
		public static const PARAM_PLAN_BACKWALL:uint = 15;
		
		public static const PARAM_INVALIDTYPE:uint=0;
		public static const PARAM_UNIT_ONE:uint = 1;
		public static const PARAM_UNIT_TWO:uint = 2;
		public static const PARAM_UNIT_THREE:uint = 3;
		public static const PARAM_UNIT_FOUR:uint = 4;
		public static const PARAM_UNIT_FIVE:uint = 5;
		public static const PARAM_UNIT_NORMAL:uint = 14;
		
		public static const PARAM_LINE_TOP:uint = 6;
		/**
		 * 柱身顶线 
		 */		
		public static const PARAM_LINE_TOP_COLUMN:uint = 44;
		public static const PARAM_LINE_BOTTOM:uint = 7;
		/**
		 * 柱身底线 
		 */		
		public static const PARAM_LINE_BOTTOM_COLUMN:uint = 43;
		public static const PARAM_LINE_WAIST:uint = 8;
		/**
		 * 柱身腰线 
		 */		
		public static const PARAM_LINE_WAIST_COLUMN:uint = 42;
		/**
		 * 嵌板组合单元件 
		 */
		public static const PARAM_UNIT_BOARD:uint = 10;
		/**
		 * 矩形组合单元件
		 */		
		public static const PARAM_UNIT_RECTANGLE:uint=9;
		/**
		 * 嵌板组合部件——角花
		 */		
		public static const PARAM_PANEL_CORNER:uint = 13;
		/**
		 * 嵌板组合部件——嵌板线 
		 */		
		public static const PARAM_PANEL_LINE:uint = 12;
		/**
		 * 矩形组合部件——边框线
		 */		
		public static const PARAM_RECTANGLE_ON_LINE:uint = 19;
		/**
		 * 矩形组合部件——拐角 
		 */		
		public static const PARAM_RECTANGLE_ON_CORNER:uint = 21;
		/**
		 * 矩形组合部件——底角 
		 */		
		public static const PARAM_RECTANGLE_ON_BOTTOM:uint = 22;
		/**
		 * 矩形组合部件——组合拐角 
		 */		
		public static const PARAM_ASSEMBLE_CORNER:uint = 23;

		/**
		 * 柱体部件 
		 */		
		public static const PARAM_COLUMN_NORMAL:uint = 16;
		/**
		 * 围线部件 
		 */		
		public static const PARAM_ROUNDLINE_NORMAL:uint = 17;
		/**
		 * 柱身内框 
		 */		
		public static const PARAM_PANEL_LINE_COLUMN:uint = 41;
		/**
		 * 背景墙矩形组合部件——闭合区域背板 
		 */		
		public static const PARAM_RECTANGLE_BOARD_BACKGROUNDWALL:uint = 18;
		/**
		 * 背景墙矩形组合部件——内区域边框
		 */		
		public static const PARAM_RECTANGLE_INLINE_BACKGROUNDWALL:uint=20;
		/**
		 * 背景墙内框线部件 
		 */		
		public static const PARAM_LINE_INLINE_BACKGROUNDWALL:uint = 24;
		/**
		 * 背景墙内框拐角部件 
		 */		
		public static const PARAM_CORNER_INLINE_BACKGROUNDWALL:uint = 25;
		/**
		 * 背景墙内框底角部件 
		 */		
		public static const PARAM_BOTTOM_INLINE_BACKGROUNDWALL:uint = 26;
		/**
		 * 参数化基础板件 
		 */		
		public static const PARAM_BOARD_NORMAL:uint = 27;
		/**
		 * 地柜 
		 */		
		public static const PARAM_CABINET_GROUND:uint=28;
		/**
		 * 高柜 
		 */		
		public static const PARAM_CABINET_HIGHT:uint=29;
		/**
		 * 中高柜 
		 */		
		public static const PARAM_CABINET_MIDDLEHEIGHT:uint=30;
		/**
		 * 吊柜 
		 */		
		public static const PARAM_CABINET_HANGING:uint=31;
		/**
		 * 台面 
		 */		
		public static const PARAM_TABLEBOARD_NORMAL:uint = 32;
		/**
		 * 收口板 
		 */		
		public static const PARAM_BOARD_CLOSINGPLATE:uint = 33;
		/**
		 * 见光板 
		 */		
		public static const PARAM_BOARD_LIGHT:uint = 34;
		/**
		 * 顶封板 
		 */		
		public static const PARAM_BOARD_TOPCOVERPLATE:uint = 35;
		/**
		 * 封边 
		 */		
		public static const PARAM_BOARD_CLOSING_NORMAL:uint = 36;
		/**
		 * 挡水板 
		 */		
		public static const PARAM_BOARD_WATERPROOF:uint = 37;
		/**
		 *  抽屉门
		 */		
		public static const PARAM_DRAWER_DOOR:uint = 47;
		/**
		 * 左开门
		 */		
		public static const PARAM_CABINE_DOORT_LEFT:uint = 48;
		/**
		 * 右开门 
		 */		
		public static const PARAM_CABINET_DOOR_RIGHT:uint = 49;
		/**
		 * 把手 
		 */		
		public static const OBJECT3D_ADORNMENT_HANDLE:uint=38;
		/**
		 * 洗盆 
		 */		
		public static const OBJECT3D_ADORNMENT_BASIN:uint = 39;
		/**
		 *	挂架 
		 */		
		public static const OBJECT3D_ADORNMENT_HANGING:uint = 40;
		/**
		 * 参数化门单元件 
		 */		
		public static const PARAM_DOOR_UNIT:uint=50;
		/**
		 * 门板 
		 */		
		public static const PARAM_DOOR_RECTANGLE:uint=51;
		/**
		 * 门板线 
		 */		
		public static const PARAM_DOOR_LINE:uint=52;
		/**
		 * 门套包边 
		 */		
		public static const PARAM_DOORSETS_BODYBOARD:uint=53;
		/**
		 * 门套角柱
		 */		
		public static const PARAM_DOORSETS_BOTTOM:uint=54;
		/**
		 * 门套线 
		 */		
		public static const PARAM_DOORSETS_LINE:uint=55;
		/**
		 * 门把手 
		 */		
		public static const OBJECT3D_DOOR_HANDLE:uint=56;
		/**
		 * 门锁 
		 */		
		public static const OBJECT3D_DOOR_LOCK:uint=57;

		
		/////////////////////////////////////////////////////////////////////////////////////////
		/**
		 * 普通报价类型 
		 */		
		public static const QUOTES_NORMAL:uint = 0;
		/**
		 * 需要算料报价的板材类型
		 */		
		public static const QUOTES_NESTING_BOARD:uint = 1;
		/**
		 * 单元件背板默认厚度 
		 */		
		public static const DEFAULT_CLAPBOARD_UINT_BOARD_THICKNESS:uint = 8;
		
		public static const WALL_DISPLAY_FIX_WIDTH:uint=1;
		
		private static var _Instance:CParamDict;
		
		public static function get Instance():CParamDict
		{
			return _Instance ||= new CParamDict();
		}
		
		private var _paramType:CHashMap;
		private var _typeConfig:CHashMap;
		private var _clsConfig:CHashMap;
		
		public function CParamDict()
		{
			_paramType=new CHashMap();
			_typeConfig=new CHashMap();
			_typeConfig.put("无效类型",PARAM_INVALIDTYPE);
			_typeConfig.put("三段单框",PARAM_UNIT_ONE);
			_typeConfig.put("两段单框",PARAM_UNIT_TWO);
			_typeConfig.put("两段双框",PARAM_UNIT_THREE);
			_typeConfig.put("两段单框加角花",PARAM_UNIT_FOUR);
			_typeConfig.put("两段双框加雕花",PARAM_UNIT_FIVE);
			_typeConfig.put("自定义单元件",PARAM_UNIT_NORMAL);
			
			_typeConfig.put("嵌板",PARAM_UNIT_BOARD);
			_typeConfig.put("基础矩形组合部件",PARAM_UNIT_RECTANGLE);
			_typeConfig.put("顶线",PARAM_LINE_TOP);
			_typeConfig.put("顶角线",PARAM_LINE_TOP_COLUMN);
			_typeConfig.put("地脚线",PARAM_LINE_BOTTOM);
			_typeConfig.put("底脚线",PARAM_LINE_BOTTOM_COLUMN);
			_typeConfig.put("腰线",PARAM_LINE_WAIST);
			_typeConfig.put("柱身腰线",PARAM_LINE_WAIST_COLUMN);
			_typeConfig.put("嵌板线",PARAM_PANEL_LINE);
			_typeConfig.put("角花",PARAM_PANEL_CORNER);

			_typeConfig.put("背景墙方案",PARAM_PLAN_BACKWALL);
			_typeConfig.put("柱体",PARAM_COLUMN_NORMAL);
			_typeConfig.put("围线",PARAM_ROUNDLINE_NORMAL);
			_typeConfig.put("柱身内框",PARAM_PANEL_LINE_COLUMN);
			_typeConfig.put("边框线",PARAM_RECTANGLE_ON_LINE);
			_typeConfig.put("拐角",PARAM_RECTANGLE_ON_CORNER);
			_typeConfig.put("组合拐角",PARAM_ASSEMBLE_CORNER);
			_typeConfig.put("底角",PARAM_RECTANGLE_ON_BOTTOM);
			_typeConfig.put("背景墙背板",PARAM_RECTANGLE_BOARD_BACKGROUNDWALL);
			_typeConfig.put("内框矩形组合部件",PARAM_RECTANGLE_INLINE_BACKGROUNDWALL);
			_typeConfig.put("背景墙内框线",PARAM_LINE_INLINE_BACKGROUNDWALL);
			_typeConfig.put("背景墙内拐角",PARAM_CORNER_INLINE_BACKGROUNDWALL);
			_typeConfig.put("背景墙内底角",PARAM_BOTTOM_INLINE_BACKGROUNDWALL);
			
			_typeConfig.put("板件",PARAM_BOARD_NORMAL);
			_typeConfig.put("地柜",PARAM_CABINET_GROUND);
			_typeConfig.put("高柜",PARAM_CABINET_HIGHT);
			_typeConfig.put("中高柜",PARAM_CABINET_MIDDLEHEIGHT);
			_typeConfig.put("吊柜",PARAM_CABINET_HANGING);
			_typeConfig.put("台面",PARAM_TABLEBOARD_NORMAL);
			_typeConfig.put("收口板",PARAM_BOARD_CLOSINGPLATE);
			_typeConfig.put("见光板",PARAM_BOARD_LIGHT);
			_typeConfig.put("顶封板",PARAM_BOARD_TOPCOVERPLATE);
			_typeConfig.put("封边",PARAM_BOARD_CLOSING_NORMAL);
			_typeConfig.put("挡水板",PARAM_BOARD_WATERPROOF);
			_typeConfig.put("抽屉门",PARAM_DRAWER_DOOR);
			_typeConfig.put("左开门",PARAM_CABINE_DOORT_LEFT);
			_typeConfig.put("右开门",PARAM_CABINET_DOOR_RIGHT);
			_typeConfig.put("把手",OBJECT3D_ADORNMENT_HANDLE);
			_typeConfig.put("洗盆配件",OBJECT3D_ADORNMENT_BASIN);
			_typeConfig.put("挂架",OBJECT3D_ADORNMENT_HANGING);
			
			_typeConfig.put("参数化门单元件",PARAM_DOOR_UNIT);
			_typeConfig.put("门板",PARAM_DOOR_RECTANGLE);
			_typeConfig.put("门板线",PARAM_DOOR_LINE);
			_typeConfig.put("门套包边",PARAM_DOORSETS_BODYBOARD);
			_typeConfig.put("门套线",PARAM_DOORSETS_LINE);
			_typeConfig.put("门套角柱",PARAM_DOORSETS_BOTTOM);
			_typeConfig.put("门把手",OBJECT3D_DOOR_HANDLE);
			_typeConfig.put("门锁",OBJECT3D_DOOR_LOCK);
			
			_clsConfig=new CHashMap();
			_clsConfig.put("CVector",getQualifiedClassName(CVector));
			_clsConfig.put("CTransform3D",getQualifiedClassName(CTransform3D));
			_clsConfig.put("CVector3DContainer",getQualifiedClassName(CVectorContainer));
			
			_clsConfig.put("CClapboardUnitVO",getQualifiedClassName(CClapboardUnitVO));
			_clsConfig.put("CClapboardLineVO",getQualifiedClassName(CClapboardLineVO));
			_clsConfig.put("CClapboardRectangleVO",getQualifiedClassName(CClapboardRectangleVO));
			_clsConfig.put("CClapboardRectangleCornerVO",getQualifiedClassName(CClapboardRectangleCornerVO));
			_clsConfig.put("CParamPlanVO",getQualifiedClassName(CParamPlanVO));
			_clsConfig.put("CBackgroundWallPlanVO",getQualifiedClassName(CBackgroundWallPlanVO));
			_clsConfig.put("CParamPartVO",getQualifiedClassName(CParamPartVO));
			_clsConfig.put("CParamRoundLineVO",getQualifiedClassName(CParamRoundLineVO));
			_clsConfig.put("CParamLineVO",getQualifiedClassName(CParamLineVO));
			_clsConfig.put("CParamCornerVO",getQualifiedClassName(CParamCornerVO));
			_clsConfig.put("CParamColumnVO",getQualifiedClassName(CParamColumnVO));
			_clsConfig.put("CParamRectangleVO",getQualifiedClassName(CParamRectangleVO));
			_clsConfig.put("CBackgroundWallBoardVO",getQualifiedClassName(CBackgroundWallBoardVO));
			_clsConfig.put("CBackgroundWallInlineVO",getQualifiedClassName(CBackgroundWallInlineVO));
			_clsConfig.put("CBackgroundWallInlineLineVO",getQualifiedClassName(CBackgroundWallInlineLineVO));
			_clsConfig.put("CBackgroundWallInlineCornerVO",getQualifiedClassName(CBackgroundWallInlineCornerVO));
			_clsConfig.put("CBackgroundWallInlineColumnVO",getQualifiedClassName(CBackgroundWallInlineColumnVO));
			
			_clsConfig.put("CParamBoardVO",getQualifiedClassName(CParamBoardVO));
			_clsConfig.put("CParamAssembleVO",getQualifiedClassName(CParamAssembleVO));
			_clsConfig.put("CParamCabinetVO",getQualifiedClassName(CParamCabinetVO));
			_clsConfig.put("CParamHangingCabinetVO",getQualifiedClassName(CParamHangingCabinetVO));
			_clsConfig.put("CParamTableboardVO",getQualifiedClassName(CParamTableboardVO));
			_clsConfig.put("CParamDoorVO",getQualifiedClassName(CParamDoorVO));
			
			_clsConfig.put("CDoorUnitVO",getQualifiedClassName(CDoorUnitVO));
			_clsConfig.put("CDoorRectangleVO",getQualifiedClassName(CDoorRectangleVO));
			_clsConfig.put("CDoorLineVO",getQualifiedClassName(CDoorLineVO));
			_clsConfig.put("CDoorSetsLineVO",getQualifiedClassName(CDoorSetsLineVO));
			_clsConfig.put("CDoorSetsBottomVO",getQualifiedClassName(CDoorSetsBottomVO));
			_clsConfig.put("CDoorSetsBodyBoardVO",getQualifiedClassName(CDoorSetsBodyBoardVO));
			_clsConfig.put("CDoorLockVO",getQualifiedClassName(CDoorLockVO));
			_clsConfig.put("CDoorHandleVO",getQualifiedClassName(CDoorHandleVO));
			
			_clsConfig.put("ClapboardLineConfig",getQualifiedClassName(ClapboardLineConfig));
			_clsConfig.put("ClapboardCornerConfig",getQualifiedClassName(ClapboardCornerConfig));
			_clsConfig.put("ConfigProperties",getQualifiedClassName(ConfigProperties));
			
		}
		/**
		 * 添加一个类型定义 
		 * @param typeStr	类型字符串
		 * @param className	类型对应的类名字符串
		 * 
		 */			
		public function addTypeDef(typeStr:String,className:String):void
		{
			if(!_paramType.containsKey(typeStr))
				_paramType.put(typeStr,{type:_typeConfig.get(typeStr) as uint,count:0,className:className})
		}
		/**
		 * 根据中文字符串判断是否是放样线条类型 
		 * @param str
		 * @return Boolean
		 * 
		 */		
		public function isLoftingLineByStr(str:String):Boolean
		{
			var paramType:uint=_typeConfig.get(str) as uint;
			return paramType==PARAM_LINE_TOP || paramType==PARAM_LINE_TOP_COLUMN ||
				paramType==PARAM_LINE_BOTTOM || paramType==PARAM_LINE_BOTTOM_COLUMN ||
				paramType==PARAM_LINE_WAIST || paramType==PARAM_LINE_WAIST_COLUMN ||
				paramType==PARAM_PANEL_LINE || paramType==PARAM_PANEL_LINE_COLUMN || paramType==PARAM_RECTANGLE_ON_LINE || paramType==PARAM_LINE_INLINE_BACKGROUNDWALL ||
				paramType==PARAM_ROUNDLINE_NORMAL ||
				paramType==PARAM_DOOR_LINE || paramType==PARAM_DOORSETS_LINE || paramType==PARAM_DOORSETS_BODYBOARD;
		}
		/**
		 * 获取类型对应的类名 
		 * @param type
		 * @return String
		 * 
		 */		
		public function getTypeClassName(type:uint):String
		{
			var paramType:uint=getParamType(type);
			var len:int=_paramType.values.length;
			var clsName:String;
			for(var i:int=0; i<len; i++)
			{
				if(_paramType.values[i].type==paramType)
				{
					clsName=_paramType.values[i].className;
					break;
				}
			}
			return clsName;
		}
		/**
		 * 获取类型名 
		 * @param type
		 * @return String
		 * 
		 */		
		public function getTypeName(type:uint):String
		{
			var paramType:uint=getParamType(type);
			var len:int=_typeConfig.values.length;
			for(var i:int=0; i<len; i++)
			{
				if(_typeConfig.values[i]==paramType)
				{
					return _typeConfig.keys[i] as String;
				}
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
			return uint(_typeConfig.get(str))+_START;
		}
		public function getParamTypeByString(str:String):uint
		{
			return uint(_typeConfig.get(str));
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
		/**
		 * 根据参数化类型获取大类型定义值 
		 * @param paramType
		 * @return 
		 * 
		 */		
		public function getTypeByParamType(paramType:uint):uint
		{
			return paramType+_START;
		}
		/**
		 * 获取参数化部件名称 
		 * @param unitType
		 * @return String
		 * 
		 */		
		public function getGroupName(unitType:uint):String
		{
			var paramType:uint=getParamType(unitType);
			var obj:Object;
			for(var i:int=0; i<_paramType.values.length; i++)
			{
				if(_paramType.values[i].type==paramType)
				{
					obj=_paramType.values[i];
					break;
				}	
			}
			if(obj==null) return null;
			obj.count=obj.count+1;
			return obj.className+"_"+obj.count;
		}
		/**
		 * 根据类型类名，获取参数化数据类型的类全名 
		 * @param typeStr	类型名称
		 * @return String
		 * 
		 */		
		public function getTypeQualifiedClassName(className:String):String
		{
			return _clsConfig.get(className) as String;
		}
		/**
		 * 根据类型类名,获取参数化数据类型类对象的引用 
		 * @param typeStr	类型名称
		 * @return Class
		 * 
		 */		
		public function getParamDataTypeCls(className:String):Class
		{
			return getDefinitionByName(getTypeQualifiedClassName(className)) as Class;
		}
	}
}