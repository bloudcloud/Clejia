package cDoorModule.interfaces
{
	import cloud.core.datas.maps.CHashMap;

	public interface ICDoorDecorationModule
	{
		function get planDatasMap():CHashMap;
		/**
		 * 显示预览 
		 * @param roomID
		 * @param wallIndex
		 * @param loadAllCompleteCallback
		 * @param renderMeshCallback
		 * @return 返回显示预览处理是否成功
		 * 
		 */		
		function showPreview(roomID:String,wallIndex:int,loadAllCompleteCallback:Function,renderMeshCallback:Function):Boolean
	}

}