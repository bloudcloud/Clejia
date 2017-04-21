package wallDecorationModule
{
	import flash.display.Stage3D;
	import flash.utils.Dictionary;
	
	import main.model.vo.task.ITaskVO;
	
	import wallDecorationModule.interfaces.ICDecorationModule;
	import wallDecorationModule.model.vo.CDecorationTaskVO;
	import wallDecorationModule.service.CDecorationService;
	
	/**
	 * 装修模块接口实现类
	 * @author cloud
	 */
	public class CDecorationModuleImp implements ICDecorationModule
	{
		private var _taskDic:Dictionary;
		private var _isRunning:Boolean;
		private var _decorationService:CDecorationService;
		
		public function CDecorationModuleImp()
		{
			_decorationService=new CDecorationService();
		}
		public function addObject3DData(uniqueID:String,type:uint,parentID:String,length:Number,width:Number,height:Number,x:Number,y:Number,z:Number,rotation:Number):void
		{
			_decorationService.addObject3DData(uniqueID,type,parentID,length,width,height,x,y,z,rotation);
		}
		
		public function addDecorationTask(taskVo:ITaskVO,stage3d:Stage3D):void
		{
			CONFIG::isDecoration
				{
					if(!_isRunning)
						start();
					if(taskVo is CDecorationTaskVO)
					{
						_decorationService.addDecorationTask(taskVo as CDecorationTaskVO,stage3d);
					}
				}
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
						_decorationService.start();
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
						_decorationService.stop();
					}
				}
		}
		public function updateByFrame(startTime:Number=0,frameTime:Number=0):void
		{
			CONFIG::isDecoration
				{
					if(_decorationService.isRunning)
						_decorationService.updateByFrame(startTime,frameTime);
				}
		}
	}
}