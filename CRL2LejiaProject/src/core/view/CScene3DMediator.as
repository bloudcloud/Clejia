package core.view
{
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.events.CDataEvent;
	import cloud.core.utils.CDebugUtil;
	
	import dict.CommandTypeDict;
	
	import main.a3d.support.CScene3D;
	import main.dict.EventTypeDict;
	
	import rl2.mvcs.view.BaseMediator;
	
	/**
	 *  场景中介类
	 * @author cloud
	 */
	public class CScene3DMediator extends BaseMediator
	{
		[Inject]
		public var scene:CScene3D;
		
		private var _floorSet:FloorViewSet;
		private var _wallSet:WallViewSet;
		
		public function CScene3DMediator()
		{
			super("CScene3DMediator");
			_floorSet=new FloorViewSet();
			_wallSet=new WallViewSet();
		}
		private function onRenderMesh(evt:CDataEvent):void
		{
			var l3dMesh:L3DMesh=evt.data as L3DMesh;
			if(l3dMesh)
			{
				_wallSet.addFurnitureView(l3dMesh);
			}
			else
			{
				_wallSet.addFurnitureView(evt.data as Mesh);
			}
		}
		private function onClicked(evt:MouseEvent3D):void
		{
			CDebugUtil.Instance.traceStr(evt.target); 
		}
		override protected function addListener():void
		{
			dispatcher.addEventListener(CommandTypeDict.CMD_RENDERMESH,onRenderMesh);
		}
		
		override public function initialize():void
		{
			scene.addChild(_floorSet);
			scene.addChild(_wallSet);
			super.initialize();
			context.dispatchEvent(new CDataEvent(EventTypeDict.EVENT_INITCOMPLETE));
		}
	}
}