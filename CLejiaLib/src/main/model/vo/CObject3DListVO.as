package main.model.vo
{
	import cloud.core.datas.base.CVector;
	import cloud.core.interfaces.ICObject3DList;
	
	import main.model.vo.task.CBaseTaskObject3DVO;
	import main.model.vo.task.CObject3DVO;
	
	import ns.cloudLib;
	
	use namespace cloudLib;
	/**
	 *  家具链表数据类
	 * @author cloud
	 */
	public class CObject3DListVO extends CObject3DVO implements ICObject3DList
	{
		private var _startPos:CVector;
		private var _endPos:CVector;

		public function get endPos():CVector
		{
			return _endPos;
		}
		
		public function set endPos(value:CVector):void
		{
			if(value!=null)
				CVector.Copy(_endPos,value);
			else
				CVector.Copy(_endPos,CVector.ZERO);
		}
		
		public function get startPos():CVector
		{
			return _startPos;
		}
		
		public function set startPos(value:CVector):void
		{
			if(value!=null)
				CVector.Copy(_startPos,value);
			else
				CVector.Copy(_startPos,CVector.ZERO);
		}

		public function CObject3DListVO(clsName:String="CObject3DListVO")
		{
			super(clsName);
			_startPos=CVector.CreateOneInstance();
			_endPos=CVector.CreateOneInstance();
		}

		override public function toString():String
		{
			return super.toString()+"startPos:"+_startPos+" "+"endPos:"+_endPos+"\n";
		}
		
		override public function clone():CBaseTaskObject3DVO
		{
			var clone:CObject3DListVO=super.clone() as CObject3DListVO;
			clone.startPos=startPos;
			clone.endPos=endPos;
			return clone;
		}
		
		override public function clear():void
		{
			super.clear();
			_startPos.back();
			_endPos.back();
			_startPos=null;
			_endPos=null;
		}
	}
}