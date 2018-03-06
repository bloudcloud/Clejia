package wallDecorationModule.model
{
	import cloud.core.datas.base.CVector;
	import cloud.core.datas.maps.CHashMap;
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import main.dict.CDataTypeDict;
	import main.dict.CParamDict;
	import main.model.CDecorationModel;
	import main.model.vo.CWallVO;
	
	import utils.CDataUtil;
	
	import wallDecorationModule.model.vo.CDoorUnitVO;
	
	/**
	 * 参数化门数据模型类
	 * @author cloud
	 * @2017-8-30
	 */
	public class CDoorModel extends CDecorationModel
	{
		private var _curSourceUnitVo:CDoorUnitVO;
		private var _unitRenderVos:Vector.<CDoorUnitVO>;
		private var _curWallVo:CWallVO;
		private var _preViewVo:CDoorUnitVO;
		
		/**
		 * 所有房间的护墙板计划数据 
		 */		
		public var allPlanDatas:CHashMap;
		
		public function CDoorModel()
		{
			super("CDoorModel");
			_unitRenderVos=new Vector.<CDoorUnitVO>();
		}
		
		private function doCollectPlanRenderDatas():void
		{
			var roomWalls:Vector.<ICData>;
			var floors:Vector.<ICData>=getDatasByType(CDataTypeDict.OBJECT3D_ROOM);
			//释放旧的计划渲染数据
			for each(var unitVo:CDoorUnitVO in _unitRenderVos)
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
		/**
		 * 创建计划渲染数据集合 
		 * @param roomWalls
		 * @param xmlCaches
		 * 
		 */		
		private function doCreatePlanRenderDatas(roomWalls:Vector.<ICData>, xmlCaches:Array):void
		{
			var sourcePlanRenderData:Object;
			//遍历房间所有的墙
			for (var j:int=0; j<xmlCaches.length; j++)
			{
				if(xmlCaches[j]==null || xmlCaches.length==0) continue;
				//遍历墙上所有的计划区域
				for(var k:int=0; k<xmlCaches[j].length; k++)
				{
					if(xmlCaches[j][k]==null) continue;
					sourcePlanRenderData=xmlCaches[j][k];
					//设置当前墙面数据
					_curWallVo=CDataUtil.Instance.getWallVoByIndex(roomWalls,j);
					//解析生成当前区域内的原始方案
					deserializeXML(sourcePlanRenderData.xml,null);
				}
			}
		}
		private function doCollectPlanTaskDatas():void
		{
			for each(var unitVo:CDoorUnitVO in _unitRenderVos)
			{
				if(unitVo.isLife)
				{
					addTask(unitVo);
					doAddPlanTask(unitVo);
				}
			}
		}
		private function doDeserializePlanXML(source:XML,parent:ICObject3D):void
		{
			if(source==null) return;
			var clsName:String;
			var cls:Class;
			var xmlList:XMLList=source.children();
			var len:int=xmlList.length();
			var vo:CBaseObject3DVO;
			for(var i:int=0; i<len; i++)
			{
				clsName=String(XML(xmlList[i]).name());
				CParamDict.Instance.addTypeDef(String(xmlList[i].@type),clsName);
				cls=CParamDict.Instance.getParamDataTypeCls(clsName);
				vo=new cls(clsName);
				vo.moduleType=_moduleType;
				if(parent!=null)
				{
					parent.addChild(vo);
				}
				vo.deserialize(xmlList[i]);
				if(vo is CDoorUnitVO)
				{
					_preViewVo=vo as CDoorUnitVO;
				}
				doDeserializePlanXML(xmlList[i],vo);
			}
		}
		
		override protected function doDeserializeComplete(vo:CBaseObject3DVO):void
		{
			if(vo is CDoorUnitVO)
			{
				var dir:CVector=CVector.CreateOneInstance();
				var startPos:CVector=CVector.CreateOneInstance();
				CVector.Copy(dir,_curWallVo.direction);
				var toward:CVector=CVector.CrossValue(dir,CVector.Z_AXIS);
				CVector.Scale(toward,6);
				CVector.Scale(dir,_curWallVo.realLength*.5);
				CVector.SetTo(startPos,_curWallVo.x-dir.x,_curWallVo.y-dir.y,_curWallVo.z-dir.z-_curWallVo.realHeight*.5);
				CVector.Normalize(dir);
				CVector.Scale(dir,vo.length*vo.scaleLength*.5);
				vo.x=startPos.x+dir.x+toward.x;
				vo.y=startPos.y+dir.y+toward.y;
				vo.z=startPos.z+dir.z+toward.z;
				vo.rotationHeight=_curWallVo.rotationHeight;
				CVector.Copy(vo.direction,_curWallVo.direction);
				_unitRenderVos.push(vo);
				dir.back();
				toward.back();
				startPos.back();
			}
		}
		public function excuteDataCollection():Boolean
		{
			if(!isLoadEnd || allPlanDatas==null || allPlanDatas.size==0) return false;
			doCollectPlanRenderDatas();
			doCollectPlanTaskDatas();
			return canLoad;
		}
		/**
		 * 执行预览计划 
		 * @param planData
		 * 
		 */		
		public function excutePreviewPlan(planData:Object):Boolean
		{
			doDeserializePlanXML(planData.xml,null);
			addTask(_preViewVo);
			doAddPlanTask(_preViewVo);
			return canLoad;
		}
	}
}