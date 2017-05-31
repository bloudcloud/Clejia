package core.view
{
	import flash.events.MouseEvent;
	
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.utils.CDebug;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
	
	import rl2.mvcs.view.BaseMediator;
	
	import utils.DatasEvent;
	
	/**
	 *  场景中介类
	 * @author cloud
	 */
	public class Scene3DMediator extends BaseMediator
	{
		[Inject]
		public var scene:CScene3D;
		
		private var _floorSet:FloorViewSet;
		private var _wallSet:WallViewSet;
//		private var _cabinetSet:CabinetViewSet;
//		private var _createBoard:Box;
//		private var _createShelter:Plane;
		
		public function Scene3DMediator()
		{
			super("Scene3DMediator");
			_floorSet=new FloorViewSet();
			_wallSet=new WallViewSet();
//			_cabinetSet=new CabinetViewSet();
		}
		private function onRenderMesh(evt:DatasEvent):void
		{
			var l3dMesh:L3DMesh=evt.data as L3DMesh;
			if(l3dMesh)
			{
//				l3dMesh.addEventListener(MouseEvent3D.CLICK,onClicked);
				_wallSet.addFurnitureView(l3dMesh);
			}
			else
			{
				_wallSet.addFurnitureView(evt.data as Mesh);
			}
		}
		private function onClicked(evt:MouseEvent3D):void
		{
			CDebug.instance.traceStr(evt.target);
		}
		override protected function addListener():void
		{
			dispatcher.addEventListener(CommandTypeDict.CMD_RENDERMESH,onRenderMesh);
		}
		
		override public function initialize():void
		{
			super.initialize();
			scene.addChild(_floorSet);
			scene.addChild(_wallSet);
		}
	}
}