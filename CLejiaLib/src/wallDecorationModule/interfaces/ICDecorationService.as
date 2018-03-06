package wallDecorationModule.interfaces
{
	import flash.display.Stage3D;
	
	import cloud.core.interfaces.ICStatus;
	
	public interface ICDecorationService extends ICStatus
	{
		/**
		 * 获取计划渲染数据是否需要更新
		 * @return Boolean
		 * 
		 */		
		function get invalidPlanRenderData():Boolean;
		/**
		 * 设置计划渲染数据是否需要更新 
		 * @param value
		 * 
		 */		
		function set invalidPlanRenderData(value:Boolean):void;
		/**
		 * 初始化装修服务类 
		 * @param stage3d
		 * 
		 */		
		function initDecorationService(stage3d:Stage3D):void;		
		/**
		 * 添加事件监听 
		 * @param type	事件类型
		 * @param func	事件监听回调函数
		 * 
		 */		
		function addEventListener(type:String,func:Function):void;
		/**
		 * 是否有事件监听 
		 * @param type	事件类型
		 * 
		 */		
		function hasEventListener(type:String):Boolean;
		/**
		 * 移除事件监听 
		 * @param type	事件类型
		 * @param func		事件监听回调函数
		 * 
		 */	
		function removeEventListener(type:String,func:Function):void;
		/**
		 * 执行装修 
		 * 
		 */		
		function excuteDecoration():void;
		/**
		 * 清理数据模型 
		 * 
		 */
		function clearModel():void;
	}
}