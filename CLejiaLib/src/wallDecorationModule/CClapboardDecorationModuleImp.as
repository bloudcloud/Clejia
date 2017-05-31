package wallDecorationModule
{
	import flash.display.Stage3D;
	import flash.geom.Point;
	
	import alternativa.engine3d.objects.Mesh;
	
	import main.extension.CTextureMaterial;
	import main.model.ModelManager;
	import main.model.vo.CWallVO;
	
	import wallDecorationModule.interfaces.ICClapboardDecorationModule;
	import wallDecorationModule.service.CClapboardDecorationService;
	
	/**
	 *  护墙板装修模块实现类
	 * @author cloud
	 */
	public class CClapboardDecorationModuleImp implements ICClapboardDecorationModule
	{
		private var _clapboardService:CClapboardDecorationService;
		
		private var _isRunning:Boolean;
		
		public var taskCompleteCallback:Function;
		
		public function CClapboardDecorationModuleImp()
		{
			_clapboardService=new CClapboardDecorationService();
		}

		public function get curLength():Number
		{
			return _clapboardService.curLength;
		}
		public function get curHeight():Number
		{
			return _clapboardService.curHeight;
		}
		public function get curFloorHeight():Number
		{
			return _clapboardService.curFloorHeight;
		}
//		public function get curSpacing():Number
//		{
//			return _clapboardService.curSpacing;
//		}	
		public function get selectMesh():Mesh
		{
			return _clapboardService.selectMesh;
		}
		public function getXmlCaches():Array
		{
			return _clapboardService.xmlCaches;
		}
		public function setXmlPlanDatas(datas:Array):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.setXmlPlanDatas(datas);
				}
		}
		public function setUnitPlan(xml:XML):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.deserialize(xml);
				}
		}
		public function setRenderPlanData(roomIndex:int=-1):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.setRenderPlanData(roomIndex);
				}
		}
		
		public function getWallData(pointA:Point,pointB:Point):CWallVO
		{
			CONFIG::isClapboardDecoration
				{
					return _clapboardService.getWallData(pointA,pointB);
				}
		}
		public function createAndSetObject3DVO(type:uint,uniqueID:String,parentID:String,length:Number,width:Number,height:Number,x:Number,y:Number,z:Number,rotation:Number):void
		{
			CONFIG::isClapboardDecoration
				{
					ModelManager.instance.createObject3DData(type,uniqueID,parentID,length,width,height,x,y,z,rotation);
				}
		}
		public function setRenderCallback(renderCallback:Function):void
		{
			_clapboardService.renderViewCallback=renderCallback;
		}
		public function usePlanDatas():Boolean
		{
			CONFIG::isClapboardDecoration
				{
					return _clapboardService.excuteStartDecoration();
				}
				return false;
		}
		public function initDecorationModule(stage3d:Stage3D):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.initDecoration(stage3d);
				}
		}
		public function excuteTask():Boolean
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.excuteTask();
				}
			return false;
		}
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		public function start():void
		{
			CONFIG::isClapboardDecoration
				{
					if(!_isRunning)
					{
						_isRunning=true;
						_clapboardService.start();
					}
				}
		}
		
		public function stop():void
		{
			CONFIG::isClapboardDecoration
				{
					if(_isRunning)
					{
						_isRunning=false;
						_clapboardService.stop();
					}
				}
		}
		public function clearData():void
		{
			_clapboardService.clearData();
		}
		public function updateByFrame(startTime:Number=0, frameTime:Number=0):void
		{
			CONFIG::isDecoration
				{
					if(_clapboardService.isRunning)
						_clapboardService.updateByFrame(startTime,frameTime);
				}
		}
		
		public function addObject3DData(uniqueID:String, type:uint, parentID:String, length:Number, width:Number, height:Number, x:Number, y:Number, z:Number, rotation:Number):void
		{
//			CONFIG::isDecoration
//				{
//					
//				}
		}
		/**
		 * 执行更换纹理操作 
		 * @param bitmapData
		 * 
		 */		
		public function excuteChangeMaterial(material:CTextureMaterial):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.excuteChangeMaterial(material);
				}
				
		}
		/**
		 * 执行更换模型样式操作 
		 * @param mesh
		 * 
		 */		
		public function excuteChangeMesh(mesh:L3DMesh):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.excuteChangeMesh(mesh);
				}
		}
		/**
		 * 执行更新护墙板显示操作 
		 * 
		 */		
		public function updateClapboardView(length:Number,height:Number,floorHeight:Number,spacing:Number=0):Boolean
		{
			CONFIG::isClapboardDecoration
				{
					return _clapboardService.updateClapboardView(length,height,floorHeight,spacing);
				}
				
		}
		public function excuteMouseDown(mesh:Mesh):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.excuteMouseDown(mesh as L3DMesh);
				}
		}
		public function excuteMouseUp(mesh:Mesh):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.excuteMouseUp(mesh as L3DMesh);
				}
		}
		public function clearAll():void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.clearAll();
				}
		}
		public function addEventListener(type:String,func:Function):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.addEventListener(type,func);
				}
		}
		public function removeEventListener(type:String,func:Function):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.removeEventListener(type,func);
				}
		}
		
		public function removeDecorationMesh(mesh:L3DMesh):void
		{
			CONFIG::isClapboardDecoration
				{
					_clapboardService.removeDecorationMeshData(mesh);
				}
		}
	}
}