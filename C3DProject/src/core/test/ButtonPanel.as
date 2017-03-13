package core.test
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import spark.components.Button;
	
	/**
	 *  
	 * @author cloud
	 */
	public class ButtonPanel extends UIComponent
	{
		public var createTableBoard:Button;
		public var createShelter:Button;
		
		public function ButtonPanel()
		{
			super();
			
//			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		
		private function onAddToStage(evt:Event):void
		{
			createTableBoard=new Button();
			createShelter=new Button();
			
			createTableBoard.left=20;
			createTableBoard.bottom=20;
			createShelter.left=createShelter.width+20;
			createShelter.bottom=20;
			
			this.addChild(createTableBoard);
			this.addChild(createShelter);
		}
	}
}