package model
{
	import dic.KitchenGlobalDic;
	
	import flash.geom.Vector3D;
	
	import interfaces.ICFurnitureModel;
	import interfaces.ICFurnitureVO;
	
	import model.vo.BaseFurnitureVO;
	
	/**
	 *	3D家具基础数据模型类
	 * @author cloud
	 */
	public class BaseFurnitureSetModel implements ICFurnitureModel
	{
		protected var _invalidProperty:Boolean;
		
		protected var _datas:Vector.<BaseFurnitureVO>;
		
		public function get datas():Vector.<BaseFurnitureVO>
		{
			return _datas;
		}
		
		protected var _length:uint;
		
		public function get length():uint
		{
			if(_invalidProperty)
			{
				_invalidProperty=false;
				updateProperty();
			}
			return _length;
		}
		
		protected var _width:uint;
		
		public function get width():uint
		{
			if(_invalidProperty)
			{
				_invalidProperty=false;
				updateProperty();
			}
			return _width;
		}
		
		protected var _height:uint;	
		
		public function get height():uint
		{
			if(_invalidProperty)
			{
				_invalidProperty=false;
				updateProperty();
			}
			return _height;
		}

		protected var _direction:int;
		/**
		 * 获取方向 
		 * @return uint
		 * 
		 */		
		public function get direction():int
		{
			if(_invalidProperty)
			{
				_invalidProperty=false;
				updateProperty();
			}
			return _direction;
		}
		/**
		 * 设置方向 
		 * @param value
		 * 
		 */		
		public function set direction(value:int):void
		{
			if(_direction!=value)
			{
				_invalidProperty=true;
				_direction = value;
			}
		}
		
		protected var _combinePos:Vector3D;
		
		public function get combinePos():Vector3D
		{
			if(_invalidProperty)
			{
				_invalidProperty=false;
				updateProperty();
			}
			return _combinePos;
		}
		public function BaseFurnitureSetModel()
		{
			_datas=new Vector.<BaseFurnitureVO>();
			_combinePos=new Vector3D();
			_direction=KitchenGlobalDic.DIR_FRONT;
		}
		
		protected function updateProperty():void
		{
		}
		/**
		 * 执行移动处理
		 * @param furnitureID	家具的唯一id
		 * @param furniturePos	家具的最新坐标
		 * @param furnitureDir 家具的方向
		 * @return Boolean
		 * 
		 */		
		public function excuteMove(furnitureID:String,furnitureDir:int,outputPos:Vector3D):Boolean
		{
			return false;
		}
		
		public function addFurnitureVO(vo:ICFurnitureVO):void
		{
			_datas.push(vo);
			(vo as BaseFurnitureVO).index=_datas.length-1;
		}
		public function removeFurnitureVO(vo:ICFurnitureVO):void
		{
			var index:int = (vo as BaseFurnitureVO).index;
			_datas.removeAt(index);
			var length:uint=_datas.length;
			for(var i:int=index; i<length; i++)
			{
				_datas[i].index=i;
			}
			vo.clear();
		}
		public function updateFurnitureVO(vo:Object):void
		{
			getFurnitureVOByID(vo.mark).updateVo(vo);
		}
		public function getFurnitureVOByID(id:String):ICFurnitureVO
		{
			for each(var vo:BaseFurnitureVO in _datas)
			{
				if(vo.uniqueID==id)
					return vo;
			}
			return null;
		}	
		public function clear():void
		{
			for each(var data:BaseFurnitureVO in _datas)
			{
				data.clear();
			}
			_datas.length=0;
		}
	}
}