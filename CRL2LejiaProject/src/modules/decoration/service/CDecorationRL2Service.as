package modules.decoration.service
{
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.events.CDataEvent;
	
	import core.service.BaseRL2Service;
	
	import dict.CommandTypeDict;
	import dict.StateTypeDict;
	
	import main.a3d.support.CScene3D;
	import main.model.WallDataModel;
	
	import wallDecorationModule.service.CBackgroundWallService;
	import wallDecorationModule.service.CClapboardDecorationService;
	import wallDecorationModule.service.CDoorDecorationService;
	
	/**
	 * 护墙板装修服务类
	 * @author cloud
	 */
	public class CDecorationRL2Service extends BaseRL2Service
	{
		[Inject]
		public var wallModel:WallDataModel;
		[Inject]
		public var scene3d:CScene3D;
		
		private var _clapboardService:CClapboardDecorationService;
		private var _backgroundWallService:CBackgroundWallService;
		private var _doorService:CDoorDecorationService;
		private var _stateMode:uint;
		
		public function CDecorationRL2Service()
		{
			super("CDecorationRL2Service");
			
			_clapboardService=new CClapboardDecorationService();
			_backgroundWallService= new CBackgroundWallService();
			_doorService=new CDoorDecorationService();
		}
		private function dispatchToRender(mesh:Mesh):void
		{
			dispatchDataEvent(CommandTypeDict.CMD_RENDERMESH, mesh);
		}
      
		private function onSetXMLPlanDatas(evt:CDataEvent):void
		{
			_stateMode=evt.data.state;
			switch(_stateMode)
			{
				case StateTypeDict.STATE_CLAPBOARD:
//					_clapboardService.setXmlPlanDatas(evt.data.datas);
					break;
				case StateTypeDict.STATE_BAKCGROUNDWALL:
					_backgroundWallService.setXmlPlanDatas(evt.data.datas);
					break;
				case StateTypeDict.STATE_PARAMDOOR:
					_doorService.setXmlPlanDatas(evt.data.datas);
					break;
			}
		}
		private function onStartShowClapboard(evt:CDataEvent):void
		{
			switch(_stateMode)
			{
				case StateTypeDict.STATE_CLAPBOARD:
//					_clapboardService.renderViewCallback=dispatchToRender;
//					_clapboardService.setRenderPlanData();
//					_clapboardService.excuteStartDecoration();
//					_clapboardService.excuteTask();
					break;
				case StateTypeDict.STATE_BAKCGROUNDWALL:
//					_backgroundWallService.renderViewCallback=dispatchToRender;
//					_backgroundWallService.invalidRenderData=true;
//					_backgroundWallService.excuteDecoration();
//					_backgroundWallService.excuteTask();
					break;
				case StateTypeDict.STATE_PARAMDOOR:
					_doorService.showView3D(null,null,dispatchToRender);
					_doorService.excuteDecoration();
					break;
			}
		}
		private function onClearClapboard(evt:CDataEvent):void
		{
			_clapboardService.stop();
		}
//		private function onLoadPlanSuccess(evt:CDataEvent):void
//		{
//			//下载方案数据成功
//			var xml:XML=XML(evt.data);
//
//		}
		/**
		 * 通过XML数据对象，执行护墙板方案 
		 * @param xml
		 * 
		 */		
		public function excutePlanByXML(xml:XML,roomID:String,wallIndex:int,regionIndex:int):void
		{
			_backgroundWallService.updatePlanData(xml,roomID,wallIndex,regionIndex);
		}
//		/**
//		 * 获取当前选中的模型的code 
//		 * @return String
//		 * 
//		 */		
//		public function get selectMesh():L3DMesh
//		{
//			return _clapboardService.selectMesh as L3DMesh;
//		}
//		/**
//		 * 执行更换纹理操作 
//		 * @param bitmapData
//		 * 
//		 */		
//		public function excuteChangeMaterial(material:CTextureMaterial):void
//		{
//			_clapboardService.excuteChangeMaterial(material);
//		}
//		/**
//		 * 执行更换模型样式操作 
//		 * @param mesh
//		 * 
//		 */		
//		public function excuteChangeMesh(mesh:L3DMesh):void
//		{
//			_clapboardService.excuteChangeMesh(mesh);
//		}
//		/**
//		 * 执行更新护墙板显示操作 
//		 * 
//		 */		
//		public function updateClapboardView(length:Number,height:Number,floorHeight:Number,spacing:Number=0):void
//		{
//			_clapboardService.updateClapboardView(length,height,floorHeight,spacing);
//		}
		
		override protected function addListener():void
		{
//			dispatcher.addEventListener(CommandTypeDict.CMD_LOADPLAN_SUCCESS,onLoadPlanSuccess);
			dispatcher.addEventListener(CommandTypeDict.CMD_SET_XMLPLAN_DATAS,onSetXMLPlanDatas);
			dispatcher.addEventListener(CommandTypeDict.CMD_OPEN_SCENE3D,onStartShowClapboard);
			dispatcher.addEventListener(CommandTypeDict.CMD_CLOSE_SCENE3D,onClearClapboard);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(CommandTypeDict.CMD_SET_XMLPLAN_DATAS,onSetXMLPlanDatas);
			dispatcher.removeEventListener(CommandTypeDict.CMD_OPEN_SCENE3D,onStartShowClapboard);
			dispatcher.removeEventListener(CommandTypeDict.CMD_CLOSE_SCENE3D,onClearClapboard);
		}
		override public function start():void
		{
			super.start();
			_clapboardService.initDecorationService(scene3d.stage3D);
			_backgroundWallService.initDecorationService(scene3d.stage3D);
			_doorService.initDecorationService(scene3d.stage3D);
		
			_clapboardService.start();
			_backgroundWallService.start();
			_doorService.start();
		}
		
		override public function stop():void
		{
			super.stop();
			_clapboardService.stop();
			_backgroundWallService.stop();
			_doorService.stop();
		}
	}
}