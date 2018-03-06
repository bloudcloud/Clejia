package main.extension
{
	import flash.geom.Rectangle;
	
	public class CRectangle extends Rectangle
	{
		/**
		 * 是否被占用 
		 */		
		public var isHad:Boolean;
		
		public function CRectangle(x:Number=0, y:Number=0, width:Number=0, height:Number=0)
		{
			super(x, y, width, height);
		}
//		override public function intersection(toIntersect:Rectangle):Rectangle
//		{
//			var rect:Rectangle=super.intersection(toIntersect);
//			rect=new CRectangle(rect.x,rect.y,rect.width,rect.height);
//			(rect as CRectangle).isHad=isHad;
//			return rect;
//		}
	}
}