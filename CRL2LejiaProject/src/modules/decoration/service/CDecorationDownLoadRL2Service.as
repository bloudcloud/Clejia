package modules.decoration.service
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	
	import L3DLibrary.L3DLibraryEvent;
	import L3DLibrary.L3DMaterialInformations;
	
	import core.service.BaseRL2Service;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
	import main.extension.CTextureMaterial;
	import main.model.WallDataModel;
	
	import utils.DatasEvent;
	
	/**
	 * 装修下载服务
	 * @author cloud
	 */
	public class CDecorationDownLoadRL2Service extends BaseRL2Service
	{
		[Inject]
		public var scene:CScene3D;
		[Inject]
		public var wallModel:WallDataModel;
		[Inject]
		public var clapboardService:ClapBoardDecorationRL2Service;
		
		private var _materialInfo:L3DMaterialInformations;
		
		public function CDecorationDownLoadRL2Service(type:String="")
		{
			super(type);
		}
		private function onStartLoadPlan(evt:DatasEvent):void
		{
			_materialInfo=evt.data as L3DMaterialInformations;
			_materialInfo.addEventListener(L3DMaterialInformations.DownloadLinkedData, onDownloadDecorationPlanHandler);
			_materialInfo.DownloadLinkedDataBuffer();
		}
		private function onStartLoadMaterial(evt:DatasEvent):void
		{
			_materialInfo=evt.data as L3DMaterialInformations;
			_materialInfo.addEventListener(L3DLibraryEvent.DownloadMaterial, onDownloadDecorationMaterialHandler);
			_materialInfo.DownloadMaterial();
		}
		private function onStartLoadMesh(evt:DatasEvent):void
		{
			_materialInfo=evt.data as L3DMaterialInformations;
			if(clapboardService.selectMesh==null || clapboardService.selectMesh.Code==_materialInfo.code) return;
			_materialInfo.addEventListener(L3DLibraryEvent.DownloadMaterial, OnDownloadDecorationMeshHandler);
			_materialInfo.DownloadMaterial();
		}
		/**
		 * 执行下载方案处理 
		 * @param evt
		 * 
		 */		
		private function onDownloadDecorationPlanHandler(evt:L3DLibraryEvent):void
		{
			evt.target.removeEventListener(L3DMaterialInformations.DownloadLinkedData, onDownloadDecorationPlanHandler);
			clapboardService.excutePlanByXML(XML(evt.data));
			scene.root.dispatchEvent(new DatasEvent(CommandTypeDict.CMD_ISLOADINGCOMPLETE,evt.data));
		}
		/**
		 * 执行下载材质处理 
		 * @param evt
		 * 
		 */		
		private function onDownloadDecorationMaterialHandler(evt:L3DLibraryEvent):void
		{
			evt.target.removeEventListener(L3DLibraryEvent.DownloadMaterial, onDownloadDecorationMaterialHandler);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadBitmapDataHandler);
			loader.loadBytes(evt.MaterialBuffer);
		}
		private function OnDownloadDecorationMeshHandler(evt:L3DLibraryEvent):void
		{
			evt.target.removeEventListener(L3DLibraryEvent.DownloadMaterialInfo,OnDownloadDecorationMeshHandler);
			var mesh:L3DMesh=L3DModel.FromBuffer(evt.MaterialBuffer).Export(scene.stage3D);
			clapboardService.excuteChangeMesh(mesh);
		}
		private function onLoadBitmapDataHandler(evt:Event):void
		{
			evt.target.removeEventListener(Event.COMPLETE, onLoadBitmapDataHandler);
			var obj:Bitmap=(evt.currentTarget as LoaderInfo).content as Bitmap;
			var bitmapTextureResource:L3DBitmapTextureResource=new L3DBitmapTextureResource(obj.bitmapData,null,scene.stage3D);
			bitmapTextureResource.Url=_materialInfo.url;
			bitmapTextureResource.Code=_materialInfo.code;
			clapboardService.excuteChangeMaterial(new CTextureMaterial(bitmapTextureResource));
		}
		
		override protected function addListener():void
		{
			dispatcher.addEventListener(CommandTypeDict.CMD_START_LOADPLAN,onStartLoadPlan);
			dispatcher.addEventListener(CommandTypeDict.CMD_START_LOADMATERIAL,onStartLoadMaterial);
			dispatcher.addEventListener(CommandTypeDict.CMD_START_LOADMESH,onStartLoadMesh);
		}
		override protected function removeListener():void
		{
			dispatcher.removeEventListener(CommandTypeDict.CMD_START_LOADPLAN,onStartLoadPlan);
			dispatcher.removeEventListener(CommandTypeDict.CMD_START_LOADMATERIAL,onStartLoadMaterial);
			dispatcher.removeEventListener(CommandTypeDict.CMD_START_LOADMESH,onStartLoadMesh);
		}
	}
}