package modules.main.service
{
	import flash.events.Event;
	
	import L3DLibrary.L3DLibraryEvent;
	import L3DLibrary.L3DMaterialInformations;
	
	import cloud.core.events.CDataEvent;
	
	import core.service.BaseRL2Service;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
	
	/**
	 * 下载服务类
	 * @author cloud
	 * @2017-6-29
	 */
	public class CDownloadRL2Service extends BaseRL2Service
	{
		[Inject]
		public var scene:CScene3D;

		private var _materialInfo:L3DMaterialInformations;
		
		public function CDownloadRL2Service(clsName:String="CDownloadRL2Service")
		{
			super(clsName);
		}
		private function onStartLoadPlan(evt:CDataEvent):void
		{
			_materialInfo=evt.data as L3DMaterialInformations;
			_materialInfo.addEventListener(L3DMaterialInformations.DownloadLinkedData, onDownloadPlanHandler);
			_materialInfo.DownloadLinkedDataBuffer();
		}
		private function onStartLoadMaterial(evt:CDataEvent):void
		{
			_materialInfo=evt.data as L3DMaterialInformations;
			_materialInfo.addEventListener(L3DLibraryEvent.DownloadMaterial, onDownloadMaterialHandler);
			_materialInfo.DownloadMaterial();
		}
		private function onStartLoadMesh(evt:CDataEvent):void
		{
			_materialInfo=evt.data as L3DMaterialInformations;
//			if(decorationService.selectMesh==null || decorationService.selectMesh.Code==_materialInfo.code) return;
			_materialInfo.addEventListener(L3DLibraryEvent.DownloadMaterial, OnDownloadMeshHandler);
			_materialInfo.DownloadMaterial();
		}
		/**
		 * 执行下载方案处理 
		 * @param evt
		 * 
		 */		
		private function onDownloadPlanHandler(evt:L3DLibraryEvent):void
		{
			evt.target.removeEventListener(L3DMaterialInformations.DownloadLinkedData, onDownloadPlanHandler);
			dispatcher.dispatchEvent(new CDataEvent(CommandTypeDict.CMD_LOADPLAN_SUCCESS,evt.data));
		}
		/**
		 * 执行下载材质处理 
		 * @param evt
		 * 
		 */		
		private function onDownloadMaterialHandler(evt:L3DLibraryEvent):void
		{
			evt.target.removeEventListener(L3DLibraryEvent.DownloadMaterial, onDownloadMaterialHandler);
			dispatcher.dispatchEvent(new CDataEvent(CommandTypeDict.CMD_LOADMATERIAL_SUCCESS,evt.data));
//			var loader:Loader = new Loader();
//			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadBitmapDataHandler);
//			loader.loadBytes(evt.MaterialBuffer);
		}
		private function OnDownloadMeshHandler(evt:L3DLibraryEvent):void
		{
			evt.target.removeEventListener(L3DLibraryEvent.DownloadMaterialInfo,OnDownloadMeshHandler);
			dispatcher.dispatchEvent(new CDataEvent(CommandTypeDict.CMD_LOADMESH_SUCCESS,evt.data));
//			var mesh:L3DMesh=L3DModel.FromBuffer(evt.MaterialBuffer).Export(scene.stage3D);
//			decorationService.excuteChangeMesh(mesh);
		}
		private function onLoadBitmapDataHandler(evt:Event):void
		{
			evt.target.removeEventListener(Event.COMPLETE, onLoadBitmapDataHandler);
//			var obj:Bitmap=(evt.currentTarget as LoaderInfo).content as Bitmap;
//			var bitmapTextureResource:L3DBitmapTextureResource=new L3DBitmapTextureResource(obj.bitmapData,null,scene.stage3D);
//			bitmapTextureResource.Url=_materialInfo.url;
//			bitmapTextureResource.Code=_materialInfo.code;
//			decorationService.excuteChangeMaterial(new CTextureMaterial(bitmapTextureResource));
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