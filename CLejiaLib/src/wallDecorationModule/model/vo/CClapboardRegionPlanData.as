package wallDecorationModule.model.vo
{
	import cloud.core.dataStruct.container.Vector3DContainer;
	import cloud.core.singleton.CPoolsManager;
	
	import main.model.vo.task.CParam3DTaskVO;
	import main.model.vo.task.CUnit3DTaskVO;

	public class CClapboardRegionPlanData 
	{
		public static const ATTRIBUTE_COUNT:uint=2;
		
		private var _invalidLength:Boolean;
		private var _length:Number=0;
		private var _size:uint;
		private var _units:Array;
		private var _realLength:Number=0;
		
		public var wallID:String;
		public var regionID:String;
		public var tilingMode:int;
		public var planType:uint;
		public var lengthScale:Number=1;
		
		public var roundPoints:Vector3DContainer;
		public var isLife:Boolean=true;
//		public var realLength:Number=0;
		
		public function set realLength(value:Number):void
		{
			_realLength=value;
		}
		public function get realLength():Number
		{
			if(_realLength==0)
			{
				_realLength=_units[0].realLength;
			}
			return _realLength;
		}
		public function get units():Array
		{
			return _units;
		}
		public function get size():uint
		{
			return _size;
		}
//		public function get realLength():Number
//		{
//			return length*lengthScale;
//		}
//		public function get length():Number
//		{
//			if(_invalidLength)
//			{
//				updateLength();
//			}
//			//临时
//			if(realLength==0)
//				realLength=_length;
//			return _length;
//		}
		public function CClapboardRegionPlanData()
		{
			roundPoints=CPoolsManager.instance.getPool(Vector3DContainer).pop() as Vector3DContainer;
			_units=new Array();
		}
		private function updateLength():void
		{
			if(_units.length>0)
			{
				var len:int=_units.length;
				_length=(_units[(_size-1)*ATTRIBUTE_COUNT]).x-_units[0].x+_units[(_size-1)*ATTRIBUTE_COUNT].length;
			}
		}
		/**
		 * 根据索引，获取单元件数据 
		 * @param index
		 * @return CUnit3DTaskVO
		 * 
		 */		
		public function getUnitVoByIndex(index:int):CUnit3DTaskVO
		{
			return _units[index*ATTRIBUTE_COUNT];
		}
		/**
		 * 根据索引，获取单元件内的单件数据集合 
		 * @param index
		 * @return Vector.<CParam3DTaskVO>
		 * 
		 */		
		public function getParamVosByIndex(index:int):Vector.<CParam3DTaskVO>
		{
			return _units[index*ATTRIBUTE_COUNT+1] as Vector.<CParam3DTaskVO>;
		}
		/**
		 * 缩放方案 
		 * @param scaleRate
		 * 
		 */		
		public function scaleByLength(scaleRate:Number):void
		{
			lengthScale=scaleRate;
			var unitVo:CUnit3DTaskVO;
			var paramVo:CParam3DTaskVO;
			var paramVos:Vector.<CParam3DTaskVO>;
			for(var i:int=0; i<_units.length; i+=ATTRIBUTE_COUNT)
			{
				unitVo=_units[i] as CUnit3DTaskVO;
				unitVo.lengthScale=scaleRate;
				paramVos=_units[i+1] as Vector.<CParam3DTaskVO>;
				for each(paramVo in paramVos)
				{
					paramVo.lengthScale=scaleRate;
				}
			}
		}
		/**
		 * 为计划创建一个单元件数据 
		 * @param unitVo
		 * 
		 */		
		public function createOneUnit(unitVo:CUnit3DTaskVO):void
		{
			_invalidLength=true;
			_units.push(unitVo);
			_units.push(new Vector.<CParam3DTaskVO>());
			_size++;
		}
		/**
		 * 清空所有数据 
		 * 
		 */		
		public function clear():void
		{
			var unitVo:CUnit3DTaskVO;
			var paramVo:CParam3DTaskVO;
			var paramVos:Vector.<CParam3DTaskVO>;
			for(var i:int=0; i<units.length; i+=2)
			{
				unitVo=units[i] as CUnit3DTaskVO;
				unitVo.dispose();
				paramVos=units[i+1] as Vector.<CParam3DTaskVO>;
				for each(paramVo in paramVos)
				{
					paramVo.dispose();
				}
				paramVos.length=0;
			}
			units.length=0;
			realLength=0;
			_length=0;
			_size=0;
			_invalidLength=false;
			roundPoints.clear();
		}
		/**
		 * 销毁计划数据 
		 * 
		 */		
		public function dispose():void
		{
			clear();
			roundPoints.dispose();
			roundPoints=null;
			_units=null;
		}
	}
}