package rl2.extension
{
	/**
	 *  rl2扩展模块接口
	 * @author cloud
	 */	
	public interface IRL2Module
	{
		/**
		 * 添加场景物体 
		 * @param entity
		 * 
		 */		
		function addView(entity:Object):void;
		/**
		 * 移除场景物体 
		 * @param entity
		 * 
		 */		
		function removeView(entity:Object):void;
	}
}