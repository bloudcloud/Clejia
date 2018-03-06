package main.model
{
	import cloud.core.mvcs.model.BaseDataModel;
	
	/**
	 * 基础3D对象数据模型类
	 * @author cloud
	 */
	public class BaseObject3DDataModel extends BaseDataModel
	{
		private var _invalidDataCache:Boolean;
		
		protected var _parentID:String;
		public function get parentID():String
		{
			return _parentID;
		}
		public function set parentID(value:String):void
		{
			if(_parentID!=value)
			{
				_parentID=value;
				initDataCache();
			}
			else
			{
				_parentID=value;
			}
		}
		public function BaseObject3DDataModel()
		{
			super();
		}
		/**
		 * 初始化数据模型的数据缓存，该方法需要子类重写实现 
		 * 
		 */		
		protected function initDataCache():void
		{
		}
		
	}
}