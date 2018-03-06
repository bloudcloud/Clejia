package wallDecorationModule.interfaces
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage3D;
	
	import cloud.core.datas.maps.CHashMap;
	import cloud.core.interfaces.ICStatus;
	
	/**
	 *  装修模块接口
	 * @author cloud
	 */
	public interface ICDecorationModule extends ICStatus
	{
		/**
		 * 获取当前模块的2D界面是否需要更新
		 * @return Boolean
		 * 
		 */		
		function get invalidView2D():Boolean;
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
		 * 初始化装修模块 
		 * @param gMain	主项目显示容器
		 * @param stage3d	3D舞台
		 * 
		 */		
		function initModule(gMain:DisplayObjectContainer,stage3d:Stage3D):void;
		/**
		 * 显示2D界面 
		 * @param holes	房间的墙面遮挡区域数组
		 * @param points	房间的围点数组
		 * 
		 */		
		function showView2D(holes:Array,points:Array,confirmCallback:Function,title:String=""):void;
		/**
		 * 关闭2D界面 
		 * @param isSaveData	是否保存数据，若为true，保存界面操作的数据
		 * 
		 */		
		function closeView2D(isSaveData:Boolean=false):void;
		/**
		 * 显示3D场景  
		 * @param loadAllCompleteCallback	当前模块下载层结束时回调 
		 * @param renderMeshCallback 当前模块进入渲染层时回调
		 * @param allPlanRenderDatas
		 * @return Boolean
		 * 
		 */		
		function showView3D(loadAllCompleteCallback:Function,renderMeshCallback:Function,allPlanRenderDatas:CHashMap=null):Boolean;
		/**
		 * 关闭3D界面 
		 * 
		 */		
		function closeView3D():void;
		/**
		 * 执行任务
		 * 
		 */		
		function excuteDecoration():void;
		/**
		 * 移除装饰模型数据
		 * @param mesh
		 * 
		 */		
		function removeDecorationMeshData(mesh:L3DMesh):void;
		/**
		 * 添加监听 
		 * @param type
		 * @param func
		 * 
		 */		
		function addEventListener(type:String,func:Function):void;
		/**
		 * 移除监听 
		 * @param type
		 * @param func
		 * 
		 */		
		function removeEventListener(type:String,func:Function):void;
		/**
		 *  清空模块服务
		 * 
		 */		
		function clear():void;
		/**
		 * 序列化 
		 * @param source
		 * @return *
		 * 
		 */		
		function serialize(mode:String):*;
		/**
		 * 反序列化 
		 * @param source
		 * 
		 */		
		function deserialize(source:*):void;
	}
}