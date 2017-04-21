package a3d.support
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.objects.WireFrame;
	import alternativa.engine3d.primitives.Box;
	
	import cloud.core.utils.Ray3D;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import rl2.mvcs.view.IRenderAble;
	
	use namespace alternativa3d;
	
	public class Scene3D extends Object3D
	{
		private var _container:DisplayObjectContainer;
		private var _stage:Stage;
		private var _stage3D:Stage3D;

		public function get stage3D():Stage3D
		{
			return _stage3D;
		}

		private var _mouseRay:Ray3D;
		private var _zFactor:Number;
		private var camera:Camera3D;
		
		public var view:View;
		public var releaseContext3DOnClose:Boolean = true;
		public var setupRendering:Boolean=true;
		public var ground:Box;
		public var controller:SimpleObjectController;
		public var onInitEvent:Function;
		public var enterFrameCallBack:Function;
		
		public function Scene3D(container:DisplayObjectContainer, stage:Stage)
		{
			_container = container;
			_stage=stage;
			_stage3D=stage.stage3Ds[0];
			_mouseRay = new Ray3D();
			
			releaseContext3DOnClose = _stage3D!=null ? false:true;
			
			view = new View(container.width, container.height, false, 0xfff111, 0, 0);
			camera = new Camera3D(0.1, 50000);
			camera.debug = true;
			camera.view = view;
			
			controller = new SimpleObjectController(stage, camera, 5000, 0.5,0.5);
			controller.stopMouseLook();
			controller.setObjectPosXYZ(-1000,-2000,1000);
			controller.lookAtXYZ(0,0,0);
			
			container.addChild(view);
			container.addChild(camera.diagram);
			
			ground = new Box(8000,8000,1,5,5);
			ground.z = ground.boundBox.maxZ-ground.boundBox.minZ>>1;
			ground.mouseEnabled = true;
			var groundMat:FillMaterial = new FillMaterial(0x888888);
			ground.setMaterialToAllSurfaces(groundMat);
			
			makeAxes();
			
			this.addChild(camera);
			this.addChild(ground);
			
			if(_stage3D.context3D==null){
				_stage3D.addEventListener(Event.CONTEXT3D_CREATE,onContextCreate);
				_stage3D.requestContext3D();
			}else{
				onContextCreate(new Event(Event.CONTEXT3D_CREATE));
			}
//			if(_stage3D == null){
//				for(var i:int=0;i<4;i++){
//					if(_stage.stage3Ds[i].context3D == null && !_stage.stage3Ds[i].hasEventListener(Event.CONTEXT3D_CREATE)){
//						_stage3D = _stage.stage3Ds[i];
//						break;
//					}
//				}
//			}
		}
		
		private function findZFactor():Number{
			var a:Vector3D = new Vector3D(0,0,1);
			a = camera.localToGlobal(a);
			a = camera.projectGlobal(a);
			
			var b:Vector3D = new Vector3D(1,1,1);
			b = camera.localToGlobal(b);
			b = camera.projectGlobal(b);
			
			var scale0:Number = b.x - a.x;
			
			
			a = new Vector3D(0,0,2);
			a = camera.localToGlobal(a);
			a = camera.projectGlobal(a);
			
			b = new Vector3D(1,1,2);
			b = camera.localToGlobal(b);
			b = camera.projectGlobal(b);
			
			var scale1:Number = b.x - a.x;
			
			
			var r:Number =  2*(-(scale1-scale0));
			
			return r;
		}
		
		private function onContextCreate(e:Event):void {
			_stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			for each (var resource:Resource in this.getResources(true)) {
				resource.upload(_stage3D.context3D);
			}
			
			_container.addEventListener(Event.RESIZE,onResize);
			if(setupRendering)
				_container.addEventListener(Event.ENTER_FRAME,onRender);
			
			if(onInitEvent !=null)onInitEvent();
		}
		
		private function makeAxes():void {
			var axisX:WireFrame = WireFrame.createLinesList(Vector.<Vector3D>([new Vector3D(0, 0, 0), new Vector3D(300, 0, 0),  new Vector3D(300, 0, 0),  new Vector3D(280, 10, 0),  new Vector3D(300, 0, 0),  new Vector3D(280, -10, 0) ]), 0x0000ff, 2);
			var axisY:WireFrame = WireFrame.createLinesList(Vector.<Vector3D>([new Vector3D(0, 0, 0), new Vector3D(0, 300, 0), new Vector3D(0, 300, 0),new Vector3D(0, 280, 10),new Vector3D(0, 300, 0),new Vector3D(0, 280, -10)  ]), 0xff0000, 2);
			var axisZ:WireFrame = WireFrame.createLinesList(Vector.<Vector3D>([new Vector3D(0, 0, 0), new Vector3D(0, 0, 300), new Vector3D(0, 0, 300),new Vector3D(10, 0, 280),new Vector3D(0, 0, 300),new Vector3D(-10, 0, 280) ]), 0x00ff00, 2);
			axisX.z=axisY.z=axisZ.z=10;
			
			this.addChild(axisX);
			this.addChild(axisY);
			this.addChild(axisZ);
		}

		private function onResize(evt:Event):void{
			camera.view.width = _container.width;
			camera.view.height = _container.height;
			
			Zoom(this.scaleX);
			_zFactor = findZFactor();
		}
		
		private function onRender(event:Event):void{
			Render();
		}
		
		public function Zoom(value:Number):void{
			this.scaleX = this.scaleY = this.scaleZ = value;
			_zFactor = findZFactor();
		}
		
		public function projectGlobal(value:Vector3D):Vector3D{
			if(!camera.orthographic){
				return camera.projectGlobal(this.localToGlobal(value));
			}else{
				var d:Vector3D = camera.globalToLocal(this.localToGlobal(value));
				d.z = _zFactor;
				d = camera.projectGlobal(camera.localToGlobal(d));
				return d;
			}
		}
		/**
		 * 计算以鼠标点击的屏幕坐标为目标，从摄像机发出的射线 
		 * @param ray
		 * @param viewX
		 * @param viewY
		 * 
		 */		
		public function calculateMouseRay(ray:Ray3D,viewX:Number,viewY:Number):void
		{
			camera.calculateRay(ray.originPos,ray.direction,viewX,viewY);
		}
		
		private var tmp:Object3D;
		public function Render():void{
			if(_stage3D.visible)
			{
				controller.update();
				
				camera.render(_stage3D);

				for (tmp = childrenList; tmp != null; tmp = tmp.next)
				{
					if(tmp is IRenderAble)
						(tmp as IRenderAble).render(stage3D);
				}
				
				if(enterFrameCallBack!=null)
					enterFrameCallBack.call(null,stage3D);
			}
			
		}
		
	}
}