package main
{
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.rpc.events.FaultEvent;
	
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.resources.BitmapTextureResource;
	
	import bearas.geometrytool.GeometryData;
	import bearas.geometrytool.IGeometryVertex;
	
	import cloud.core.utils.Vector3DUtil;
	
	import interfaces.ICDecorationModule;
	
	import l3dbuild.geometry.L3DGeometryData;
	import l3dbuild.geometry.L3DLoadHelper;
	import l3dbuild.geometry.L3DVertex;
	import l3dbuild.geometry.ProcessHighResTexture;
	import l3dbuild.geometry.ProcessMatterProfileWithYAxis;
	import l3dbuild.geometry.ProcessPathExtrude;
	
	import model.vo.task.CTaskVO;
	import model.vo.task.ITaskVO;
	import dict.Object3DDict;
	
	/**
	 * 装修模块接口实现类
	 * @author cloud
	 */
	public class CDecorationModuleImp implements ICDecorationModule
	{
		private var _taskDic:Dictionary;
		private var _isRunning:Boolean;
		
		public function CDecorationModuleImp()
		{
		}
		/**
		 * 放样模型网格 
		 * @param source
		 * @param path
		 * @return GeometryData
		 * 
		 */		
		private function createLoftingMeshGeometry(source:L3DMesh,position:Vector3D,direction:Vector3D,path:Vector.<Vector3D>):GeometryData
		{
			var rotation:Number=Vector3DUtil.calculateRotationByAxis(direction,new Vector3D(0,-1,0),false);
			var go:L3DGeometryData = new L3DGeometryData();
			go.readFromMesh(source.getChildAt(0) as L3DMesh);
			
			var outline:L3DGeometryData = new L3DGeometryData();
			ProcessMatterProfileWithYAxis(outline,go);
			
			var size:Vector3D;
			size = outline.getBounds().size;
			//修正坐标
			outline.applyTranslation(new Vector3D(-size.x/2,0,0));
			//path[1]是起始位置
			outline.applyScale(new Vector3D(.1,.1,.1));
			//开始放样
			var finalgo:L3DGeometryData = new L3DGeometryData();
			ProcessPathExtrude(finalgo,outline,path,setUV);
			
			finalgo.lines.length = 0;
			finalgo.applyRotation(new Vector3D(0,0,rotation));
			finalgo.applyTranslation(position);
			
			ProcessHighResTexture(finalgo,4);
			return finalgo;
		}
		private function setUV(vertex:IGeometryVertex,pos:Vector3D,dir:Vector3D):void{
			var v:L3DVertex = vertex as  L3DVertex;
			var length:Number = pos.subtract(v.position).dotProduct(dir);
			v.texcord0.y += length/100;
			v.texcord1.y += length/100;
		}
	
		private function createWaistline(source:L3DMesh,textureResource:L3DBitmapTextureResource,position:Vector3D,direction:Vector3D,length:Number):Mesh
		{
			//修正位置
			position.z-=0.5;
			//创建放样模型网格信息
			var paths:Vector.<Vector3D>=new Vector.<Vector3D>();
			paths.push(new Vector3D(0,-length*.5*.1,0),new Vector3D(0,-length*.5*.1,0),new Vector3D(0,length*.5*.1,0),new Vector3D(0,length*.5*.1,0));
			var geo:L3DGeometryData=createLoftingMeshGeometry(source,position,direction,paths) as L3DGeometryData;
			//生成模型
			var mesh:Mesh=new Mesh();
			var material:Material=new TextureMaterial(new BitmapTextureResource(textureResource.data));
			geo.writeToMesh(mesh,material);
			mesh.userData=new RelatingParams();
			return mesh;
		}
		private function onLoadComplete(evt:Event):void
		{
			var loader:L3DLoadHelper=evt.target as L3DLoadHelper;
			var mesh:L3DMesh=loader.mesh;
			var textureResource:L3DBitmapTextureResource=loader.l3dBitmapTextureResource;
			if(mesh)
				doLoadMeshSuccess(mesh,loader);
			else if(textureResource)
				doCreateWaist(textureResource,loader);
		}
		private function doLoadMeshSuccess(mesh:L3DMesh,loader:L3DLoadHelper):void
		{
			var index:int=mesh.Code.indexOf("-");
			if(index>0)
			{
				var code:String=mesh.Code.slice(index+1);
				loader.loadType=L3DBitmapTextureResource;
				loader.LoadByCode(code);
			}
			(_taskDic[loader] as CTaskVO).mesh=mesh;
		}
		private function doCreateWaist(textureResource:L3DBitmapTextureResource,loader:L3DLoadHelper):void
		{
			loader.removeEventListener(Event.COMPLETE,onLoadComplete);
			var taskVo:CTaskVO=_taskDic[loader] as CTaskVO;
			switch(taskVo.type)
			{
				case Object3DDict.OBJECT3D_WAIST:
					var returnMesh:Mesh=createWaistline(taskVo.mesh,textureResource,taskVo.position,taskVo.direction,taskVo.length);
					if(taskVo.endCallback!=null)
						taskVo.endCallback.call(null,returnMesh);
					break;
			}
			loader.Dispose();
		}
		private function faultHandler(feObj:FaultEvent):void {
			//Alert.show(url + "加载失败");
		}
		private var _stage:Stage3D;

		public function addDecorationTask(taskVo:ITaskVO,stage3d:Stage3D):void
		{
			CONFIG::isDecoration
				{
					if(!_isRunning)
						start();
					if(taskVo is CTaskVO)
					{
						var loader:L3DLoadHelper=new L3DLoadHelper(stage3d);
						var vo:CTaskVO=taskVo as CTaskVO;
						_taskDic[loader]=taskVo;
						loader.addEventListener(Event.COMPLETE,onLoadComplete,false,0,true);
						loader.LoadByCode(taskVo.code);
					}
				}
		}
		public function get isRunning():Boolean
		{
			CONFIG::isDecoration
				{
					return _isRunning;
				}
			return false;
		}
		
		public function start():void
		{
			CONFIG::isDecoration
				{
					if(!_isRunning)
					{
						_isRunning=true;
						_taskDic=new Dictionary();
					}
				}
		}
		
		public function stop():void
		{
			CONFIG::isDecoration
				{
					if(_isRunning)
					{
						_isRunning=false;
						var taskVo:CTaskVO;
						for (var key:* in _taskDic)
						{
							taskVo=_taskDic[key] as CTaskVO;
							if(taskVo!=null)
								taskVo.clear();
							delete _taskDic[key];
						}
						_taskDic=null;
					}
				}
		}
		
		public function updateByFrame(startTime:Number=0,frameTime:Number=0):void
		{
			CONFIG::isDecoration
				{
					if(getTimer()-startTime<frameTime)
					{
						//TODO:
					}
				}
		}
	}
}