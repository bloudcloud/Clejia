package wallDecorationModule.model
{
	import cloud.core.datas.base.CVector;
	import cloud.core.datas.maps.CHashMap;
	import cloud.core.interfaces.ICData;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import main.dict.CDataTypeDict;
	import main.model.CDecorationModel;
	import main.model.vo.CWallVO;
	import main.model.vo.plans.CParamPlanVO;
	import main.model.vo.task.CBaseTaskObject3DVO;
	
	import utils.CDataUtil;
	
	public class CBackgroundWallModel extends CDecorationModel
	{
		/**
		 * 当前墙体数据 
		 */		
		private var _curWallVo:CWallVO;
		/**
		 * 渲染单元件元数据集合 
		 */		
		private var _planRenderVos:Vector.<CParamPlanVO>;
		
		public var allPlanDatas:CHashMap;
		
		public function CBackgroundWallModel()
		{
			super("CBackgroundWallModel");
			_planRenderVos=new Vector.<CParamPlanVO>();
			_moduleType=CDataTypeDict.BACKGROUND_PLAN_DATAS;
		}
		/**
		 * 执行计划数据的渲染 
		 * 
		 */		
		private function doCollectPlanRenderDatas():void
		{
			var roomWalls:Vector.<ICData>;
			var floors:Vector.<ICData>=getDatasByType(CDataTypeDict.OBJECT3D_ROOM);
			//释放旧的计划渲染数据
			for each(var planVo:CParamPlanVO in _planRenderVos)
			{
				planVo.clear();
			}
			_planRenderVos.length=0;
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
			var sourceXML:XML;
			//遍历房间所有的墙
			for (var j:int=0; j<xmlCaches.length; j++)
			{
				if(xmlCaches[j]==null || xmlCaches.length==0) continue;
				//遍历墙上所有的计划区域
				sourceXML=XML(xmlCaches[j]);
				_curWallVo=CDataUtil.Instance.getWallVoByIndex(roomWalls,j);
				//解析生成当前区域内的原始方案
				deserializeXML(sourceXML,null);
			}
		}
		
		override protected function doDeserializeComplete(vo:CBaseObject3DVO):void
		{
			if(vo is CParamPlanVO)
			{
				var dir:CVector=_curWallVo.direction.clone() as CVector;
				var toward:CVector=CVector.CrossValue(dir,CVector.Z_AXIS);
				var zAixs:CVector=CVector.Z_AXIS.clone() as CVector;
				CVector.Scale(dir,-_curWallVo.length*.5+vo.offLeft+vo.length*.5);
				CVector.Scale(toward,_curWallVo.width+vo.offBack+2);
				CVector.Scale(zAixs,-_curWallVo.height*.5+vo.offGround+vo.height*.5);
				vo.x=_curWallVo.x+dir.x+toward.x+zAixs.x;
				vo.y=_curWallVo.y+dir.y+toward.y+zAixs.y;
				vo.z=_curWallVo.z+dir.z+toward.z+zAixs.z;
				vo.rotationLength=_curWallVo.rotationLength;
				vo.rotationWidth=_curWallVo.rotationWidth;
				vo.rotationHeight=_curWallVo.rotationHeight;
				_planRenderVos.push(vo);
			}
			else if(vo is CBaseTaskObject3DVO)
			{
				addTask(vo as CBaseTaskObject3DVO)
				doAddPlanTask(vo);
			}
		}
		public function excuteDataCollection():Boolean
		{
			if(!isLoadEnd || allPlanDatas==null || allPlanDatas.size==0) return false;
			if(invalidPlanRenderData)
			{
				invalidPlanRenderData=false;
				doCollectPlanRenderDatas();
			}
			return canLoad;
		}
		override public function clearAll():void
		{
			super.clearAll();
			for each(var planVo:CParamPlanVO in _planRenderVos)
			{
				planVo.clear();
			}
			_planRenderVos.length=0;
			allPlanDatas=null;
			_curWallVo=null;
		}
	}
}