package wallDecorationModule.model.vo
{
	import main.model.vo.task.CParamPartVO;

	public class CClapboardRegionPlanData 
	{
		private var _invalidLength:Boolean;
		private var _units:Vector.<CClapboardUnitVO>;
		private var _realLength:Number=0;
		private var _scaleLength:Number=1;
		private var _scaleHeight:Number=1;
		
		public var wallID:String;
		public var wallIndex:int;
		public var regionID:String;
		public var tilingMode:int;
		public var isLife:Boolean=true;
		
		public function get scaleLength():Number
		{
			return _scaleLength;
		}
		public function set scaleLength(value:Number):void
		{
			if(_scaleLength!=value)
			{
				_invalidLength=true;
				_scaleLength=value;
				var unitVo:CClapboardUnitVO;
				for(var i:int=0; i<_units.length; i++)
				{
					_units[i].scaleLength=value;
					for(var child:CParamPartVO=_units[i].children as CParamPartVO; child!=null; child=child.next as CParamPartVO)
					{
						child.scaleLength=value;
					}
				}
			}
			
		}
		public function get scaleHeight():Number
		{
			return _scaleHeight;
		}
		public function set scaleHeight(value:Number):void
		{
			_scaleHeight=value;
		}
		/**
		 * 获取整个区域方案的总长度 
		 * @return Number
		 * 
		 */
		public function get realLength():Number
		{
			if(_invalidLength)
			{
				_invalidLength=false;
				_realLength=0;
				for(var i:int=0; i<_units.length; i++)
				{
					_realLength+=_units[i].realLength;
				}
			}
			return _realLength;
		}
		public function get units():Vector.<CClapboardUnitVO>
		{
			return _units;
		}
		
		public function CClapboardRegionPlanData()
		{
			_units=new Vector.<CClapboardUnitVO>();
		}
		/**
		 * 缩放方案 
		 * @param scaleRate
		 * 
		 */		
		public function scaleByLength(scaleRate:Number):void
		{
			scaleLength=scaleRate;
			
		}
		/**
		 * 为计划创建一个单元件数据 
		 * @param unitVo
		 * 
		 */		
		public function createOneUnit(unitVo:CClapboardUnitVO):void
		{
			_invalidLength=true;
			_units.push(unitVo);
		}
		/**
		 * 清空所有数据 
		 * 
		 */		
		public function clear():void
		{
			var unitVo:CClapboardUnitVO;
			var paramVo:CParamPartVO;
			var paramVos:Vector.<CParamPartVO>;
			for(var i:int=0; i<units.length; i++)
			{
				unitVo=units[i] as CClapboardUnitVO;
				if(unitVo.isLife)
					unitVo.clear();
			}
			units.length=0;
			_realLength=0;
			_invalidLength=false;
		}
		/**
		 * 销毁计划数据 
		 * 
		 */		
		public function dispose():void
		{
			if(isLife)
				clear();
			_units=null;
		}
	}
}