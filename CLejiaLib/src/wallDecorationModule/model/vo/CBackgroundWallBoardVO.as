package wallDecorationModule.model.vo
{
	import flash.geom.Vector3D;
	
	import cloud.core.datas.base.CVector;
	
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CParamRectangleVO;
	
	/**
	 * 背景墙边框数据类
	 * @author cloud
	 */
	public class CBackgroundWallBoardVO extends CParamRectangleVO
	{		
		public var inlineLength:Number;
		public var inlineHeight:Number;
		
		public function CBackgroundWallBoardVO(clsType:String)
		{
			super(clsType);
		}
		
		override protected function doDeserializeXML(xml:XML):void
		{
			super.doDeserializeXML(xml);
			inlineLength=Number(xml.@inlineLength);
			inlineHeight=Number(xml.@inlineHeight);
		}
		override protected function doCreateLoftingPaths(loftingAxis:CVector,towardAxis:CVector,paths:Array):void
		{
			if(inlineLength!=0)
			{
				paths.push(new Vector3D(-realLength*.5,0,-realHeight*.5));
				paths.push(new Vector3D(-inlineLength*.5,0,-realHeight*.5),new Vector3D(-inlineLength*.5,0,-realHeight*.5+inlineHeight),new Vector3D(inlineLength*.5,0,-realHeight*.5+inlineHeight),new Vector3D(inlineLength*.5,0,-realHeight*.5));
				paths.push(new Vector3D(realLength*.5,0,-realHeight*.5),new Vector3D(realLength*.5,0,realHeight*.5),new Vector3D(-realLength*.5,0,realHeight*.5));
			}
			else
			{
				paths.push(new Vector3D(-realLength*.5,0,-realHeight*.5),new Vector3D(realLength*.5,0,-realHeight*.5),new Vector3D(realLength*.5,0,realHeight*.5),new Vector3D(-realLength*.5,0,realHeight*.5));
			}
			
		}
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CBackgroundWallBoardVO=super.clone() as CBackgroundWallBoardVO;
			clone.inlineLength=inlineLength;
			clone.inlineHeight=inlineHeight;
			return clone;
		}
	}
}