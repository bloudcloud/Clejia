package modules.kitchen.service
{
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.events.CDataEvent;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import core.service.BaseRL2Service;
	
	import dict.CommandTypeDict;
	
	import kitchenModule.service.CCabinetService;
	
	import main.a3d.support.CScene3D;
	import main.dict.CDataTypeDict;
	import main.model.WallDataModel;
	import main.model.vo.CRoom3DVO;
	
	/**
	 * 橱柜模块服务类
	 * @author cloud
	 * @2017-6-29
	 */
	public class CCabinetRL2Service extends BaseRL2Service
	{
		[Inject]
		public var wallModel:WallDataModel;
		[Inject]
		public var scene3d:CScene3D;
		
		private var _cabinetService:CCabinetService;

		public function CCabinetRL2Service(clsName:String="CCabinetRL2Service")
		{
			super(clsName);
			_cabinetService=new CCabinetService();
		}
		private function onStartCabinetModule(evt:CDataEvent):void
		{
			_cabinetService.renderViewCallback ||= function(mesh:Mesh):void{dispatchDataEvent(CommandTypeDict.CMD_RENDERMESH,mesh)};
		}
		private function onStopCabinetModule(evt:CDataEvent):void
		{
			
		}
		private function onLoadPlanSuccess(evt:CDataEvent):void
		{
			var xml:XML=XML(evt.data);
			var floorVo:CRoom3DVO=wallModel.getDataByTypeAndID(CDataTypeDict.OBJECT3D_ROOM,wallModel.curRoomID) as CRoom3DVO;
			var root:CBaseObject3DVO=new CBaseObject3DVO();
			_cabinetService.deserializeXML(xml,floorVo);
			_cabinetService.excuteTask();
		} 
		private function onLoadMaterialSuccess(evt:CDataEvent):void
		{
			
		}
		private function onLoadMeshSuccess(evt:CDataEvent):void
		{
			
		}
		override protected function addListener():void
		{
			dispatcher.addEventListener(CommandTypeDict.CMD_OPEN_SCENE3D,onStartCabinetModule);
			dispatcher.addEventListener(CommandTypeDict.CMD_CLOSE_SCENE3D,onStopCabinetModule);
			dispatcher.addEventListener(CommandTypeDict.CMD_LOADPLAN_SUCCESS,onLoadPlanSuccess);
			dispatcher.addEventListener(CommandTypeDict.CMD_LOADMATERIAL_SUCCESS,onLoadMaterialSuccess);
			dispatcher.addEventListener(CommandTypeDict.CMD_LOADMESH_SUCCESS,onLoadMeshSuccess);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(CommandTypeDict.CMD_OPEN_SCENE3D,onStartCabinetModule);
			dispatcher.removeEventListener(CommandTypeDict.CMD_CLOSE_SCENE3D,onStopCabinetModule);
			dispatcher.removeEventListener(CommandTypeDict.CMD_LOADPLAN_SUCCESS,onLoadPlanSuccess);
			dispatcher.removeEventListener(CommandTypeDict.CMD_LOADMATERIAL_SUCCESS,onLoadMaterialSuccess);
			dispatcher.removeEventListener(CommandTypeDict.CMD_LOADMESH_SUCCESS,onLoadMeshSuccess);
		}
		override public function start():void
		{
			super.start();
			_cabinetService.initService(scene3d.stage3D);
			_cabinetService.start();
		}
	}
}