package main.model
{
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.mvcs.model.paramVos.CBaseObject3DVO;
	
	import main.dict.CParamDict;
	import main.model.vo.task.CBaseTaskObject3DVO;

	/**
	 *  装修数据模型类
	 * @author cloud
	 * 
	 */	
	public class CDecorationModel extends TaskDataModel
	{
		private var _invalidPlanRenderData:Boolean;
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
		private var _className:String;
		
		protected var _moduleType:uint;
		
		public function get invalidPlanRenderData():Boolean
		{
			return _invalidPlanRenderData;
		}
		public function set invalidPlanRenderData(value:Boolean):void
		{
			_invalidPlanRenderData=value;
		}
		public function get className():String
		{
			return _className;
		}
		
		public function CDecorationModel(clsName:String)
		{
			super();
			_className=clsName;
		}
		/**
		 * 添加计划任务数据 
		 * @param taskVo
		 * 
		 */		
		protected function doAddPlanTask(parentVo:ICObject3D):void
		{
			var child:CBaseTaskObject3DVO;
			for(child=parentVo.children as CBaseTaskObject3DVO; child!=null; child=child.next as CBaseTaskObject3DVO)
			{
				if(child==null) continue;
				addTask(child);
				doAddPlanTask(child);
			}
		}
		/**
		 * 解析完成后的处理 
		 * 
		 */		
		protected function doDeserializeComplete(vo:CBaseObject3DVO):void
		{
		}
		/**
		 * 反序列化 
		 * @param xml
		 * 
		 */		
		public function deserializeXML(source:XML,parent:ICObject3D):void
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
				doDeserializeComplete(vo);
				deserializeXML(xmlList[i],vo);
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
	}
}