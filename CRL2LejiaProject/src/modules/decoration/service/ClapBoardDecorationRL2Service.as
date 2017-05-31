package modules.decoration.service
{
	import alternativa.engine3d.objects.Mesh;
	
	import core.service.BaseRL2Service;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
	import main.extension.CTextureMaterial;
	import main.model.WallDataModel;
	
	import utils.DatasEvent;
	
	import wallDecorationModule.service.CClapboardDecorationService;
	
	/**
	 * 护墙板装修服务类
	 * @author cloud
	 */
	public class ClapBoardDecorationRL2Service extends BaseRL2Service
	{
		[Inject]
		public var wallModel:WallDataModel;
		[Inject]
		public var scene3d:CScene3D;
		
		private var _clapboardService:CClapboardDecorationService;
		
		public function ClapBoardDecorationRL2Service()
		{
			super("ClapBoardDecorationRL2Service");
		}
		private function dispatchToRender(mesh:Mesh):void
		{
			dispatchDatasEvent(CommandTypeDict.CMD_RENDERMESH, mesh);
		}
		private function onSetXMLPlanDatas(evt:DatasEvent):void
		{
			_clapboardService.setXmlPlanDatas(evt.data);
		}
//		/**
//		 *	执行选中墙体的命令事件处理
//		 * @param evt
//		 * 
//		 */		
//		private function onSelectWall(evt:DatasEvent):void
//		{
//			var wallVo:CWallVO=CDataUtil.instance.getWallVoByRoundPoint3D(wallModel.walls,evt.data.pointA,evt.data.pointB,false);
//			wallVo.indexIn2DMode=evt.data.index;
//			_clapboardService.setWallData(wallVo);
//		}
		private function onStartShowClapboard(evt:DatasEvent):void
		{
			_clapboardService.start();
			_clapboardService.renderViewCallback=dispatchToRender;
			_clapboardService.setRenderPlanData();
			_clapboardService.excuteStartDecoration();
		}
		private function onClearClapboard(evt:DatasEvent):void
		{
			_clapboardService.stop();
		}
//		private function onUseDecorationPlan(evt:DatasEvent):void
//		{
//			var xml:XML;
//			var tilingMode:int=-1;
//			if(evt.data[0]!=null)
//			{
//				xml=XML(evt.data[0].xml);
//				tilingMode=evt.data[0].mode;
//				_clapboardService.deserialize(xml);
//			}
//			_clapboardService.setRegionData(evt.data[1].index,evt.data[1].point);
//			if(tilingMode<0)
//				_clapboardService.tilingUnitPlan();
//			else
//				_clapboardService.tilingUnitPlan(tilingMode);
//		}
		/**
		 * 通过XML数据对象，执行护墙板方案 
		 * @param xml
		 * 
		 */		
		public function excutePlanByXML(xml:XML):void
		{
			_clapboardService.renderViewCallback=dispatchToRender;
			_clapboardService.deserialize(xml);
		}
		/**
		 * 获取当前选中的模型的code 
		 * @return String
		 * 
		 */		
		public function get selectMesh():L3DMesh
		{
			return _clapboardService.selectMesh as L3DMesh;
		}
		/**
		 * 执行更换纹理操作 
		 * @param bitmapData
		 * 
		 */		
		public function excuteChangeMaterial(material:CTextureMaterial):void
		{
			_clapboardService.excuteChangeMaterial(material);
		}
		/**
		 * 执行更换模型样式操作 
		 * @param mesh
		 * 
		 */		
		public function excuteChangeMesh(mesh:L3DMesh):void
		{
			_clapboardService.excuteChangeMesh(mesh);
		}
		/**
		 * 执行更新护墙板显示操作 
		 * 
		 */		
		public function updateClapboardView(length:Number,height:Number,floorHeight:Number,spacing:Number=0):void
		{
			_clapboardService.updateClapboardView(length,height,floorHeight,spacing);
		}
		
		override protected function addListener():void
		{
			dispatcher.addEventListener(CommandTypeDict.CMD_SET_XMLPLAN_DATAS,onSetXMLPlanDatas);
//			dispatcher.addEventListener(CommandTypeDict.CMD_DECORATION_SELECTWALL,onSelectWall);
//			dispatcher.addEventListener(CommandTypeDict.CMD_USE_DECORATIONPLAN,onUseDecorationPlan);
			dispatcher.addEventListener(CommandTypeDict.CMD_OPEN_SCENE3D,onStartShowClapboard);
			dispatcher.addEventListener(CommandTypeDict.CMD_CLOSE_SCENE3D,onClearClapboard);
			
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(CommandTypeDict.CMD_SET_XMLPLAN_DATAS,onSetXMLPlanDatas);
//			dispatcher.removeEventListener(CommandTypeDict.CMD_DECORATION_SELECTWALL,onSelectWall);
//			dispatcher.removeEventListener(CommandTypeDict.CMD_USE_DECORATIONPLAN,onUseDecorationPlan);
			dispatcher.removeEventListener(CommandTypeDict.CMD_OPEN_SCENE3D,onStartShowClapboard);
			dispatcher.removeEventListener(CommandTypeDict.CMD_CLOSE_SCENE3D,onClearClapboard);
		}
		override public function start():void
		{
			super.start();
			_clapboardService=new CClapboardDecorationService();
			_clapboardService.initDecoration(scene3d.stage3D);
			_clapboardService.start();
//			_testMesh=new Mesh();
//			scene3d.addChild(_testMesh);
//			_clapboardService.mesh=_testMesh;
		}
		
		override public function stop():void
		{
			super.stop();
			_clapboardService.stop();
			_clapboardService=null;
		}
	}
}