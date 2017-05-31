package wallDecorationModule
{
	import flash.display.Stage3D;
	
	import main.dict.Object3DDict;
	import main.model.vo.task.ITaskVO;
	
	import wallDecorationModule.interfaces.ICWaistDecorationModule;
	import wallDecorationModule.model.vo.CDecorationTaskVO;
	import wallDecorationModule.service.CWaistDecorationService;
	
	/**
	 * 装修模块接口实现类
	 * @author cloud
	 */
	public class CWaistDecorationModuleImp implements ICWaistDecorationModule
	{
		private var _isRunning:Boolean;
		private var _waistService:CWaistDecorationService;
		   
		public function CWaistDecorationModuleImp()
		{
			_waistService=new CWaistDecorationService();
		}
		
		public function addObject3DData(uniqueID:String,type:uint,parentID:String,length:Number,width:Number,height:Number,x:Number,y:Number,z:Number,rotation:Number):void
		{
			CONFIG::isDecoration
				{
					switch(type)
					{
						case Object3DDict.OBJECT3D_WAIST:
							_waistService.addObject3DData(uniqueID,type,parentID,length,width,height,x,y,z,rotation);
							break;
					}
				}
		}
		
		public function addDecorationTask(taskVo:ITaskVO):void
		{
			CONFIG::isDecoration
				{
					if(!_isRunning)
						start();
					if(taskVo is CDecorationTaskVO)
					{
						_waistService.addDecorationTask(taskVo as CDecorationTaskVO);
					}
				}
		}
		public function excuteTask():Boolean
		{
			CONFIG::isDecoration
				{
					return _waistService.excuteTaskLoad();
				}
				return false;
		}
		public function initDecorationModule(stage3d:Stage3D):void
		{
			_waistService.initDecoration(stage3d);
		}
		public function get isRunning():Boolean
		{
			CONFIG::isDecoration
				{
					return _isRunning;
				}
			return false;
		}
		public function start():void
		{
			CONFIG::isDecoration
				{
					if(!_isRunning)
					{
						_isRunning=true;
						_waistService.start();
					}
				}
		}
		public function stop():void
		{
			CONFIG::isDecoration
				{
					if(_isRunning)
					{
						_isRunning=false;
						_waistService.stop();
					}
				}
		}
		public function updateByFrame(startTime:Number=0,frameTime:Number=0):void
		{
			CONFIG::isDecoration
				{
					if(_waistService.isRunning)
						_waistService.updateByFrame(startTime,frameTime);
				}
		}
	}
}