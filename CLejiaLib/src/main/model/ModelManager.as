package main.model
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import cloud.core.interfaces.ICObject3DData;
	
	import kitchenModule.model.CabinetModel;
	import kitchenModule.model.HangingCabinetModel;
	
	import main.dict.Object3DDict;
	import main.model.vo.CObject3DVO;
	import main.model.vo.CWallVO;

	/**
	 * 数据模型管理类
	 * @author cloud
	 */
	public class ModelManager
	{
		private static var _instance:ModelManager;
		public static function get instance():ModelManager
		{
			return _instance ||= new ModelManager(new Singleton());
		}
		
		private var _modelDic:Dictionary;
		
		public function ModelManager(enforcer:Singleton)
		{
			_modelDic=new Dictionary();
		}
		
		private function doCreateObject3DData(type:uint):ICObject3DData
		{
			var vo:ICObject3DData;
			switch(type)
			{
				case Object3DDict.OBJECT3D_WALL:
					vo=new CWallVO();
					break;
				default:
					vo=new CObject3DVO();
					break;
			}
			return vo;
		}
		/**
		 * 根据数据类型，获取数据模型对象 
		 * @param type	数据类型
		 * @return BaseObject3DDataModel
		 * 
		 */		
		public function getModel(type:uint):BaseObject3DDataModel
		{
			if(!_modelDic.hasOwnProperty(type))
			{
				switch(type)
				{
					case Object3DDict.OBJECT3D_CABINET:
						return new CabinetModel();
					case Object3DDict.OBJECT3D_HANGING_CABINET:
						return new HangingCabinetModel();
					case Object3DDict.OBJECT3D_WALL:
						return new WallDataModel();
				}
			}
			return _modelDic[type] as BaseObject3DDataModel;
		}
		/**
		 * 创建3D对象数据 
		 * @param uniqueID
		 * @param type
		 * @param parentID
		 * @param length
		 * @param width
		 * @param height
		 * @param x
		 * @param y
		 * @param z
		 * @param rotation
		 * 
		 */		
		public function createObject3DData(uniqueID:String,type:uint,parentID:String,length:Number,width:Number,height:Number,x:Number,y:Number,z:Number,rotation:Number):ICObject3DData
		{
			var vo:ICObject3DData = doCreateObject3DData(type);
			vo.uniqueID=uniqueID;
			vo.type=type;
			vo.parentID=parentID;
			vo.length=length;
			vo.width=width;
			vo.height=height;
			vo.x=x;
			vo.y=y;
			vo.z=z;
			vo.rotation=rotation;
			vo.direction=new Vector3D(Math.cos(rotation),Math.sin(rotation),0);
			return vo;
		}
	}
}
class Singleton{}