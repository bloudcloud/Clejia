package 
{
	import flash.display.Stage3D;
	import flash.geom.Vector3D;
	
	import mx.core.UIComponent;
	
	import cloud.core.model.BaseDataModel;
	import cloud.core.singleton.CVector3DUtil;
	
	import kitchenModule.CKitchenModuleImp;
	import kitchenModule.interfaces.ICKitchenModule;
	
	import main.dict.Object3DDict;
	import main.model.ModelManager;
	import main.model.vo.CRoom3DVO;
	import main.model.vo.CWallVO;
	
	import wallDecorationModule.CClapboardDecorationModuleImp;
	import wallDecorationModule.CWaistDecorationModuleImp;
	import wallDecorationModule.dict.CDecorationParamDict;
	import wallDecorationModule.interfaces.ICClapboardDecorationModule;
	import wallDecorationModule.interfaces.ICDecorationModule;
	import wallDecorationModule.interfaces.ICWaistDecorationModule;
	
	/**
	 *  模块管理类
	 * @author cloud
	 */
	public class CLejiaModules extends UIComponent implements ICLejiaModules
	{
		private var _kithenModule:CKitchenModuleImp;
		private var _decorationModule:CWaistDecorationModuleImp;
		private var _clapboardDecorationModule:CClapboardDecorationModuleImp;
		private var _dataModel:BaseDataModel;
		
		public function CLejiaModules()
		{
			super();
			_dataModel=new BaseDataModel();
		}
		
//		/**
//		 * 初始化数据 
//		 * @param data
//		 * 
//		 */		
//		public function initData(data:ICData):void
//		{
//			_dataModel ||= new BaseDataModel();
//			_dataModel.addData(data);
//		}
//		
		/**
		 * 创建房间数据 
		 * @param uniqueID
		 * @param parentID
		 * 
		 */		
		public function createRoomVo(uniqueID:String,parentID:String=null):void
		{
			var roomVo:CRoom3DVO = new CRoom3DVO();
			roomVo.uniqueID=uniqueID;
			roomVo.parentID=parentID;
			roomVo.type=Object3DDict.OBJECT3D_ROOM;
			_dataModel.addData(roomVo);
		}
		/**
		 * 创建墙体数据  
		 * @param uniqueID
		 * @param parentID
		 * @param roomHeight
		 * @param startPos
		 * @param endPos
		 * 
		 */			
		public function createWallVo(uniqueID:String,parentID:String,roomHeight:Number,startPos:Vector3D,endPos:Vector3D,index2DMode:int,roomIndex:int):void
		{
			var direction:Vector3D=endPos.subtract(startPos);
			var length:Number=direction.length;
			var width:Number=CDecorationParamDict.WALL_DISPLAY_FIX_WIDTH;
			var height:Number=roomHeight;
			var x:Number=(startPos.x+endPos.x)*.5;
			var y:Number=(startPos.y+endPos.y)*.5;
			var z:Number=roomHeight*.5;
			var rotation:Number=CVector3DUtil.instance.calculateRotationByAxis(direction,CVector3DUtil.X_AXIS);
			var wallVo:CWallVO=ModelManager.instance.createObject3DData(Object3DDict.OBJECT3D_WALL,uniqueID,parentID,length,width,height,x,y,z,rotation) as CWallVO;
			wallVo.indexIn2DMode=index2DMode;
			wallVo.roomIndex=roomIndex;
			wallVo.startPos=startPos;
			wallVo.endPos=endPos;
			direction.normalize();
			wallVo.direction=direction;
			_dataModel.addData(wallVo);
		}
		public function initDecorationModule(stage3d:Stage3D):void
		{
			_decorationModule ||= new CWaistDecorationModuleImp();
			_decorationModule.initDecorationModule(stage3d);
			_clapboardDecorationModule ||= new CClapboardDecorationModuleImp();
			_clapboardDecorationModule.initDecorationModule(stage3d);
		}
		/**
		 * 启动应用 
		 * 
		 */		
		public function start():void
		{
//			_dataModel=new BaseDataModel();
//			_kithenModule.start();
//			_decorationModule.start();
//			_clapboardDecorationModule.start();
		}
		/**
		 * 停止应用 
		 * 
		 */		
		public function stop():void
		{
//			_dataModel=null;
//			_kithenModule.stop();
//			_decorationModule.stop();
//			_clapboardDecorationModule.stop();
		}
		public function get kitchenModule():ICKitchenModule
		{
			return _kithenModule ||= new CKitchenModuleImp();
		}
		public function get waistDecorationModule():ICWaistDecorationModule
		{
			return _decorationModule ||= new CWaistDecorationModuleImp();
		}
		
		public function get clapboardDecorationModule():ICClapboardDecorationModule
		{
			return _clapboardDecorationModule ||= new CClapboardDecorationModuleImp();
		}
	}
}