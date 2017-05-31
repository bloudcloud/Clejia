package wallDecorationModule.interfaces
{
	import flash.geom.Point;
	
	import alternativa.engine3d.objects.Mesh;
	
	import main.extension.CTextureMaterial;
	import main.model.vo.CWallVO;

	/**
	 * 
	 * @author cloud
	 */
	public interface ICClapboardDecorationModule extends ICDecorationModule
	{
		function get curLength():Number;
		function get curHeight():Number;
		function get curFloorHeight():Number;
//		function get curSpacing():Number;
		/**
		 * 选中的模型的code 
		 * @return String
		 * 
		 */		
		function get selectMesh():Mesh;
		/**
		 * 设置护墙板xml计划数据集合 
		 * @param datas
		 * 
		 */		
		function setXmlPlanDatas(datas:Array):void;
		/**
		 * 获取缓存的应用于墙体的xml方案数据,数组索引为2D模式下的墙体数组对象的索引
		 * @return Array
		 * 
		 */		
		/**
		 * 设置单元件方案 
		 * @param xml	单元件方案
		 * 
		 */		
		function setUnitPlan(xml:XML):void;
		/**
		 * 设置护墙板渲染计划数据集合 
		 * 
		 */		
		function setRenderPlanData(roomIndex:int=-1):void;
		/**
		 * 设置渲染回掉函数,开始渲染  
		 * @param renderCallback	渲染回调函数，参数为L3DMesh对象
		 * 
		 */				
		function setRenderCallback(renderCallback:Function):void;
		/**
		 * 获取墙体数据  
		 * @param pointA
		 * @param pointB
		 * @return CWallVO
		 * 
		 */		
		function getWallData(pointA:Point,pointB:Point):CWallVO;
		/**
		 * 执行更换纹理操作 
		 * @param TextureMaterial
		 * 
		 */		
		function excuteChangeMaterial(material:CTextureMaterial):void;
		/**
		 * 执行更换模型样式操作 
		 * @param mesh
		 * 
		 */		
		function excuteChangeMesh(mesh:L3DMesh):void;
		/**
		 * 执行更新护墙板显示操作  
		 * @param length
		 * @param height
		 * @param floorHeight
		 * @param spacing
		 * @return Boolean
		 */		
		function updateClapboardView(length:Number,height:Number,floorHeight:Number,spacing:Number=0):Boolean
		/**
		 * 执行鼠标按下事件 
		 * 
		 */		
		function excuteMouseDown(mesh:Mesh):void;
		/**
		 * 执行鼠标释放事件 
		 * 
		 */		
		function excuteMouseUp(mesh:Mesh):void;
		/**
		 * 清除数据 
		 * 
		 */		
		function clearData():void;
		/**
		 * 清除所有装修 
		 * 
		 */		
		function clearAll():void;
		/**
		 * 添加模块事件监听
		 * @param type	事件类型
		 * @param func		事件回调函数处理
		 * 
		 */		
		function addEventListener(type:String,func:Function):void;
		/**
		 * 移除事件监听 
		 * @param type	事件类型
		 * @param func		事件监听回调函数
		 * 
		 */	
		function removeEventListener(type:String,func:Function):void;
		/**
		 * 移除装饰模型 
		 * @param mesh
		 * 
		 */		
		function removeDecorationMesh(mesh:L3DMesh):void;
		/**
		 * 创建并且设置3D对象数据 
		 * @param type
		 * @param uniqueID
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
		function createAndSetObject3DVO(type:uint,uniqueID:String,parentID:String,length:Number,width:Number,height:Number,x:Number,y:Number,z:Number,rotation:Number):void;
		/**
		 * 使用计划方案数据  
		 * @return 返回是否需要加载
		 * 
		 */			
		function usePlanDatas():Boolean;
	}
}