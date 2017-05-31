package main.model.vo
{
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	
	import cloud.core.interfaces.ICData;
	import cloud.core.interfaces.ICObject3D;
	import cloud.core.interfaces.ICObject3DList;
	import cloud.core.singleton.CVector3DUtil;
	
	import kitchenModule.model.KitchenErrorModel;
	
	import ns.cloudLib;
	
	use namespace cloudLib;
	/**
	 *  家具链表数据类
	 * @author cloud
	 */
	public class CObject3DListVO extends CObject3DVO implements ICObject3DList
	{
		private var _startPos:Vector3D;
		private var _endPos:Vector3D;

		public function get endPos():Vector3D
		{
			return _endPos;
		}
		
		public function set endPos(value:Vector3D):void
		{
			if(value!=null)
				_endPos.copyFrom(value);
			else
				_endPos.copyFrom(CVector3DUtil.ZERO);
		}
		
		public function get startPos():Vector3D
		{
			return _startPos;
		}
		
		public function set startPos(value:Vector3D):void
		{
			if(value!=null)
				_startPos.copyFrom(value);
			else
				_startPos.copyFrom(CVector3DUtil.ZERO);
		}

		public function CObject3DListVO()
		{
			super();
			_startPos=new Vector3D();
			_endPos=new Vector3D();
		}
	
		override public function update(value:*):void
		{
			super.update(value);
			startPos=value.headPos;
			endPos=value.endPos;
		}
		
		override public function compare(source:ICData):Number
		{
			var distance:Number;
			var vo:ICObject3D=source as ICObject3D;
			if(vo)
			{
				var vec:Vector3D=this.position.subtract(vo.position);
				distance=vec.dotProduct(vo.direction)>0 ? vec.length : vec.length*-1;
			}
			else
				KitchenErrorModel.instance.throwErrorByMessage("CObject3DListVO","compare"," vo",String(getQualifiedClassName(vo)+" 参数不是双向链表数据类型！"));
			return distance;
		}
		
		override public function toString():String
		{
			return super.toString()+"startPos:"+_startPos+" "+"endPos:"+_endPos+"\n";
		}
		
		override public function clone():CObject3DVO
		{
			var vo:CObject3DListVO=new CObject3DListVO();
			vo.uniqueID=this.uniqueID;
			vo.type=this.type;
			vo.direction=this.direction;
			vo.length=this.length;
			vo.width=this.width;
			vo.height=this.height;
			vo.parentID=this.parentID;
			vo.isLife=this.isLife;
			vo.startPos=this.startPos;
			vo.endPos=this.endPos;
			
			vo.rotation=this.rotation;
			vo.x=this.x;
			vo.y=this.y;
			vo.z=this.z;
			
			return vo;
		}
		
		override public function clear():void
		{
			super.clear();
			_startPos=null;
			_endPos=null;
		}
	}
}