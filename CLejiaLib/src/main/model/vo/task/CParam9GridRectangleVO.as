package main.model.vo.task
{
	import flash.geom.Vector3D;
	
	import cloud.core.datas.base.CVector;
	import cloud.core.datas.containers.CVectorContainer;
	import cloud.core.utils.CVectorUtil;

	/**
	 * 参数化9宫格矩形区域任务数据类
	 * @author cloud
	 */
	public class CParam9GridRectangleVO extends CParamRectangleVO
	{
		protected var _leftLinePath:CVectorContainer;
		protected var _rightLinePath:CVectorContainer;
		protected var _topLinePath:CVectorContainer;
		protected var _bottomLinePath:CVectorContainer;
		
		public function get leftLinePath():CVectorContainer
		{
			return _leftLinePath;
		}
		public function get rightLinePath():CVectorContainer
		{
			return _rightLinePath;
		}
		public function get topLinePath():CVectorContainer
		{
			return _topLinePath;
		}
		public function get bottomLinePath():CVectorContainer
		{
			return _bottomLinePath;
		}
		
		public function CParam9GridRectangleVO(clsType:String="CParam9GridRectangleVO")
		{
			super(clsType);
			_leftLinePath=CVectorContainer.CreateOneInstance();
			_rightLinePath=CVectorContainer.CreateOneInstance();
			_topLinePath=CVectorContainer.CreateOneInstance();
			_bottomLinePath=CVectorContainer.CreateOneInstance();
		}
		protected function doDeserializeComplete():void
		{
			var dir:CVector;
			var start:CVector;
			var end:CVector;
			var pos:CVector;
			dir=CVector.CreateOneInstance();
			pos=CVector.CreateOneInstance();
			start=CVector.CreateOneInstance();
			end=CVector.CreateOneInstance();
			CVectorUtil.Instance.calculateDirectionByRotation(globalRotation.z,dir);
			if(parent)
				localToGlobal(CVector.ZERO,pos);
			else
				CVector.Copy(pos,position);
			CVector.Scale(dir,realLength*.5);
			CVector.SetTo(start,pos.x-dir.x,pos.y-dir.y,pos.z-dir.z-realHeight*.5+bottomHeight);
			CVector.SetTo(end,pos.x-dir.x,pos.y-dir.y,pos.z-dir.z+realHeight*.5-cornerHeight);
			_leftLinePath.add(new Vector3D(start.x,start.y,start.z-bottomHeight));
			_leftLinePath.add(start);
			_leftLinePath.add(end);
			_leftLinePath.add(new Vector3D(end.x,end.y,end.z+cornerHeight));
			CVector.SetTo(start,pos.x+dir.x,pos.y+dir.y,pos.z+dir.z+realHeight*.5-cornerHeight);
			CVector.SetTo(end,pos.x+dir.x,pos.y+dir.y,pos.z+dir.z-realHeight*.5+bottomHeight);
			_rightLinePath.add(new Vector3D(start.x,start.y,start.z+cornerHeight));
			_rightLinePath.add(start);
			_rightLinePath.add(end);
			_rightLinePath.add(new Vector3D(end.x,end.y,end.z-bottomHeight));
			CVector.Normalize(dir);
			CVector.Scale(dir,realLength*.5-cornerLength);
			CVector.SetTo(start,pos.x-dir.x,pos.y-dir.y,pos.z-dir.z+realHeight*.5);
			CVector.SetTo(end,pos.x+dir.x,pos.y+dir.y,pos.z+dir.z+realHeight*.5);
			_topLinePath.add(new Vector3D(start.x-dir.x,start.y-dir.y,start.z-dir.z));
			_topLinePath.add(start);
			_topLinePath.add(end);
			_topLinePath.add(new Vector3D(end.x+dir.x,end.y+dir.y,end.z+dir.z));
			CVector.SetTo(start,pos.x+dir.x,pos.y+dir.y,pos.z+dir.z-realHeight*.5);
			CVector.SetTo(end,pos.x-dir.x,pos.y-dir.y,pos.z-dir.z-realHeight*.5);
			_bottomLinePath.add(new Vector3D(start.x+dir.x,start.y+dir.y,start.z+dir.z));
			_bottomLinePath.add(start);
			_bottomLinePath.add(end);
			_bottomLinePath.add(new Vector3D(end.x-dir.x,end.y-dir.y,end.z-dir.z));
			
			dir.back();
			pos.back();
			start.back();
			end.back();
		}
		override public function deserialize(source:*):void
		{
			super.deserialize(source);
			doDeserializeComplete();
		}
		
	}
}