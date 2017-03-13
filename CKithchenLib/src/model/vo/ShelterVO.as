package model.vo
{
	/**
	 *  
	 * @author cloud
	 */
	public class ShelterVO extends BaseFurnitureVO
	{
		public var rotation:Number;
		
		public function ShelterVO()
		{
			super();
		}
		
		override public function toString():String
		{
			return super.toString()+" rotation:"+rotation+"\n";
		}
	}
}