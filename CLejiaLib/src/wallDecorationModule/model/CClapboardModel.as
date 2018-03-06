package wallDecorationModule.model
{
	import flash.geom.Rectangle;
	
	import mx.utils.UIDUtil;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.datas.maps.CHashMap;
	import cloud.core.interfaces.ICData;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	import cloud.core.utils.CGeometry3DUtil;
	import cloud.core.utils.CMathUtil;
	import cloud.core.utils.CMathUtilForAS;
	import cloud.core.utils.CUtil;
	
	import main.dict.CDataTypeDict;
	import main.dict.CParamDict;
	import main.model.CDecorationModel;
	import main.model.vo.CRegionVO;
	import main.model.vo.CWallVO;
	import main.model.vo.task.CParamPartVO;
	
	import utils.CDataUtil;
	
	import wallDecorationModule.model.vo.CClapboardUnitVO;

	/**
	 *  护墙板数据模型类
	 * @author cloud
	 * 
	 */	
	public class CClapboardModel extends CDecorationModel
	{
		/**
		 * 当前墙体数据 
		 */		
		private var _curWallVo:CWallVO;
		/**
		 * 当前墙体上的区域数据 
		 */		
		private var _curRegionVo:CRegionVO;
		/**
		 * 渲染单元件元数据集合 
		 */		
		private var _unitRenderVos:Vector.<CClapboardUnitVO>;
		
		/**
		 * 所有房间的护墙板计划数据 
		 */		
		public var allPlanDatas:CHashMap;

		public function CClapboardModel()
		{
			super("CClapboardModel");
			_unitRenderVos=new Vector.<CClapboardUnitVO>();
			_moduleType=CDataTypeDict.CLAPBOARD_PLAN_DATAS;
		}
		/**
		 * 采集计划渲染数据集合
		 * 
		 */		
		private function doCollectPlanRenderDatas():void
		{
			var roomWalls:Vector.<ICData>;
			var floors:Vector.<ICData>=getDatasByType(CDataTypeDict.OBJECT3D_ROOM);
			//释放旧的计划渲染数据
			for each(var unitVo:CClapboardUnitVO in _unitRenderVos)
			{
				unitVo.clear();
			}
			_unitRenderVos.length=0;
			clearAllCache();
			//渲染全部房间
			var xmlArr:Array;
			for(var i:int=0; i<floors.length; i++)
			{
				xmlArr=allPlanDatas.get(floors[i].uniqueID) as Array;
				if(xmlArr!=null && xmlArr.length>0)
				{
					roomWalls=getDatasByTypeAndParentID(CDataTypeDict.OBJECT3D_WALL,floors[i].uniqueID);
					doCreatePlanRenderDatas(roomWalls,xmlArr);
				}
			}
		}
		private function doUpdateRegionPoints(regionPoints:Array,wallLength:Number,prevOffset:Number=0,nextOffset:Number=0):void
		{
			var curCrossValue:Number;
			var indexArr:Array;
			var i:int,len:int;
			indexArr=CMathUtilForAS.Instance.getStartPosIndexByXYArray(regionPoints);
			//判断当前墙面区域的护墙板是否需要根据墙面的凹凸角进行内切还是外延
			if(regionPoints[indexArr[0]].x==0 && prevOffset!=0)
			{
				//判断前一面墙的最后区域是否有护墙板计划
				len=regionPoints.length;
				for(i=0;i<len;i++)
				{
					if(regionPoints[i].x==0)
					{
						regionPoints[i].x+=prevOffset;
					}
				}
			}
			//判断后一面墙的第一个区域是否有护墙板
			if(regionPoints[indexArr[1]].x==wallLength && nextOffset!=0)
			{
				len=regionPoints.length;
				for(i=0;i<len;i++)
				{
					if(regionPoints[i].x==wallLength)
					{
						regionPoints[i].x+=nextOffset;
					}
				}
			}
		}
		/**
		 * 创建计划渲染数据集合 
		 * @param roomWalls
		 * @param xmlCaches
		 * 
		 */		
		private function doCreatePlanRenderDatas(roomWalls:Vector.<ICData>, xmlCaches:Array):void
		{
			var sourcePlanRenderData:Object;
			var indexArr:Array;
			var i:int,j:int,k:int;
			var prev:int,next:int,wallLen:int,regionLen:int,plen:int;
			var crossValue:Number,tmpCrossValue:Number;
			var nor:CVector;
			//计算房间的正向
			wallLen=roomWalls.length;
			var tmpArr:Array=[];
			for(i=0; i<wallLen; i++)
			{
				tmpArr[i]=roomWalls[i];
			}
			indexArr=CMathUtilForAS.Instance.getStartPosIndexByXYArray(tmpArr);
			crossValue=CVector.CrossValue(tmpArr[indexArr[1]].direction,tmpArr[indexArr[0]].direction).z;
			//遍历房间所有的墙
			var newPoints:Array;
			wallLen=xmlCaches.length;
			for (i=0; i<wallLen; i++)
			{
				if(xmlCaches[i]==null || xmlCaches.length==0) continue;
				prev=i==0?wallLen-1:i-1;
				next=i==wallLen-1?0:i+1;
				//更新墙的起点方向偏移值和终点方向偏移值
				if(i!=prev && xmlCaches[prev] && xmlCaches[prev].length>0)
				{
					tmpCrossValue=CVector.CrossValue(tmpArr[prev].direction,tmpArr[i].direction).z;
					tmpArr[i].startOffsetScale=crossValue*tmpCrossValue<0?-1:1;
				}
				if(i!=next && xmlCaches[next] && xmlCaches[next].length>0)
				{
					tmpCrossValue=CVector.CrossValue(tmpArr[i].direction,tmpArr[next].direction).z;
					tmpArr[i].endOffsetScale=crossValue*tmpCrossValue<0?-1:1;
				}
				//设置当前墙面数据
				_curWallVo=CDataUtil.Instance.getWallVoByIndex(roomWalls,i);
				//遍历墙上所有的计划区域
				regionLen=xmlCaches[i].length;
				for(j=0; j<regionLen; j++)
				{
					if(xmlCaches[i][j]==null) continue;
					sourcePlanRenderData=xmlCaches[i][j];
					//更新区域围点数据
					newPoints=[];
					plen=sourcePlanRenderData.points.length;
					for(k=0;k<plen;k++)
					{
						newPoints[k]=sourcePlanRenderData.points[k].clone();
					}
//					doUpdateRegionPoints(newPoints,tmpArr[i].length,tmpArr[i].startOffsetScale,tmpArr[i].endOffsetScale);
					//设置当前区域数据
					setRegionData(newPoints,sourcePlanRenderData.xml,sourcePlanRenderData.mode,j,i,tmpArr[i].startOffsetScale,tmpArr[i].endOffsetScale);
					//解析生成当前区域内的原始方案
					deserializeXML(sourcePlanRenderData.xml,null);
					//阵列当前方案
					tilingUnitPlan(sourcePlanRenderData.scaleX,sourcePlanRenderData.scaleY);
				}
			}
		}
		/**
		 * 创建计划渲染数据中的一个单元件数据 
		 * @param sourceUnitVo
		 * @param startPos
		 * @param unitName
		 * @param outPutVec
		 * @return CClapboardUnitVO
		 * 
		 */		
		private function doCreateRealUnitVo(sourceUnitVo:CClapboardUnitVO,startPos:CVector,unitName:String,outputPosition:CVector):CClapboardUnitVO
		{
			//计算当前单元件的中心点坐标
			var cutLength:Number=0;
			CVector.Normalize(_curWallVo.direction);
			CVector.SetTo(outputPosition,startPos.x+_curWallVo.direction.x*sourceUnitVo.realLength*.5,startPos.y+_curWallVo.direction.y*sourceUnitVo.realLength*.5,startPos.z+_curWallVo.direction.z*sourceUnitVo.realLength*.5);
			CVector.Decrease(outputPosition,_curWallVo.position);
			if(CVector.DotValue(outputPosition,sourceUnitVo.direction)>0)
			{
				cutLength=outputPosition.length;
			}
			var cloneUnitVo:CClapboardUnitVO=sourceUnitVo.clone() as CClapboardUnitVO;
			cloneUnitVo.name=unitName;
			cloneUnitVo.uniqueID=CUtil.Instance.createUID();
			cloneUnitVo.x=startPos.x;
			cloneUnitVo.y=startPos.y;
			cloneUnitVo.z=startPos.z;
			cloneUnitVo.cutLength=cutLength;
			cloneUnitVo.parentID=_curWallVo.uniqueID;
			cloneUnitVo.roomID=_curWallVo.roomID;
			cloneUnitVo.wallID=_curWallVo.uniqueID;
			cloneUnitVo.rotationHeight=_curWallVo.rotationHeight;
			return cloneUnitVo;
		}
		/**
		 * 创建单元件数据中的参数化部件数据 
		 * @param realParentVo
		 * @param sourceParentVo
		 * 
		 */		
		private function doCreateParamPartVo(realParentVo:CParamPartVO,sourceParentVo:CParamPartVO):void
		{
			var clone:CParamPartVO;
			for(var child:CParamPartVO=sourceParentVo.children as CParamPartVO; child!=null; child=child.next as CParamPartVO)
			{
				clone=child.clone() as CParamPartVO;
				clone.name=realParentVo.name;
				clone.roomID=realParentVo.roomID;
				clone.wallID=realParentVo.wallID;
				realParentVo.addChild(clone);
				doCreateParamPartVo(clone,child);
			}
		}
		/**
		 * 根据计划渲染数据，阵列护墙板
		 * 
		 */		
		private function tilingUnitPlan(scaleX:Number,scaleY:Number):void
		{
			if(_curWallVo==null || _curRegionVo.units.length==0) return;
			var globalStartPos:CVector=CVector.CreateOneInstance();
			var unitVoStartPos:CVector=CVector.CreateOneInstance();
			var position:CVector=CVector.CreateOneInstance();
			var dir:CVector=_curRegionVo.direction.clone() as CVector;
			//根据区域阵列模式,布置方案
			var unitNum:Number;
			var unitLength:Number;
			switch(_curRegionVo.mode)
			{
				case CParamDict.TILING_DECREASE:
				case CParamDict.TILING_INCREASE:
					unitNum=_curRegionVo.length/_curRegionVo.realLength;
					unitNum=int(unitNum+0.001);
					unitLength=_curRegionVo.realLength;
					break;
				case CParamDict.TILING_NORMAL:
					unitNum=int(_curRegionVo.length/(_curRegionVo.realLength/scaleX));
					unitLength=(_curRegionVo.realLength/scaleX);
					break;
				default:
					unitNum=1;
					unitLength=_curRegionVo.realLength;
					break;
			}
			CVector.Scale(dir,_curRegionVo.length);
			CVector.SetTo(globalStartPos,_curRegionVo.x-dir.x*.5,_curRegionVo.y-dir.y*.5,_curRegionVo.z-dir.z*.5);
			CVector.Normalize(dir);
			CVector.Scale(dir,unitLength);
			//应用方案并创建真实的墙面护墙板单元件数据
			var sourceUnitVo:CClapboardUnitVO;
			var realUnitVo:CClapboardUnitVO;
			var realParamVos:Vector.<CParamPartVO>;
			var groupName:String=CParamDict.Instance.getGroupName(_curRegionVo.units[0].type);
			
			for(var i:int=0; i<unitNum; i++)
			{
				//分析每一组单元件方案数据
				if(i>0)
					CVector.SetTo(globalStartPos,globalStartPos.x+dir.x,globalStartPos.y+dir.y,globalStartPos.z+dir.z);
				for(var j:int=0; j<_curRegionVo.units.length; j++)
				{
					//创建每一组单元件方案内的所有单元件真实数据
					//TODO：根据区域数据是否有起始点或终止点偏移，修正数据
					sourceUnitVo=_curRegionVo.units[j] as CClapboardUnitVO;
					sourceUnitVo.length=unitLength;
					CVector.SetTo(unitVoStartPos
						,globalStartPos.x+_curRegionVo.direction.x*(sourceUnitVo.realLength*.5+sourceUnitVo.offLeft)
						,globalStartPos.y+_curRegionVo.direction.y*(sourceUnitVo.realLength*.5+sourceUnitVo.offLeft)
						,globalStartPos.z+_curRegionVo.direction.z*(sourceUnitVo.realLength*.5+sourceUnitVo.offLeft));
					realUnitVo=doCreateRealUnitVo(sourceUnitVo,unitVoStartPos,groupName,position);
					if(!realUnitVo)
					{
						continue;
					}
					//更新起始点终止点的偏移缩放值
					if(_curRegionVo.startOffsetScale!=0 && CMathUtil.Instance.equalByValue(CVector.DotValue(_curWallVo.startPos,dir),CVector.DotValue(globalStartPos,dir)))
					{
						realUnitVo.startOffsetScale=_curRegionVo.startOffsetScale;
					}
					if(_curRegionVo.endOffsetScale!=0 && CMathUtil.Instance.equalByValue(CVector.DotValue(_curWallVo.endPos,dir),CVector.DotValue(CVector.Add(globalStartPos,dir),dir)))
					{
						realUnitVo.endOffsetScale=_curRegionVo.endOffsetScale;
					}
					//创建真实部件数据
					_unitRenderVos.push(realUnitVo);
					doCreateParamPartVo(realUnitVo,sourceUnitVo);
				}
			}
			globalStartPos.back();
			unitVoStartPos.back();
			position.back();
			dir.back();
		}
		/**
		 * 设置区域数据 
		 * @param index
		 * @param points
		 * 
		 */		
		private function setRegionData(points:Array,xml:XML,mode:int,index:int,wallIndex:int,prevOffset:Number,nextOffset:Number):void
		{
			var rectangle:Rectangle=CDataUtil.Instance.getRectangleByRoundPoints(points);
			var pos3D:CVector=CVector.CreateOneInstance();
			pos3D.x=rectangle.x+rectangle.width*.5-_curWallVo.length*.5;
			pos3D.y=-_curWallVo.width-CParamDict.DEFAULT_CLAPBOARD_UINT_BOARD_THICKNESS-2;
			pos3D.z=_curWallVo.height*.5-(rectangle.y+rectangle.height*.5);
			CGeometry3DUtil.Instance.transformVectorByCTransform3D(pos3D,_curWallVo.transform,false);
			if(_curRegionVo)
				_curRegionVo.clear();
			_curRegionVo=CDataUtil.Instance.createRegionPlanVO(CDataTypeDict.DATA_REGION2D,UIDUtil.createUID(),_curWallVo.uniqueID,rectangle.width,CParamDict.DEFAULT_CLAPBOARD_UINT_BOARD_THICKNESS+1,rectangle.height,pos3D.x,pos3D.y,pos3D.z,_curWallVo.rotationHeight) as CRegionVO;
			_curRegionVo.planXML=xml;
			_curRegionVo.roomID=_curWallVo.roomID;
			_curRegionVo.wallID=_curWallVo.uniqueID;
			_curRegionVo.wallIndex=wallIndex;
			_curRegionVo.index=index;
			_curRegionVo.mode=mode;
			_curRegionVo.roundPoints.add(points);
			_curRegionVo.startOffsetScale=prevOffset;
			_curRegionVo.endOffsetScale=nextOffset;
//			allRegionVos.push(_curRegionVo);
			pos3D.back();
		}
		/**
		 * 采集计划任务数据 
		 * 
		 */	
		private function doCollectPlanTaskDatas():void
		{
			//创建护墙板计划的任务数据
			for each(var unitVo:CClapboardUnitVO in _unitRenderVos)
			{
				if(unitVo.isLife)
				{
					addTask(unitVo);
					doAddPlanTask(unitVo);
				}
			}
		}
		/**
		 *  删除XML的子节点
		 * @param typeName
		 * @param length
		 * @param height
		 * @param xml
		 * @return Boolean
		 * 
		 */		
		private function doRemoveXMLChild(typeName:String,length:Number,height:Number,xml:XML):Boolean
		{
			var xmlLength:Number;
			var xmlHeight:Number;
			xmlLength=Number(xml.@length);
			xmlHeight=Number(xml.@height);
			if(xmlLength==length && xmlHeight==height)
			{
				if(xml.@type==typeName ||
					xml.@lineType==typeName ||
					xml.@cornerType==typeName)
				{
					delete xml.parent().children()[xml.childIndex()];
					return true;
				}
			}
			var xmlList:XMLList=xml.children();
			var len:int=xmlList.length();
			for(var i:int=0; i<len; i++)
			{
				if(doRemoveXMLChild(typeName,length,height,xmlList[i]))
					return true;
			}
			return false;
		}
		
		override protected function doDeserializeComplete(vo:CBaseObject3DVO):void
		{
			if(vo is CClapboardUnitVO)
			{
				_curRegionVo.addUnitVo(vo as CClapboardUnitVO);
			}
		}
		
		/**
		 * 执行任务，使用计划方案 
		 * @return Boolean
		 * 
		 */			
		public function excuteDataCollection():Boolean
		{
			if(!isLoadEnd || allPlanDatas==null || allPlanDatas.size==0) return false;
			if(invalidPlanRenderData)
			{
				invalidPlanRenderData=false;
				doCollectPlanRenderDatas();
				doCollectPlanTaskDatas();
			}
			return canLoad;
		}
		/**
		 * 移除修改计划数据 
		 * @param partVo
		 * 
		 */		
		public function removePlanData(sourceVo:CParamPartVO):void
		{
			var sourceXmlList:XMLList;
			var len:int;
			var i:int,j:int;
			var wallVo:CWallVO;
			var xmlObjArr:Array;
			wallVo=getDataByTypeAndID(CDataTypeDict.OBJECT3D_WALL,sourceVo.wallID) as CWallVO;
			if(wallVo==null) return;
			xmlObjArr=allPlanDatas.get(wallVo.roomID)[wallVo.indexIn2DMode];
			for(i=0; i<xmlObjArr.length; i++)
			{
				if(xmlObjArr[i]==null) continue;
				sourceXmlList=xmlObjArr[i].xml.children();
				len=sourceXmlList.length();
				for(j=0;j<len;j++)
				{
					if(doRemoveXMLChild(CParamDict.Instance.getTypeName(sourceVo.type),sourceVo.length,sourceVo.height,sourceXmlList[j]))
					{
						break;
					}
				}
				sourceXmlList=xmlObjArr[i].xml.children();
				if(sourceXmlList.length()==0)
				{
					xmlObjArr[i]=null;
				}
			}
		}
		override public function clearAll():void
		{
			super.clearAll();
			for each(var unitVo:CClapboardUnitVO in _unitRenderVos)
			{
				unitVo.clear();
			}
			_unitRenderVos.length=0;
			if(_curRegionVo)
			{
				_curRegionVo.clear();
				_curRegionVo=null;
			}
			allPlanDatas=null;
			_curWallVo=null;
		}
	}
}