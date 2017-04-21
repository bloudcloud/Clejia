package wallDecorationModule.service
{
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	
	import bearas.geometrytool.GeometryData;
	import bearas.geometrytool.IGeometryVertex;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3DData;
	import cloud.core.interfaces.ICStatus;
	import cloud.core.utils.Geometry3DUtil;
	import cloud.core.utils.Vector3DUtil;
	
	import l3dbuild.geometry.L3DGeometryData;
	import l3dbuild.geometry.L3DVertex;
	import l3dbuild.geometry.ProcessHighResTexture;
	import l3dbuild.geometry.ProcessMatterProfileWithYAxis;
	import l3dbuild.geometry.ProcessPathExtrude;
	
	import main.dict.EventTypeDict;
	import main.dict.GlobalConstDict;
	import main.dict.Object3DDict;
	import main.model.ModelManager;
	import main.model.TaskDataModel;
	import main.model.WallDataModel;
	import main.model.vo.task.ITaskVO;
	
	import wallDecorationModule.model.vo.CDecorationTaskVO;

	/**
	 * 装修服务类
	 * @author cloud
	 */
	public class CDecorationService implements ICStatus
	{
		private var _taskDic:Dictionary;
		private var _taskModel:TaskDataModel;
		private var _isRunning:Boolean;
		
		public function CDecorationService()
		{
			//任务数据模型
			_taskModel=new TaskDataModel();
//			_taskModel.addEventListener(EventTypeDict.EVENT_LOADCOMPLETE,onExcuteTask);
			_taskModel.addEventListener(EventTypeDict.EVENT_LOADCOMPLETE,onExcuteTask2);
		}
		/**
		 * 任务数据未包含创建区域，执行此方法 
		 * @param evt
		 * 
		 */		 
		private function onExcuteTask(evt:Event):void
		{
			var rootMesh:Mesh=new Mesh();
			var paths:Array=new Array();
			var positions:Array=new Array();
			var taskVos:Vector.<ITaskVO>=_taskModel.curTaskVos;
			for each(var taskVo:CDecorationTaskVO in taskVos)
			{
				getWaistPathsAndPoses(taskVo,paths,positions);
				for(var i:int=0; i<positions.length; i++)
				{
					rootMesh.addChild(createOneWaistline(_taskModel.curMesh,_taskModel.curMaterial,positions[i],paths[i],Vector3DUtil.calculateRotationByAxis(taskVo.direction,new Vector3D(0,-1,0),false)));
				}
				if(taskVo.endCallback!=null)
					taskVo.endCallback.call(null,rootMesh);
			}
		}
		/**
		 * 任务数据包括了创建区域，执行此方法 
		 * 
		 */		
		private function onExcuteTask2(evt:Event):void
		{
			var rootMesh:Mesh=new Mesh();
			var paths:Vector.<Vector3D>;
			var startPosition:Vector3D;
			var taskVos:Vector.<ITaskVO>=_taskModel.curTaskVos;
			for each(var taskVo:CDecorationTaskVO in taskVos)
			{
				paths=new Vector.<Vector3D>();
				startPosition=new Vector3D();
				calculatePathAndPosition(taskVo.regionRoundPoints,startPosition,paths);
				rootMesh.addChild(createOneWaistline(_taskModel.curMesh,_taskModel.curMaterial,startPosition,paths,Vector3DUtil.calculateRotationByAxis(Vector3D.X_AXIS,new Vector3D(0,-1,0),false)));
				if(taskVo.endCallback!=null)
					taskVo.endCallback.call(null,rootMesh);
			}
		}
		private function calculatePathAndPosition(regionRoundPoints:Array,oPosition:Vector3D,oPath:Vector.<Vector3D>):void
		{
			var maxX:Number=int.MIN_VALUE,minX:Number=int.MAX_VALUE,maxY:Number=int.MIN_VALUE,minY:Number=int.MAX_VALUE;
			for each(var point:Point in regionRoundPoints)
			{
				if(maxX<point.x) maxX=point.x;
				if(minX>point.x) minX=point.x;
				if(maxY<point.y) maxY=point.y;
				if(minY>point.y) minY=point.y;
			}
			var length:Number=maxX-minX;
			var height:Number=maxY-minY;
			oPosition.setTo((minX+maxX)*.5,0,minY);
			oPath.push(new Vector3D(0,-length*.5,0),new Vector3D(0,-length*.5,0),new Vector3D(0,length*.5,0),new Vector3D(0,length*.5,0));
		}
		/**
		 * 放样模型网格 
		 * @param source
		 * @param path
		 * @return GeometryData
		 * 
		 */		
		private function createLoftingMeshGeometry(source:L3DMesh,position:Vector3D,path:Vector.<Vector3D>,rotation:Number):GeometryData
		{
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
			for each(var vertice:IGeometryVertex in finalgo.vertices)
			{
				vertice.position=Geometry3DUtil.transformVector(vertice.position,position.x,position.y,position.z,rotation,false);
			}
			
			ProcessHighResTexture(finalgo,4);
			return finalgo;
		}
		private function setUV(vertex:IGeometryVertex,pos:Vector3D,dir:Vector3D):void{
			var v:L3DVertex = vertex as  L3DVertex;
			var length:Number = pos.subtract(v.position).dotProduct(dir);
			v.texcord0.y += length/(100*GlobalConstDict.SCENE3D_SCALERATIO);
			v.texcord1.y += length/(100*GlobalConstDict.SCENE3D_SCALERATIO);
		}
		
		private function createOneWaistline(sourceMesh:L3DMesh,sourceMaterial:Material,position:Vector3D,path:Vector.<Vector3D>,rotation:Number):Mesh
		{
			//创建放样模型网格信息
			var geo:L3DGeometryData;
			var subMesh:Mesh;
			//修正位置
			geo=createLoftingMeshGeometry(sourceMesh,position,path,rotation) as L3DGeometryData;
			//创建模型
			subMesh=new Mesh();
			geo.writeToMesh(subMesh,sourceMaterial);
			subMesh.userData=new RelatingParams();
			return subMesh;
		}
		
		private function getWaistPathsAndPoses(taskVo:CDecorationTaskVO,outputPaths:Array,outputPoses:Array):void
		{
			var wallID:String=taskVo.parentID;
			var wallModel:WallDataModel=ModelManager.instance.getModel(Object3DDict.OBJECT3D_WALL) as WallDataModel;
			var furnitures:Vector.<ICData>=wallModel.getFurnituresByWallID(wallID);
			//计算腰线起始位置
			var halfDis:Number=taskVo.length*GlobalConstDict.SCENE3D_SCALERATIO*.5;
			//生成腰线的生成路径
			var pathArr:Array=new Array();
			pathArr.push(-halfDis,halfDis);
			if(furnitures)
			{
				for each(var furniture:ICObject3DData in furnitures)
				{
					if(furniture.type==taskVo.type) continue;
					calculatWasitIntersection(taskVo,furniture,pathArr);
				}
				pathArr.sort(Array.NUMERIC);
			}
			//填充返回数据
			var paths:Vector.<Vector3D>;
			var outputPosition:Vector3D;
			for(var i:int=0; i<pathArr.length; i+=2)
			{
				paths=new Vector.<Vector3D>();
				halfDis=(pathArr[i+1]-pathArr[i])*.5;
				paths.push(new Vector3D(0,-halfDis,0),new Vector3D(0,-halfDis,0),new Vector3D(0,halfDis,0),new Vector3D(0,halfDis,0));
				outputPaths.push(paths);
				outputPosition=Geometry3DUtil.transformVectorByTransform3D(new Vector3D((pathArr[i]+pathArr[i+1])*.5/GlobalConstDict.SCENE3D_SCALERATIO,0,0),taskVo.transform,true);
				outputPosition.scaleBy(GlobalConstDict.SCENE3D_SCALERATIO);
				outputPoses.push(outputPosition);
			}
		}
		/**
		 * 计算腰线与家具的交点 
		 * @param wasitVo	腰线数据
		 * @param furnitureVo	家具数据
		 * @param paths	如果相交，存储交点有效坐标
		 * 
		 */		
		private function calculatWasitIntersection(wasitVo:ICObject3DData,furnitureVo:ICObject3DData,paths:Array):void
		{
			var position:Vector3D=Geometry3DUtil.transformVectorByTransform3D(wasitVo.position,furnitureVo.inverseTransform,false);
			if(Math.abs(position.z)<(furnitureVo.height*.5+GlobalConstDict.DOOR3D_OFFSET))
			{
				//相交,设置交点坐标
				var x1:Number=-furnitureVo.length*.5*furnitureVo.transform.a+position.y*furnitureVo.transform.b+position.z*furnitureVo.transform.c+furnitureVo.transform.d;
				var x2:Number=furnitureVo.length*.5*furnitureVo.transform.a+position.y*furnitureVo.transform.b+position.z*furnitureVo.transform.c+furnitureVo.transform.d;
				//转换到腰线本地坐标系内
				x1=x1*wasitVo.inverseTransform.a+wasitVo.y*wasitVo.inverseTransform.b+wasitVo.z*wasitVo.inverseTransform.c+wasitVo.inverseTransform.d;
				x2=x2*wasitVo.inverseTransform.a+wasitVo.y*wasitVo.inverseTransform.b+wasitVo.z*wasitVo.inverseTransform.c+wasitVo.inverseTransform.d;
				paths.push(x1*GlobalConstDict.SCENE3D_SCALERATIO+GlobalConstDict.DOOR3D_OFFSET*GlobalConstDict.SCENE3D_SCALERATIO,x2*GlobalConstDict.SCENE3D_SCALERATIO);
			}
		}
		/**
		 * 创建3D对象数据 
		 * @param uniqueID
		 * @param type
		 * @param parentID
		 * @param length
		 * @param width
		 * @param height
		 * @param x
		 * @param y
		 * @param z
		 * @param rotation
		 * 
		 */		
		public function addObject3DData(uniqueID:String,type:uint,parentID:String,length:Number,width:Number,height:Number,x:Number,y:Number,z:Number,rotation:Number):void
		{
			_taskModel.addCacheData(ModelManager.instance.createObject3DData(uniqueID,type,parentID,length,width,height,x,y,z,rotation));
		}
		/**
		 * 添加装修任务 
		 * @param taskVo
		 * @param stage3d
		 * 
		 */		
		public function addDecorationTask(taskVo:CDecorationTaskVO,stage3d:Stage3D):void
		{
			_taskModel.addTask(taskVo,stage3d);
		}
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		public function start():void
		{
			_isRunning=true;
			_taskDic=new Dictionary();
		}
		public function stop():void
		{
			_isRunning=false;
			var taskVo:CDecorationTaskVO;
			for (var key:* in _taskDic)
			{
				taskVo=_taskDic[key] as CDecorationTaskVO;
				if(taskVo!=null)
					taskVo.clear();
				delete _taskDic[key];
			}
			_taskDic=null;
		}
		public function updateByFrame(startTime:Number=0,frameTime:Number=0):void
		{
			if(getTimer()-startTime<frameTime)
			{
				//TODO:
			}
		}
	}
}