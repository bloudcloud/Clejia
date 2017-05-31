package wallDecorationModule.service
{
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;
	
	import mx.utils.UIDUtil;
	
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	
	import bearas.math.linear.vnormal;
	
	import cloud.core.dataStruct.CTransform3D;
	import cloud.core.dataStruct.CVector3D;
	import cloud.core.dataStruct.container.Vector3DContainer;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.interfaces.ICStatus;
	import cloud.core.singleton.CPoolsManager;
	import cloud.core.singleton.CUtil;
	import cloud.core.singleton.CVector3DUtil;
	import cloud.core.utils.CDebug;
	import cloud.core.utils.Geometry3DUtil;
	
	import l3dbuild.geometry.L3DBuildableMesh;
	
	import main.dict.EventTypeDict;
	import main.dict.GlobalConstDict;
	import main.dict.Object3DDict;
	import main.extension.CTextureMaterial;
	import main.model.ModelManager;
	import main.model.TaskDataModel;
	import main.model.vo.CWallVO;
	import main.model.vo.task.CParam3DTaskVO;
	import main.model.vo.task.CParamRectangle3DTaskVO;
	import main.model.vo.task.CUnit3DTaskVO;
	import main.model.vo.task.ITaskVO;
	
	import utils.CDataUtil;
	import utils.CDecorationMeshUtil;
	
	import wallDecorationModule.dict.CDecorationParamDict;
	import wallDecorationModule.model.vo.CClapboardLineVO;
	import wallDecorationModule.model.vo.CClapboardRectangleVO;
	import wallDecorationModule.model.vo.CClapboardRegionPlanData;
	import wallDecorationModule.model.vo.CClapboardUnitVO;
	import wallDecorationModule.model.vo.CRegionVO;
	
	/**
	 * 护墙板装修服务类
	 * @author cloud
	 */
	public class CClapboardDecorationService implements ICStatus
	{
		private var _invalidClapboard:Boolean;
		private var _isRendering:Boolean;
		private var _isRunning:Boolean;
		private var _wallVo:CWallVO;
		private var _regionVo:CRegionVO;
		private var _taskModel:TaskDataModel;
		private var _allXMLPlanDatas:Array;
		private var _planDatas:Vector.<CClapboardRegionPlanData>;
		private var _sourcePlanData:CClapboardRegionPlanData;
		private var _l3dModel:L3DModel;
		private var _regions:Vector.<CRegionVO>;
		private var _sourceXml:XML;
		private var _selectMesh:L3DMesh;
		private var _isNeedReRender:Boolean;
		private var _currentRoomIndex:int;
		
		private var _curLength:Number;
		private var _curHeight:Number;
		/**
		 * 当前对象的中心点离地高 
		 */		
		private var _curFloorHight:Number;
		/**
		 * 当前对象的左右间距 
		 */		
		private var _curSpacing:Number;
				
		public var renderViewCallback:Function;
		
		public function get xmlCaches():Array
		{
			return _allXMLPlanDatas;
		}
		public function get selectMesh():Mesh
		{
			return _selectMesh;
		}
		
		public function get curLength():Number
		{
			return _curLength;
		}
		public function set curLength(value:Number):void
		{
			if(_curLength!=value)
			{
				_invalidClapboard=true;
				_curLength=value;
			}
		}
		
		public function get curHeight():Number
		{
			return _curHeight;
		}
		public function set curHeight(value:Number):void
		{
			if(_curHeight!=value)
			{
				_invalidClapboard=true;
				_curHeight=value;
			}
		}
		
		public function get curFloorHeight():Number
		{
			return _curFloorHight;
		}
		public function set curFloorHeight(value:Number):void
		{
			if(_curFloorHight!=value)
			{
				_invalidClapboard=true;
				_curFloorHight=value;
			}
		}

		public function CClapboardDecorationService()
		{
			CPoolsManager.instance.registPool(Vector3DContainer,CVector3D);
			CPoolsManager.instance.registPool(CUnit3DTaskVO);
			CPoolsManager.instance.registPool(CParam3DTaskVO);
			
			_l3dModel=new L3DModel();
			_regions=new Vector.<CRegionVO>();
			_planDatas=new Vector.<CClapboardRegionPlanData>();
			_sourcePlanData=new CClapboardRegionPlanData();
			_taskModel=new TaskDataModel();
			_taskModel.addEventListener(EventTypeDict.EVENT_LOADCOMPLETE,onExcuteTaskComplete);
			registerClassAlias("CClapboardUnitVO",CClapboardUnitVO);
			registerClassAlias("CClapboardLineVO",CClapboardLineVO);
			registerClassAlias("CClapboardRectangleVO",CClapboardRectangleVO);
		}
		private function onExcuteTaskComplete(evt:Event):void
		{
			var rootMesh:Mesh;
			var subMeshVos:Vector.<ITaskVO>;
			var l3dMesh:L3DMesh;
			var tasks:Vector.<ITaskVO>=_taskModel.curTaskVos;
			var groups:Array=new Array();
			var subMesh:Object3D;
			var l3dBitmapTextureResource:L3DBitmapTextureResource;
			var i:int;
			var rootMeshName:String;
			var object3dVo:ICObject3D;
			var needNewGroup:Boolean;
			//根据任务数据集合，创建装修模型组
			for each(var taskVo:ITaskVO in tasks)
			{
				object3dVo=taskVo as ICObject3D;
				rootMeshName=taskVo.type+"_"+object3dVo.z.toFixed(0)+"_"+object3dVo.length.toFixed(0)+"_"+object3dVo.height.toFixed();
				needNewGroup=true;
				for(i=0; i<groups.length; i+=2)
				{
					if(groups[i].name==rootMeshName)
					{
						rootMesh=groups[i];
						subMeshVos=groups[i+1];
						needNewGroup=false;
						break;
					}
				}
				if(needNewGroup)
				{
					rootMesh=new Mesh();
					rootMesh.name=rootMeshName;
					subMeshVos=new Vector.<ITaskVO>();
					groups.push(rootMesh,subMeshVos);
				}
				doCreateDecorationMesh(taskVo,_taskModel.curMesh,_taskModel.curMaterial,rootMesh,subMeshVos);
			}
			//打包装修模型组，并提交渲染
			for(i=0; i<groups.length; i+=2)
			{
				rootMesh=groups[i];
				subMeshVos=groups[i+1];
				_l3dModel.Import(rootMesh);
				l3dMesh=_l3dModel.Export(_taskModel.stage3d);
				for(var j:int=0 ;j<l3dMesh.numChildren; j++)
				{
					subMesh=l3dMesh.getChildAt(j);
					if(subMesh is L3DMesh)
					{
						if(_taskModel.curMesh)
						{
							(subMesh as L3DMesh).catalog=22;
							(subMesh as L3DMesh).Mode=22;
						}
						l3dBitmapTextureResource=((subMesh as Mesh).getSurface(0).material as TextureMaterial).diffuseMap as L3DBitmapTextureResource;
						l3dBitmapTextureResource.Url=((_taskModel.curMaterial as TextureMaterial).diffuseMap as L3DBitmapTextureResource).Url;
					}
				}
				l3dMesh.name=_taskModel.curType.toString();
				if(subMeshVos[0] is CParam3DTaskVO)
				{
					l3dMesh.OffGround=(subMeshVos[0] as CParam3DTaskVO).offGround;
				}
				l3dMesh.userData2=subMeshVos;
				l3dMesh.userData3=_taskModel.curMesh;
				l3dMesh.userData4=_taskModel.curMaterial;
				l3dMesh.userData5=_taskModel.curCode;
				l3dMesh.userData6=_taskModel.curType;
				if(_taskModel.curMesh)
				{
					l3dMesh.catalog=_taskModel.curMesh.catalog;
					l3dMesh.family=_taskModel.curMesh.family;
					l3dMesh.Code=_taskModel.curMesh.Code;
					l3dMesh.ERPCode=_taskModel.curMesh.ERPCode;
					l3dMesh.Mode=_taskModel.curMesh.catalog;
					l3dMesh.isPolyMode=_taskModel.curMesh.isPolyMode;
				}
				else
				{
					l3dMesh.catalog=22;
					l3dMesh.Mode=22;
				}
				groups[i]=null;
				groups[i+1]=null;
				if(renderViewCallback!=null)
					renderViewCallback.call(null,l3dMesh);
			}
			groups.length=0;
		}
		/**
		 * 创建装修模型 
		 * @param taskVo	任务数据对象
		 * @param sourceMesh	源模型样式
		 * @param sourceMaterial	源模型材质
		 * @param groups	模型组
		 * 
		 */		
		private function doCreateDecorationMesh(taskVo:ITaskVO,sourceMesh:L3DMesh,sourceMaterial:CTextureMaterial,rootMesh:Mesh,subMeshVos:Vector.<ITaskVO>=null):void
		{
			var paths:Vector.<Vector3D>;
			var unitVo:CUnit3DTaskVO;
			var paramVo:CParam3DTaskVO;
			var rectangleVo:CParamRectangle3DTaskVO;
			var position:Vector3D;
			var endPosition:Vector3D;
			var startPosition:Vector3D;
			var dir:Vector3D;
			var toward:Vector3D;
			var realLength:Number;
			var realHeight:Number;
			var type:uint;
			var normal:Vector3D;
			var subMesh:Mesh;
			var rootMesh:Mesh;
			var key:String;
			type=CDecorationParamDict.instance.getParamType(taskVo.type);
			switch(type)
			{
				case CDecorationParamDict.PARAM_UNIT_ONE:
				case CDecorationParamDict.PARAM_UNIT_TWO:
				case CDecorationParamDict.PARAM_UNIT_THREE:
				case CDecorationParamDict.PARAM_UNIT_FOUR:
				case CDecorationParamDict.PARAM_UNIT_FIVE:
				case CDecorationParamDict.PARAM_UNIT_NORMAL:
					unitVo=taskVo as CUnit3DTaskVO;
					if(subMeshVos) subMeshVos.push(unitVo);
					normal=unitVo.direction.crossProduct(CVector3DUtil.Z_AXIS);
					normal.normalize();
					normal.scaleBy(unitVo.width+1);
					position=unitVo.position.add(normal);
					realLength=unitVo.realLength;
					realHeight=unitVo.realHeight;
					unitVo.width=CDecorationParamDict.DEFAULT_UINT_BOARD_THICKNESS;
					unitVo.qLength=unitVo.realLength;
					unitVo.qWidth=unitVo.width;
					unitVo.qHeight=unitVo.realHeight;
					CDecorationMeshUtil.instance.createBoardMeshBySize(unitVo.name,sourceMaterial,realLength,unitVo.width,realHeight,position,unitVo.direction,unitVo.rotation,rootMesh,false);
					break;
				case CDecorationParamDict.PARAM_RECTANGLE_BOARD:
				case CDecorationParamDict.PARAM_RECTANGLE_NOBOARD:
				case CDecorationParamDict.PARAM_RECTANGLE_CORNER:
					//创建区域面板
					rectangleVo=taskVo as CParamRectangle3DTaskVO;
					if(subMeshVos) subMeshVos.push(rectangleVo);
					normal=rectangleVo.direction.crossProduct(CVector3DUtil.Z_AXIS);
					normal.normalize();
					normal.scaleBy(rectangleVo.thicknessOffset*2+rectangleVo.width+1);
					position=rectangleVo.position.add(normal);
					realLength=rectangleVo.realLength-rectangleVo.lineLength*2;
					realHeight=rectangleVo.height-rectangleVo.lineWidth* 2;
					rectangleVo.width=CDecorationParamDict.DEFAULT_UINT_BOARD_THICKNESS;
					rectangleVo.qLength=realLength;
					rectangleVo.qWidth=rectangleVo.width;
					rectangleVo.qHeight=realHeight;
					CDecorationMeshUtil.instance.createBoardMeshBySize(rectangleVo.name,sourceMaterial,realLength,2,realHeight,position,rectangleVo.direction,rectangleVo.rotation,rootMesh,false);
					subMesh=rootMesh.getChildAt(rootMesh.numChildren-1) as Mesh;
					break;
				case CDecorationParamDict.PARAM_LINE_TOP:
				case CDecorationParamDict.PARAM_LINE_BOTTOM:
				case CDecorationParamDict.PARAM_LINE_WAIST:
					//创建整线
					paramVo=taskVo as CParam3DTaskVO;
					if(subMeshVos) subMeshVos.push(paramVo);
					if(sourceMesh!=null && sourceMesh.Width!=0)
						paramVo.width=sourceMesh.Width;
					paths=new Vector.<Vector3D>();
					dir=paramVo.direction.clone();
					dir.normalize();
					dir.scaleBy(paramVo.realLength*.5);
					normal=dir.crossProduct(CVector3DUtil.Z_AXIS);
					normal.normalize();
					normal.scaleBy(paramVo.thicknessOffset+paramVo.width*.5+2);
					endPosition=paramVo.position.add(dir).add(normal);
//					endPosition.z-=paramVo.height*.5;
					startPosition=paramVo.position.subtract(dir).add(normal);
//					startPosition.z-=paramVo.height*.5;
					paths.push(startPosition.clone(),startPosition.clone(),endPosition.clone(),endPosition.clone());
					toward=vnormal(dir.crossProduct(CVector3DUtil.Z_AXIS));
					paramVo.rotation=CVector3DUtil.instance.calculateRotationByAxis(paramVo.direction,CVector3DUtil.X_AXIS);
					paramVo.qLength=paramVo.realLength;
					subMesh=CDecorationMeshUtil.instance.createLoftingLineByPaths(sourceMesh,sourceMaterial,paths,toward);
					subMesh.name=paramVo.name;
					rootMesh.addChild(subMesh);
					break;
				case CDecorationParamDict.PARAM_PANEL_LINE:
					//创建面板线
					paramVo=taskVo as CParam3DTaskVO;
					if(subMeshVos) subMeshVos.push(paramVo);
					if(sourceMesh!=null && sourceMesh.Width!=0)
						paramVo.width=sourceMesh.Width;
					paths=new Vector.<Vector3D>();
					dir=paramVo.direction.clone();
					dir.normalize();
					dir.scaleBy(paramVo.realLength*.5);
					normal=dir.crossProduct(CVector3DUtil.Z_AXIS);
					normal.normalize();
					normal.scaleBy(paramVo.thicknessOffset+paramVo.width*.5+2);
					endPosition=paramVo.position.add(dir).add(normal);
					endPosition.z-=paramVo.height*.5;
					startPosition=paramVo.position.subtract(dir).add(normal);
					startPosition.z-=paramVo.height*.5;
					paths.push(endPosition.clone(),new Vector3D(endPosition.x,endPosition.y,endPosition.z+paramVo.height),new Vector3D(startPosition.x,startPosition.y,startPosition.z+paramVo.height),startPosition.clone(),endPosition.clone(),new Vector3D(endPosition.x,endPosition.y,endPosition.z+paramVo.height),new Vector3D(startPosition.x,startPosition.y,startPosition.z+paramVo.height));
					paramVo.rotation=CVector3DUtil.instance.calculateRotationByAxis(paramVo.direction,CVector3DUtil.X_AXIS);
					toward=vnormal(dir.crossProduct(CVector3DUtil.Z_AXIS));
					paramVo.qLength=paramVo.realLength*2+paramVo.realHeight*2;
					subMesh=CDecorationMeshUtil.instance.createLoftingLineByPaths(sourceMesh,sourceMaterial,paths,toward);
					subMesh.name=paramVo.name;
					rootMesh.addChild(subMesh);
					break;
				case CDecorationParamDict.PARAM_PANEL_CORNER:
					//创建面板拐角
					paramVo=taskVo as CParam3DTaskVO;
					if(subMeshVos) subMeshVos.push(paramVo);
					position=paramVo.position;
					if(sourceMesh!=null && sourceMesh.Width!=0)
						paramVo.width=sourceMesh.Width;
					normal=paramVo.direction.crossProduct(CVector3DUtil.Z_AXIS);
					normal.normalize();
					normal.scaleBy(paramVo.width*.5);
					position.incrementBy(normal);
					paramVo.qLength*=4;
					paramVo.qWidth=paramVo.width;
					paramVo.qHeight*=4;
					//第一个角
					dir=paramVo.direction.clone();
					dir.normalize();
					dir.scaleBy(paramVo.realLength*.5);
					subMesh=createCornerMesh(sourceMesh,sourceMaterial,position.x-dir.x,position.y-dir.y,position.z-dir.z+paramVo.height*.5,0,paramVo.rotation);
					subMesh.name=paramVo.name;
					rootMesh.addChild(subMesh);
					//第二个角
					subMesh=createCornerMesh(sourceMesh,sourceMaterial,position.x+dir.x,position.y+dir.y,position.z+dir.z+paramVo.height*.5,90,paramVo.rotation);
					subMesh.name=paramVo.name;
					rootMesh.addChild(subMesh);
					//第三个角
					subMesh=createCornerMesh(sourceMesh,sourceMaterial,position.x+dir.x,position.y+dir.y,position.z+dir.z-paramVo.height*.5,180,paramVo.rotation);
					subMesh.name=paramVo.name;
					rootMesh.addChild(subMesh);
					//第四个角
					subMesh=createCornerMesh(sourceMesh,sourceMaterial,position.x-dir.x,position.y-dir.y,position.z-dir.z-paramVo.height*.5,-90,paramVo.rotation);
					subMesh.name=paramVo.name;
					rootMesh.addChild(subMesh);
					break;
				default:
					CDebug.instance.throwError("CClapboardDecorationService","onExcuteTaskComplete","type",String(type+" 该类型不是参数化类型!"));
					break;
			}
		}
		private function createCornerMesh(sourceMesh:L3DMesh,sourceMaterial:Material,posX:Number,posY:Number,posZ:Number,rotationY:Number,rotationZ:Number):Mesh
		{
			var mesh:L3DBuildableMesh = new L3DBuildableMesh();
			mesh.copy(sourceMesh.getChildAt(0) as Mesh);
			var transform:CTransform3D=Geometry3DUtil.instance.composeTransform(posX*GlobalConstDict.SCENE3D_SCALERATIO,posY*GlobalConstDict.SCENE3D_SCALERATIO,posZ*GlobalConstDict.SCENE3D_SCALERATIO,
				0,rotationY,rotationZ,GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO,GlobalConstDict.SCENE3D_SCALERATIO);
			var matrix3d:Matrix3D=Geometry3DUtil.instance.getMatrix3DByTransform3D(transform);
			mesh.applyMatrix(matrix3d);
			mesh.setMaterialToAllSurfaces(sourceMaterial);
			return mesh;
		}
		/**
		 * 执行解析xml,返回参数化3D物体任务数据对象 
		 * @param xml
		 * @param unitType
		 * @return CParam3DTaskVO	参数化3D物体任务数据对象 
		 * 
		 */		
		private function doDeserializeParamXML(xml:XML,unitType:uint,unitWidth:Number,unitHeight:Number,paramVos:Vector.<CParam3DTaskVO>,parentID:String=null):void
		{
			var classDict:Class=getClassByAlias(String(xml.name()));
			var vo:CParam3DTaskVO=new classDict();
			vo.deserialize(xml);
			if(parentID!=null)
				vo.parentID=parentID;
			vo.x=vo.y=0;
			if(vo is CParamRectangle3DTaskVO)
				vo.z=-unitHeight*.5+vo.offGround+vo.height*.5;
			else
				vo.z=-unitHeight*.5+vo.offGround;
			vo.unitType=unitType;
			vo.thicknessOffset=unitWidth;
			paramVos.push(vo);
			
			var children:XMLList=xml.children();
			var len:int=children.length();
			if(len>0)
			{
				for(var i:int=0; i<len; i++)
				{
					doDeserializeParamXML(XML(children[i]),vo.type,unitWidth,unitHeight,paramVos,vo.uniqueID);
				}
			}
		}
		/**
		 * 执行解析单元件，返回单元件3D物体任务数据 
		 * @param xml
		 * @return CUnit3DTaskVO	单元件3D物体任务数据 
		 * 
		 */		
		private function doDeserializeUnitXML(sourceXml:XML):void
		{
			var xml:XML;
			var xmlList:XMLList;
			var len:int,i:int;
			var paramVos:Vector.<CParam3DTaskVO>=new Vector.<CParam3DTaskVO>();
			var classDict:Class=getClassByAlias(String(sourceXml.name()));
			var vo:CUnit3DTaskVO=new classDict();
			vo.deserialize(sourceXml);
			vo.parentID=_wallVo.uniqueID;
			_sourcePlanData.planType=vo.type;
			_sourcePlanData.createOneUnit(vo);
			//解析单件子节点
			xmlList=sourceXml.children();
			len=xmlList.length();
			for(i=0;i<len;i++)
			{
				xml=xmlList[i] as XML;
				doDeserializeParamXML(xml,vo.type,vo.width,vo.height,_sourcePlanData.getParamVosByIndex(_sourcePlanData.size-1));
			}
		}
		/**
		 * 初始化装修 
		 * @param stage3d
		 * 
		 */		
		public function initDecoration(stage3d:Stage3D):void
		{
			_taskModel.initLoader(stage3d);
		}
		/**
		 * 添加事件监听 
		 * @param type	事件类型
		 * @param func		事件监听回调函数
		 * 
		 */		
		public function addEventListener(type:String,func:Function):void
		{
			_taskModel.addEventListener(type,func);
		}
		/**
		 * 移除事件监听 
		 * @param type	事件类型
		 * @param func		事件监听回调函数
		 * 
		 */		
		public function removeEventListener(type:String,func:Function):void
		{
			_taskModel.removeEventListener(type,func);
		}
		public function setXmlPlanDatas(datas:Array):void
		{
			if(_allXMLPlanDatas==null)
				_allXMLPlanDatas=datas;
		}
		/**
		 * 获取墙体数据 
		 * @param pointA
		 * @param pointB
		 * @return CWallVO
		 * 
		 */		
		public function getWallData(pointA:Point,pointB:Point):CWallVO
		{
			return CDataUtil.instance.getWallVoByRoundPoint3D(_taskModel.getDatasByType(Object3DDict.OBJECT3D_WALL),pointA,pointB);
		}
		/**
		 * 反序列化 
		 * @param xml
		 * 
		 */		
		public function deserialize(source:XML):void
		{
			_sourceXml=source;
			//解析单元件节点
			var xmlList:XMLList;
			var unitVo:CUnit3DTaskVO;
			var paramVos:Vector.<CParam3DTaskVO>;
			var len:int,i:int;
			_sourcePlanData.clear();
			xmlList=XMLList(source);
			len=xmlList.length();
			for(i=0;i<len;i++)
			{
				doDeserializeUnitXML(XML(xmlList[i]));
			}
		}
		/**
		 * 序列化数据 
		 * @return XML
		 * 
		 */		
		public function serialize():XML
		{
			return new XML();
		}
		
		private function setWallData(wallVo:CWallVO):void
		{
			if(wallVo==null) return;
			if(_wallVo==null || _wallVo.uniqueID!=wallVo.uniqueID || !_wallVo.startPos.equals(wallVo.startPos) || !_wallVo.endPos.equals(wallVo.endPos))
			{
				_taskModel.addData(wallVo);
				_wallVo=wallVo;
			}
		}
		/**
		 * 设置区域数据 
		 * @param index
		 * @param points
		 * 
		 */		
		private function setRegionData(index:int,points:Array):void
		{
//			if(_regionVo==null || _regionVo.indexInRoom != _wallVo.indexIn2DMode || _regionVo.indexInWall!=index)
//			{
//				
//			}
			var rectangle:Rectangle=CDataUtil.instance.getRectangleByRoundPoints(points);
			var pos3d:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(new Vector3D(rectangle.x+rectangle.width*.5-_wallVo.length*.5,-_wallVo.width-CDecorationParamDict.DEFAULT_UINT_BOARD_THICKNESS,_wallVo.height*.5-(rectangle.y+rectangle.height*.5)),_wallVo.transform,false);
			_regionVo=ModelManager.instance.createObject3DData(Object3DDict.DATA_REGION2D,UIDUtil.createUID(),_wallVo.uniqueID,rectangle.width,CDecorationParamDict.DEFAULT_UINT_BOARD_THICKNESS+1,rectangle.height,pos3d.x,pos3d.y,pos3d.z,_wallVo.rotation) as CRegionVO;
			_regionVo.indexInRoom=_wallVo.indexIn2DMode;
			_regionVo.indexInWall=index;
			_regions.push(_regionVo);
			_sourcePlanData.regionID=_regionVo.uniqueID;
			_sourcePlanData.wallID=_regionVo.parentID;
			_sourcePlanData.roundPoints.add(points);
		}
		private function doInitTaskVo(clone:CParam3DTaskVO,unitVo:CUnit3DTaskVO):void
		{
			var position:Vector3D=Geometry3DUtil.instance.transformVectorByCTransform3D(clone.position,unitVo.transform,false);
			clone.parentID=unitVo.uniqueID;
			clone.x=position.x;
			clone.y=position.y;
			clone.z=position.z;
			clone.rotation=unitVo.rotation;
			clone.direction=unitVo.direction;
			clone.direction.normalize();
			clone.cutLength= unitVo.cutLength>0 ? unitVo.cutLength-(unitVo.length-clone.length)*.5 : 0;
			clone.unitUniqueID=unitVo.uniqueID;
		}
		/**
		 * 缓存一个单元件中的所有部件
		 * @param unitVo
		 * 
		 */		
		private function doCreateParamVos(realUnitVo:CUnit3DTaskVO,realParamVos:Vector.<CParam3DTaskVO>,sourceParamVos:Vector.<CParam3DTaskVO>):void
		{
			var paths:Vector.<Vector3D>;
			var clone:CParam3DTaskVO;
			var position:Vector3D;
			var rectangleVo:CParamRectangle3DTaskVO;
			var groupID:String;
			for each(var paramVo:CParam3DTaskVO in sourceParamVos)
			{
				if(paramVo.material.length>0)
				{
					//任务数据本身有code
					groupID=CUtil.instance.createUID();
					paramVo.groupID=groupID;
					clone=paramVo.clone();
					if(CDecorationParamDict.PARAM_RECTANGLE_NOBOARD==CDecorationParamDict.instance.getParamType(clone.type))
					{
						rectangleVo=clone as CParamRectangle3DTaskVO;
						if(rectangleVo.width==0)
							rectangleVo.width=1;
					}
					doInitTaskVo(clone,realUnitVo);
					realParamVos.push(clone);
				}
				if(paramVo is CParamRectangle3DTaskVO)
				{
					rectangleVo=paramVo as CParamRectangle3DTaskVO;
					if(rectangleVo.lineCode.length>0)
					{
						//矩形区域的面板线样式
						groupID ||= CUtil.instance.createUID();
						rectangleVo.groupID=groupID;
						clone=rectangleVo.clone();
						doInitTaskVo(clone,realUnitVo);
						clone.code=rectangleVo.lineCode;
						clone.material=rectangleVo.lineMaterial;
						clone.type=rectangleVo.lineType;
						realParamVos.push(clone);
					}
					if(rectangleVo.cornerCode.length>0)
					{
						//矩形区域的拐角样式
						groupID ||=CUtil.instance.createUID();
						rectangleVo.groupID=groupID;
						clone=rectangleVo.clone();
						doInitTaskVo(clone,realUnitVo);
						clone.code=rectangleVo.cornerCode;
						clone.material=rectangleVo.cornerMaterial;
						clone.type=rectangleVo.cornerType;
						realParamVos.push(clone);
					}
				}
			}
		}
		/**
		 * 添加一个计划数据到计划数据集合中 
		 * @return CClapboardRegionPlanData
		 * 
		 */		
		private function getOneRegionPlanData():CClapboardRegionPlanData
		{
			var regionPlanData:CClapboardRegionPlanData;
//			for (var i:int=0; i<_planDatas.length; i++)
//			{
//				if(_planDatas[i].wallID==_sourcePlanData.wallID && _planDatas[i].regionID==_sourcePlanData.regionID)
//				{
//					regionPlanData=_planDatas[i];
//					regionPlanData.clear();
//					break;
//				}
//			}
//			if(regionPlanData==null)
//			{
//				regionPlanData=new CClapboardRegionPlanData();
//				regionPlanData.wallID=_sourcePlanData.wallID;
//				regionPlanData.regionID=_sourcePlanData.regionID;
//				_planDatas.push(regionPlanData);
//			}
			regionPlanData=new CClapboardRegionPlanData();
			regionPlanData.wallID=_sourcePlanData.wallID;
			regionPlanData.regionID=_sourcePlanData.regionID;
			_planDatas.push(regionPlanData);
			return regionPlanData;
		}
		/**
		 * 添加计划任务数据 
		 * @param taskVo
		 * 
		 */		
		private function doAddPlanTask(planData:CClapboardRegionPlanData):void
		{
			for(var i:int=0; i<planData.units.length; i+=CClapboardRegionPlanData.ATTRIBUTE_COUNT)
			{
				_taskModel.addTask(planData.units[i].clone());
				for(var j:int=0; j<planData.units[i+1].length; j++)
				{
					_taskModel.addTask(planData.units[i+1][j].clone());
				}
			}
		}
		private function doCreateRealUnitVo(sourceUnitVo:CUnit3DTaskVO,startPos:CVector3D):CUnit3DTaskVO
		{
			//计算当前单元件的中心点坐标
			var cutLength:Number=0;
			_wallVo.direction.normalize();
			var diff:CVector3D=new CVector3D(startPos.x+_wallVo.direction.x*sourceUnitVo.realLength*.5,startPos.y+_wallVo.direction.y*sourceUnitVo.realLength*.5,startPos.z+_wallVo.direction.z*sourceUnitVo.realLength*.5);
			diff.decrementBy(_wallVo.position);
			if(diff.dotProduct(sourceUnitVo.direction)>0)
			{
				cutLength=diff.length;
			}
			if(cutLength>0 && _sourcePlanData.tilingMode==CDecorationParamDict.TILING_NORMAL)  return null;
			var cloneUnitVo:CUnit3DTaskVO=sourceUnitVo.clone();
			cloneUnitVo.uniqueID=CUtil.instance.createUID();
			cloneUnitVo.x=startPos.x;
			cloneUnitVo.y=startPos.y;
			cloneUnitVo.z=startPos.z;
			cloneUnitVo.rotation=_wallVo.rotation;
			cloneUnitVo.direction=_wallVo.direction;
			cloneUnitVo.cutLength=cutLength;
			return cloneUnitVo;
		}
		/**
		 * 平铺护墙板方案 
		 * 
		 */		
		private function tilingUnitPlan(scaleX:Number,scaleY:Number):void
		{
			if(_wallVo==null || _sourcePlanData.units==null || _sourcePlanData.units.length==0) return;
			var planData:CClapboardRegionPlanData;
			var globalStartPos:Vector3D;
			var position:Vector3D;
			//获取当前区域计划数据
			planData=getOneRegionPlanData();
			//根据区域阵列模式,布置方案
			var unitNum:int=_regionVo.length/_sourcePlanData.realLength;
			_regionVo.direction.normalize();
			globalStartPos=new CVector3D(_regionVo.x-_regionVo.direction.x*_regionVo.length*.5,_regionVo.y-_regionVo.direction.y*_regionVo.length*.5,_regionVo.z-_regionVo.direction.z*_regionVo.length*.5);
			//计算单元件起始中点世界坐标
			var sourceUnitVo:CUnit3DTaskVO;
			var realUnitVo:CUnit3DTaskVO;
			var realParamVos:Vector.<CParam3DTaskVO>;
			var unitVoStartPos:CVector3D=new CVector3D();
			for(var i:int=0; i<unitNum; i++)
			{
				if(i>0)
					globalStartPos.setTo(globalStartPos.x+_regionVo.direction.x*_sourcePlanData.realLength,globalStartPos.y+_regionVo.direction.y*_sourcePlanData.realLength,globalStartPos.z+_regionVo.direction.z*_sourcePlanData.realLength);
				for(var j:int=0; j<_sourcePlanData.size; j+=CClapboardRegionPlanData.ATTRIBUTE_COUNT)
				{
					sourceUnitVo=_sourcePlanData.units[j] as CUnit3DTaskVO;
					unitVoStartPos.setTo(globalStartPos.x+_regionVo.direction.x*(sourceUnitVo.realLength*.5+sourceUnitVo.leftSpacing),globalStartPos.y+_regionVo.direction.y*(sourceUnitVo.realLength*.5+sourceUnitVo.leftSpacing),globalStartPos.z+_regionVo.direction.z*(sourceUnitVo.realLength*.5+sourceUnitVo.leftSpacing));
					realUnitVo=doCreateRealUnitVo(sourceUnitVo,unitVoStartPos);
					if(realUnitVo!=null)
					{
						planData.createOneUnit(realUnitVo);
						doCreateParamVos(realUnitVo,planData.getParamVosByIndex(planData.size-1),_sourcePlanData.units[j+1]);
					}
				}
			}
		}
		private function createPlanTaskDatas():void
		{
			_taskModel.clearCache();
			//创建护墙板计划的任务数据
			for each(var planData:CClapboardRegionPlanData in _planDatas)
			{
				if(planData.isLife)
					doAddPlanTask(planData);
			}
		}
		private function doSetRenderPlanData(roomWalls:Vector.<ICData>, xmlCaches:Array):void
		{
			var planObj:Object;
			for (var j:int=0; j<xmlCaches.length; j++)
			{
				//遍历房间所有的墙
				if(xmlCaches[j]==null || xmlCaches.length==0) continue;
				for(var k:int=0; k<xmlCaches[j].length; k++)
				{
					if(xmlCaches[j][k]==null) continue;
					//遍历墙上所有的计划区域
					planObj=xmlCaches[j][k];
					//设置当前墙面数据
					_wallVo=CDataUtil.instance.getWallVoByIndex(roomWalls,j);
					//设置当前区域数据
					setRegionData(k,planObj.points);
					_sourcePlanData.tilingMode=planObj.mode;
					//解析生成当前区域内的原始方案
					deserialize(planObj.xml);
					//阵列当前方案
					tilingUnitPlan(planObj.scaleX,planObj.scaleY);
				}
			}
		}
		/**
		 * 设置用于渲染的护墙板计划数据集合
		 * 
		 */		
		public function setRenderPlanData(isCurrentRoomIndex:int=-1):void
		{
			//方案生效，遍历原始xml数据,执行对应阵列操作
			_isNeedReRender=true;
			_currentRoomIndex=isCurrentRoomIndex;
		}
		private function doRenderPlanData():void
		{
			var roomWalls:Vector.<ICData>;
			var floors:Vector.<ICData>=_taskModel.getDatasByType(Object3DDict.OBJECT3D_ROOM);
			for each(var planData:CClapboardRegionPlanData in _planDatas)
			{
				planData.dispose();
			}
			_planDatas.length=0;
			if(_currentRoomIndex<0)
			{
				//渲染全部房间
				for(var i:int=0; i<floors.length; i++)
				{
					if(_allXMLPlanDatas[i] !=null && _allXMLPlanDatas[i].length>0)
					{
						roomWalls=_taskModel.getDatasByTypeAndParentID(Object3DDict.OBJECT3D_WALL,floors[i].uniqueID);
						doSetRenderPlanData(roomWalls,_allXMLPlanDatas[i]);
					}
				}
			}
			else
			{
				//渲染当前房间
				if(_allXMLPlanDatas[i] !=null && _allXMLPlanDatas[i].length>0)
				{
					roomWalls=_taskModel.getDatasByTypeAndParentID(Object3DDict.OBJECT3D_WALL,floors[_currentRoomIndex].uniqueID);
					doSetRenderPlanData(roomWalls,_allXMLPlanDatas[_currentRoomIndex]);
				}
			}
		}
		/**
		 * 执行任务，使用计划方案
		 * 
		 */		
		public function excuteStartDecoration():Boolean
		{
			if(!_taskModel.isLoadEnd) return false;
			if(_isNeedReRender)
			{
				_isNeedReRender=false;
				doRenderPlanData();
			}
			createPlanTaskDatas();
			return _taskModel.canLoad;
		}
		/**
		 * 开始下载 
		 * 
		 */		
		public function excuteTask():void
		{
			//开始处理任务加载
			_taskModel.startLoad();
		}
		/**
		 * 执行更换纹理操作 
		 * @param bitmapData
		 * 
		 */		
		public function excuteChangeMaterial(material:CTextureMaterial):void
		{
			if(!_isRunning || !_selectMesh) return;
			var rootMesh:Mesh;
			var l3dModel:L3DModel;
			var l3dMesh:L3DMesh;
			//创建新模型
			var tasks:Vector.<ITaskVO>=_selectMesh.userData2;
			var subMesh:Object3D;
			var l3dBitmapTextureResource:L3DBitmapTextureResource;
			//根据任务数据集合，创建装修模型组
			rootMesh=new Mesh();
			for each(var taskVo:ITaskVO in tasks)
			{
				doCreateDecorationMesh(taskVo,_selectMesh.userData3,material,rootMesh);
			}
			
			l3dModel=new L3DModel();
			l3dModel.Import(rootMesh,false,true);
			l3dMesh=l3dModel.Export(_taskModel.stage3d);
			l3dModel.Clear();
			for(var i:int=0 ;i<l3dMesh.numChildren; i++)
			{
				subMesh=l3dMesh.getChildAt(i) as Mesh;
				if(subMesh)
				{
					l3dBitmapTextureResource=((subMesh as Mesh).getSurface(0).material as TextureMaterial).diffuseMap as L3DBitmapTextureResource;
					l3dBitmapTextureResource.Url=(material.diffuseMap as L3DBitmapTextureResource).Url;
				}
			}
			l3dMesh.userData2=_selectMesh.userData2;
			l3dMesh.userData3=_selectMesh.userData3;
			l3dMesh.userData4=material;
			l3dMesh.userData5=_selectMesh.userData5;
			l3dMesh.userData6=_selectMesh.userData6;
			l3dMesh.catalog=_selectMesh.catalog;
			l3dMesh.family=_selectMesh.family;
			l3dMesh.Code=_selectMesh.Code;
			l3dMesh.ERPCode=_selectMesh.ERPCode;
			l3dMesh.Mode=_selectMesh.Mode;
			l3dMesh.isPolyMode=_selectMesh.isPolyMode;
			
			if(renderViewCallback!=null)
				renderViewCallback.call(null,l3dMesh);
		}
		/**
		 * 执行更新护墙板显示操作 
		 * 
		 */		
		public function updateClapboardView(length:Number,height:Number,floorHeight:Number,spacing:Number):Boolean
		{
			if(!_isRunning || _selectMesh==null || _selectMesh.userData2[0] is CUnit3DTaskVO) return false;
//			if(spacing>0)
//			{
//				curSpacing=spacing;
//			}
//			else
//			{
//				curLength=length;
//			}
			curLength=length;
			curHeight=height;
			curFloorHeight=floorHeight;
			
			if(_invalidClapboard)
			{
				_invalidClapboard=false;
				var rootMesh:Mesh;
				var vec:Vector3D;
				var l3dMesh:L3DMesh;
				var subMesh:Object3D;
				var l3dBitmapTextureResource:L3DBitmapTextureResource;
				
				var tasks:Vector.<ITaskVO>=_selectMesh.userData2;
				var tasksDic:Dictionary=new Dictionary();
				rootMesh=new Mesh();
				for each(var taskVo:CParam3DTaskVO in tasks)
				{
					if(taskVo.cutLength>0)
					{
						taskVo.cutLength-=(taskVo.length-_curLength)*.5;
					}
					taskVo.length=_curLength;
					taskVo.height=_curHeight;
					vec=Geometry3DUtil.instance.transformVectorByCTransform3D(new Vector3D(0,0,_curFloorHight-1400),_regionVo.transform,false);
					taskVo.z=vec.z;
					doCreateDecorationMesh(taskVo,_selectMesh.userData3,_selectMesh.userData4,rootMesh);
				}
				//创建新模型
				_l3dModel.Import(rootMesh,false,true);
				l3dMesh=_l3dModel.Export(_taskModel.stage3d);
				for(var i:int=0 ;i<l3dMesh.numChildren; i++)
				{
					subMesh=l3dMesh.getChildAt(i) as Mesh;
					if(subMesh)
					{
						l3dBitmapTextureResource=((subMesh as Mesh).getSurface(0).material as TextureMaterial).diffuseMap as L3DBitmapTextureResource;
						l3dBitmapTextureResource.Url=((_selectMesh.userData4 as TextureMaterial).diffuseMap as L3DBitmapTextureResource).Url;
					}
				}
				l3dMesh.userData2=_selectMesh.userData2;
				l3dMesh.userData3=_selectMesh.userData3;
				l3dMesh.userData4=_selectMesh.userData4;
				l3dMesh.userData5=_selectMesh.userData5;
				l3dMesh.userData6=_selectMesh.userData6;
				l3dMesh.catalog=_selectMesh.catalog;
				l3dMesh.family=_selectMesh.family;
				l3dMesh.Code=_selectMesh.Code;
				l3dMesh.ERPCode=_selectMesh.ERPCode;
				l3dMesh.Mode=_selectMesh.Mode;
				l3dMesh.isPolyMode=_selectMesh.isPolyMode;
				if(renderViewCallback!=null)
					renderViewCallback.call(null,l3dMesh);
				return true;
			}
			return false;
		}
		/**
		 * 执行改变模型样式 
		 * @param sourceMesh
		 * 
		 */		
		public function excuteChangeMesh(sourceMesh:L3DMesh):void
		{
			if(!_isRunning || !_selectMesh) return;
			var l3dModel:L3DModel;
			var l3dMesh:L3DMesh;
			var rootMesh:Mesh;
			var subMesh:Object3D;
			var l3dBitmapTextureResource:L3DBitmapTextureResource;
			//创建新模型
			rootMesh=new Mesh();
			var tasks:Vector.<ITaskVO>=_selectMesh.userData2;
			for each(var taskVo:ITaskVO in tasks)
			{
				doCreateDecorationMesh(taskVo,sourceMesh,_selectMesh.userData4,rootMesh);
			}
			l3dModel=new L3DModel();
			l3dModel.Import(rootMesh,false,true);
			l3dMesh=l3dModel.Export(_taskModel.stage3d);
			l3dModel.Clear();
			for(var i:int=0 ;i<l3dMesh.numChildren; i++)
			{
				subMesh=l3dMesh.getChildAt(i) as Mesh;
				if(subMesh)
				{
					l3dBitmapTextureResource=((subMesh as Mesh).getSurface(0).material as TextureMaterial).diffuseMap as L3DBitmapTextureResource;
					l3dBitmapTextureResource.Url=((_selectMesh.userData4 as TextureMaterial).diffuseMap as L3DBitmapTextureResource).Url;
				}
			}
			l3dMesh.userData2=_selectMesh.userData2;
			l3dMesh.userData3=sourceMesh;
			l3dMesh.userData4=_selectMesh.userData4;
			l3dMesh.userData5=_selectMesh.userData5;
			l3dMesh.userData6=_selectMesh.userData6;
			l3dMesh.catalog=_selectMesh.catalog;
			l3dMesh.family=_selectMesh.family;
			l3dMesh.Code=_selectMesh.Code;
			l3dMesh.ERPCode=_selectMesh.ERPCode;
			l3dMesh.Mode=_selectMesh.Mode;
			l3dMesh.isPolyMode=_selectMesh.isPolyMode;
			if(renderViewCallback!=null)
				renderViewCallback.call(null,l3dMesh);
		}
		public function excuteMouseDown(mesh:L3DMesh):void
		{
			if(!_isRunning) return;
		}
		public function excuteMouseUp(mesh:L3DMesh):void
		{
			_selectMesh=mesh;
			if(!_isRunning || mesh==null || mesh.userData2==null || mesh.userData2.length==0 || (mesh.userData2[0] is CUnit3DTaskVO)) return;
			var planData:CClapboardRegionPlanData;
			var unitVo:CUnit3DTaskVO;
			var paramVo:CParam3DTaskVO=mesh.userData2[0] as CParam3DTaskVO;
			if(paramVo)
			{
				_curLength=paramVo.length;
				_curHeight=paramVo.height;
//				_curSpacing=(_sourcePlanData.unitVo.length-paramVo.length)*.5;
				_curFloorHight=paramVo.offGround;
			}
		}
		/**
		 * 删除护墙板装修模型数据 
		 * @param taskVo
		 * 
		 */		
		public function removeDecorationMeshData(mesh:L3DMesh):void
		{
			var paramVo:CParam3DTaskVO=mesh.userData2[0] as CParam3DTaskVO;
			if(paramVo==null) return;
			var paramVos:Vector.<CParam3DTaskVO>;
			for(var i:int=0; i<_planDatas.length; i++)
			{
				for(var j:int=0; j<_planDatas[i].size; j++)
				{
					paramVos=_planDatas[i].getParamVosByIndex(j);
					for(var k:int=0;k<paramVos.length; k++)
					{
						if(paramVos[k].type==paramVo.type && paramVos[k].length==paramVo.length && paramVos[k].height==paramVo.height && paramVos[k].offGround==paramVo.offGround)
						{
							paramVos.splice(k,1);
							break;
						}
					}
				}
			}
			var unitVos:Vector.<ICData>=_taskModel.getCacheDatasByType(paramVo.unitType);
			var wallVo:CWallVO=_taskModel.getDataByTypeAndID(Object3DDict.OBJECT3D_WALL,unitVos[0].parentID) as CWallVO;
			var sourceXml:XML;
			var xmlCaches:Array=_allXMLPlanDatas[wallVo.roomIndex];
			for(i=0; i<xmlCaches.length; i++)
			{
				if(xmlCaches[i]==null) continue;
				for(j=0; j<xmlCaches[i].length; j++)
				{
					if(xmlCaches[i][j]==null) continue;
					sourceXml=XML(xmlCaches[i][j].xml);
					doRemoveXMLChild(CDecorationParamDict.instance.getTypeName(paramVo.type),paramVo.length,paramVo.height,paramVo.offGround,sourceXml);
				}
			}
		}
		private function doRemoveXMLChild(typeName:String,length:Number,height:Number,offGround:Number,xml:XML):void
		{
			var xmlList:XMLList=xml.children();
			var child:XML;
			var len:int=xmlList.length();
			var xmlLength:Number;
			var xmlHeight:Number;
			var xmlOffGround:Number;
			for(var i:int=0; i<len; i++)
			{
				child=XML(xmlList[i]);
				xmlLength=Number(child.@length);
				xmlHeight=Number(child.@height);
				xmlOffGround=Number(child.@offGround);
				if(xmlLength==length && xmlHeight==height && xmlOffGround==offGround)
				{
					if(child.@type==typeName || child.@lineType==typeName)
					{
						delete child.parent().children()[child.childIndex()];
						break;
					}
//					else if(child.@lineType==typeName)
//					{
//						child.@lineType="";
//						child.@lineCode="";
//						child.@lineMaterial="";
//						break;
//					}
					else if(child.@cornerType==typeName)
					{
						child.@cornerType="";
						child.@cornerCode="";
						child.@cornerMaterial="";
						break;
					}
				}
			}
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
			_wallVo=null;
		}
		public function clearData():void
		{
			_taskModel.clearAll();
		}
		/**
		 * 通过2个墙体的围点，删除计划数据 
		 * @param pointA
		 * @param pointB
		 * 
		 */		
		public function deletePlanDataByWallPosition(pointA:Point, pointB:Point):void
		{
			var wallVo:CWallVO=CDataUtil.instance.getWallVoByRoundPoint3D(_taskModel.getCacheDatasByType(Object3DDict.OBJECT3D_WALL),pointA,pointB);
			if(wallVo)
			{
				for (var i:int=0; i<_planDatas.length; i++)
				{
					if(_planDatas[i].wallID==wallVo.uniqueID)
					{
						_planDatas[i].clear();
						_planDatas.removeAt(i);
						break;
					}
				}
			}
		}
		/**
		 * 清空全部数据 
		 * 
		 */		
		public function clearAll():void
		{
			_isRunning=false;
			for each(var regionVo:CRegionVO in _regions)
			{
				regionVo.clear();
			}
			_regions.length=0;
			for each(var planData:CClapboardRegionPlanData in _planDatas.length)
			{
				planData.dispose();
			}
			_planDatas.length=0;
			
			_sourcePlanData.clear();
			_taskModel.clearAll();
			_allXMLPlanDatas=null;
			_sourceXml=null;
			_selectMesh=null;
			_wallVo=null;
		}
		public function updateByFrame(startTime:Number=0, frameTime:Number=0):void
		{
		}
	}
}