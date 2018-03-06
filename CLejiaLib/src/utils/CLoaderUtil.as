package utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import L3DLibrary.L3DLibrary;
	import L3DLibrary.L3DLibraryWebService;
	
	import cloud.core.events.CDataEvent;
	import cloud.core.events.CEventDispatcher;
	
	import main.dict.EventTypeDict;

	/**
	 *  下载器工具类
	 * @author cloud
	 * 
	 */	
	public class CLoaderUtil
	{
		/**
		 * 排料请求 
		 */		
		public static const REQUEST_NESTING:String = "nestingRequest";
		
		private static const _Instance:CLoaderUtil=new CLoaderUtil();
		public static function get Instance():CLoaderUtil
		{
			return _Instance;
		}
		
		private var _loadCount:int;
		private var _urlLoader:URLLoader;
		private var _curUrl:String;
		private var _dispatcher:CEventDispatcher;
		private var _paths:Vector.<String>;
		private var _isLoading:Boolean;
		
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
		public function get dispatcher():CEventDispatcher
		{
			return _dispatcher ||= new CEventDispatcher();
		}
		
		public function CLoaderUtil()
		{
			_paths=new Vector.<String>();
			_urlLoader=new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE,loadCompleteHandler);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
		}
		private function loadCompleteHandler(evt:Event):void
		{
			_loadCount=0;
			if(_paths.length>0)
			{
				_urlLoader.load(new URLRequest(_paths.pop()));
				if(dispatcher.hasEventListener(EventTypeDict.EVENT_LOADCOMPLETE))
					dispatcher.dispatchEvent(new CDataEvent(EventTypeDict.EVENT_LOADCOMPLETE,evt.target.data));
			}
			else
			{
				_isLoading=false;
				if(dispatcher.hasEventListener(EventTypeDict.EVENT_LOADCOMPLETE))
					dispatcher.dispatchEvent(new CDataEvent(EventTypeDict.EVENT_LOADCOMPLETE,evt.target.data));
				if(dispatcher.hasEventListener(EventTypeDict.EVENT_LOADALLCOMPLETE))
					dispatcher.dispatchEvent(new CDataEvent(EventTypeDict.EVENT_LOADALLCOMPLETE,evt.target.data));
			}
		}
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			_loadCount++;
			if(_loadCount<3)
			{
				_urlLoader.load(new URLRequest(_curUrl));
			}
			else
			{
				if(dispatcher.hasEventListener(EventTypeDict.EVENT_LOADERROR))
					dispatcher.dispatchEvent(new CDataEvent(EventTypeDict.EVENT_LOADERROR,evt.errorID+": "+evt.text));
			}
		}
		/**
		 * 开始一个urlloader的加载任务 
		 * @param url
		 * @param dataFormat
		 * @param isNewLoader
		 * 
		 */
		public function startURLLoad(url:String,dataFormat:String=URLLoaderDataFormat.TEXT,isNewLoader:Boolean=false):void
		{
			if(_paths.indexOf(url)>=0) return;
			if(_isLoading)
			{
				_paths.push(url);
			}
			else
			{
				_isLoading=true;
				_curUrl=url;
				_urlLoader.load(new URLRequest(url));
			}
		}
		/**
		 * 开启一个RPC请求 
		 * @param type	请求类型
		 * @param source 请求数据对象
		 * 
		 */		
		public function startRPCRequest(type:String,source:*):void
		{
			var atObj:AsyncToken;
			var rpObj:mx.rpc.Responder;
			switch(type)
			{
				case REQUEST_NESTING:
					atObj=L3DLibraryWebService.LibraryService.TileCS(XML(source).toXMLString());
					rpObj=new mx.rpc.Responder(tileCSResultHandler, tileCSFaultHandler);
					break;
			}
			atObj.addResponder(rpObj);
		}
		/**
		 * 排料请求成功的处理 
		 * @param reObj
		 * 
		 */		
		private function tileCSResultHandler(evt:ResultEvent):void
		{
//			var xml:XML = XML(evt.result);
//			if(xml == null) return;
//			var xmlList:XMLList = xml.children();
//			var yuliaoArray:Array = [];
//			if( xmlList && xmlList.length > 0)
//			{
//				for( var i:int = 0 ; i < xmlList.length ; i ++ )
//				{
//					tempXML = xmlList[i];
//					yuliaoArray.push(tempXML.@TextureNo);
//				}
//			}
//			
//			for( var j:int = 0 ; j < yuliaoArray.length ; j ++ )
//			{
//				var textureNo:String = yuliaoArray[j];
//				for( var k:int = 0 ; k < textureNoToCodeArray.length ; k ++ )
//				{
//					if( textureNo == String(textureNoToCodeArray[k].textureNo) )
//					{
//						textureNoToCodeArray[k].count = int(textureNoToCodeArray[k].count) + 1;
//					}
//				}
//			}
//			if(!_cutWin){
//				_cutWin = new TileCut;
//			}
//			_cutWin.setup(recodeCutTileArray,textureNoToCodeArray);
//			_cutWin.addEventListener("CLOSE_REPORT_WIN",clearTxt);
//			PopUpManager.addPopUp(_cutWin,parentWnd==null?(FlexGlobals.topLevelApplication as DisplayObject):parentWnd);
		}
		private function tileCSFaultHandler(evt:FaultEvent):void
		{
			L3DLibrary.L3DLibrary.ShowMessage(evt.fault.toString(), 1);
		}
	}
}