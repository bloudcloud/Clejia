package model
{
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.model.BaseDataModel;
	
	/**
	 * 基础3D对象数据模型类
	 * @author cloud
	 */
	public class BaseObject3DVOModel extends BaseDataModel
	{
		public var currentID:String;
		
		public function BaseObject3DVOModel()
		{
			super();
		}
		
		protected function filterDataByParentID(data:ICObject3DData):Boolean
		{
			return data.parentID==currentID;
		}
		public function initModel():void
		{
			
		}
	}
}