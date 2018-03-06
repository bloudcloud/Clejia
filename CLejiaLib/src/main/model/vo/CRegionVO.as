package main.model.vo
{
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import main.model.vo.task.CBaseTaskObject3DVO;

	/**
	 *  区域数据类
	 * @author cloud
	 * 
	 */	
	public class CRegionVO extends CBaseObject3DVO
	{
		private var _invalidLength:Boolean;
		private var _realLength:Number;
		private var _units:Vector.<CBaseTaskObject3DVO>;
		
		/**
		 * 所在房间的索引 
		 */		
		public var roomID:String;
		/**
		 * 所在房间中的墙的ID 
		 */		
		public var wallID:String;
		/**
		 *  所在房间中墙的索引
		 */		
		public var wallIndex:int;
		/**
		 * 当前的索引 
		 */		
		public var index:int;
		/**
		 * 阵列模式 
		 */		
		public var mode:int;
		/**
		 * 护墙板区域计划源数据 
		 */		
		public var planXML:XML;
		/**
		 * 区域起始点方向角的偏移（值为正表示内向缩进，值为负表示外向延伸）
		 */	
		public var startOffsetScale:Number;
		/**
		 * 区域终止点方向角的偏移 （值为正表示内向缩进，值为负表示外向延伸）
		 */	
		public var endOffsetScale:Number;
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
					_realLength+=_units[i].length;
				}
			}
			return _realLength;
		}
		/**
		 *  获取单元件集合
		 * @return Vector.<CBaseTaskObject3DVO>
		 * 
		 */		
		public function get units():Vector.<CBaseTaskObject3DVO>
		{
			return _units;
		}
		
		public function CRegionVO()
		{
			super();
			startOffsetScale=0;
			endOffsetScale=0;
			_units=new Vector.<CBaseTaskObject3DVO>();
		}
		/**
		 * 添加一个单元件数据 
		 * @param unitVo
		 * 
		 */		
		public function addUnitVo(unitVo:CBaseTaskObject3DVO):void
		{
			_invalidLength=true;
			_units.push(unitVo);
		}
		
		override public function clear():void
		{
			super.clear();
			startOffsetScale=0;
			endOffsetScale=0;
			var paramVo:CBaseTaskObject3DVO;
			for each(paramVo in units)
			{
				if(paramVo.isLife)
					paramVo.clear();
			}
			units.length=0;
			planXML=null;
		}
	
	}
}