package wallDecorationModule.service
{
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICStatus;
	import cloud.core.singleton.CVector3DUtil;
	import cloud.core.utils.Geometry3DUtil;
	
	import main.dict.EventTypeDict;
	import main.dict.GlobalConstDict;
	import main.dict.Object3DDict;
	import main.model.ModelManager;
	import main.model.TaskDataModel;
	import main.model.WallDataModel;
	import main.model.vo.CObject3DVO;
	import main.model.vo.task.ITaskVO;
	
	import utils.CDecorationMeshUtil;
	
	import wallDecorationModule.model.vo.CDecorationTaskVO;
	
	/**
	 * 装修服务类
	 * @author cloud
	 */
	public class CWaistDecorationService implements ICStatus
	{
		private var _taskModel:TaskDataModel;
		private var _isRunning:Boolean;
		
		public function CWaistDecorationService()
		{
			//任务数据模型
			_taskModel=new TaskDataModel();
			_taskModel.loadMode="-";
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
//			var rootMesh:Mesh=new Mesh();
//			var paths:Array=new Array();
//			var positions:Array=new Array();
//			var taskVos:Vector.<ITaskVO>=_taskModel.curTaskVos;
//			var rotation:Number;
//			for each(var taskVo:CDecorationTaskVO in taskVos)
//			{
//				getWaistPathsAndPoses(taskVo,paths,positions);
//				for(var i:int=0; i<positions.length; i++)
//				{
//					rotation=Vector3DUtil.calculateRotationByAxis(taskVo.direction,new Vector3D(0,-1,0),false);
//					rootMesh.addChild(CDecorationMeshUtil.createLoftingLineByPaths(_taskModel.curMesh,_taskModel.curMaterial,paths[i],positions[i],rotation));
//				}
//				if(taskVo.endCallback!=null)
//					taskVo.endCallback.call(null,rootMesh);
//			}
		}
		/**
		 * 任务数据包括了创建区域，执行此方法 
		 * 
		 */		
		private function onExcuteTask2(evt:Event):void
		{
			var paths:Vector.<Vector3D>;
			var rotation:Number;
			var taskVos:Vector.<ITaskVO>=_taskModel.curTaskVos;
			var rootMesh:Mesh=new Mesh();
			var direction:Vector3D;
			var toward:Vector3D;
			var startPos:Vector3D;
			var endPos:Vector3D;
			for each(var taskVo:CDecorationTaskVO in taskVos)
			{
				direction=taskVo.direction.clone();
				direction.normalize();
				direction.scaleBy(taskVo.length*.5);
				endPos=taskVo.position.add(direction);
				startPos=taskVo.position.subtract(direction);
				paths=new Vector.<Vector3D>();
				paths.push(startPos.clone(),startPos.clone(),endPos.clone(),endPos.clone());
				direction.normalize();
				
				toward=direction.crossProduct(CVector3DUtil.Z_AXIS);
				taskVo.rotation=CVector3DUtil.instance.calculateRotationByAxis(taskVo.direction,CVector3DUtil.X_AXIS);
				subMesh=CDecorationMeshUtil.instance.createLoftingLineByPaths(_taskModel.curMesh,_taskModel.curMaterial,paths,toward);
				rootMesh.addChild(subMesh);
			}
			
			var l3dModel:L3DModel=new L3DModel();
			l3dModel.Import(rootMesh,false,true);
			var l3dMesh:L3DMesh=l3dModel.Export(_taskModel.stage3d);
			l3dModel.Clear();
			var subMesh:Object3D;
			var l3dBitmapTextureResource:L3DBitmapTextureResource;
			for(var i:int=0 ;i<l3dMesh.numChildren; i++)
			{
				subMesh=l3dMesh.getChildAt(i);
				if(subMesh is L3DMesh)
				{
					l3dBitmapTextureResource=((subMesh as Mesh).getSurface(0).material as TextureMaterial).diffuseMap as L3DBitmapTextureResource;
					l3dBitmapTextureResource.Url=((_taskModel.curMaterial as TextureMaterial).diffuseMap as L3DBitmapTextureResource).Url;
				}
			}
			l3dMesh.catalog=_taskModel.curMesh.catalog;
			l3dMesh.family=_taskModel.curMesh.family;
			l3dMesh.Code=_taskModel.curMesh.Code;
			l3dMesh.ERPCode=_taskModel.curMesh.ERPCode;
			l3dMesh.Mode=_taskModel.curMesh.catalog;
			l3dMesh.isPolyMode=_taskModel.curMesh.isPolyMode;
			if(taskVo.endCallback!=null)
				taskVo.endCallback.call(null,l3dMesh);
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
				for each(var furniture:CObject3DVO in furnitures)
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
				outputPosition=Geometry3DUtil.instance.transformVectorByCTransform3D(new Vector3D((pathArr[i]+pathArr[i+1])*.5/GlobalConstDict.SCENE3D_SCALERATIO,0,0),taskVo.transform,true);
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
		private function calculatWasitIntersection(wasitVo:CObject3DVO,furnitureVo:CObject3DVO,paths:Array):void
		{
			var position:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(wasitVo.position,furnitureVo.inverseTransform,false);
			if(Math.abs(position.z)<(furnitureVo.height))
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
			_taskModel.addCacheData(ModelManager.instance.createObject3DData(type,uniqueID,parentID,length,width,height,x,y,z,rotation));
		}
		/**
		 * 添加装修任务 
		 * @param taskVo
		 * @param stage3d
		 * 
		 */		
		public function addDecorationTask(taskVo:CDecorationTaskVO):void
		{
			if(taskVo.code.length>0)
				_taskModel.addTask(taskVo);
		}
		
		public function excuteTaskLoad():Boolean
		{
			_taskModel.startLoad();
			return !_taskModel.isLoadEnd;
		}
		public function initDecoration(stage3d:Stage3D):void
		{
			_taskModel.initLoader(stage3d);
		}
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		public function start():void
		{
			_isRunning=true;
		}
		public function stop():void
		{
			_isRunning=false;
			_taskModel.clearCache();
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