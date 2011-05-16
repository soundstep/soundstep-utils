package {

	import test.TimerTests;

	import uk.co.soulwire.gui.SimpleGUI;

	import com.bit101.components.Label;
	import com.soundstep.utils.Time;

	import org.flexunit.internals.TraceListener;
	import org.flexunit.runner.FlexUnitCore;
	import org.fluint.uiImpersonation.VisualTestEnvironmentBuilder;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	public class TestRunner extends Sprite {

		private var core:FlexUnitCore;
		private var _id:String;
		private var _gui:SimpleGUI;

		public function TestRunner() {
			
			stage.frameRate = 31;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			// Launch your unit tests by right clicking within this class and select: Run As > FDT SWF Application
			
			//Instantiate the core.
			core = new FlexUnitCore();
			//This registers the stage with the VisualTestEnvironmentBuilder, which allows you
			//to use the UIImpersonator classes to add to the display list and remove from within your
			//tests. With Flex, this is done for you, but in AS projects it needs to be handled manually.
			VisualTestEnvironmentBuilder.getInstance(this);
			
			//Add any listeners. In this case, the TraceListener has been added to display results.
			core.addListener(new TraceListener());
			
			//There should be only 1 call to run().
			//You can pass a comma separated list (or an array) of tests or suites.
			//You can also pass a Request Object, which allows you to sort, filter and subselect.
			//var request:Request = Request.methods( someClass, ["method1", "method2", "method3"] ).sortWith( someSorter ).filterWith( someFilter );
			//core.run( request );
			//core.run(TimerTests);
			
			buildUI();
			
		}

		private function buildUI():void {
//			var xml:XML = <comps>
//			    <VBox x="10" y="10">
//			        <Label label="create" width="100" event="click:timerHandler"/>
//			        <PushButton label="create" width="100" event="click:timerHandler"/>
//			        <PushButton label="pause" width="100" event="click:timerHandler"/>
//			        <PushButton label="resume" width="100" event="click:timerHandler"/>
//			    </VBox>
//			</comps>;
//			var config:MinimalConfigurator = new MinimalConfigurator(this);
//			config.parseXML(xml);
			_gui = new SimpleGUI(this, "Time Helper", "h");
			_gui.showToggle = true;
			_gui.show();
			_gui.addLabel("Time: 0");
			_gui.addButton("run tests", {callback:timerHandler, callbackParams:["run tests"]});
			_gui.addButton("create", {callback:timerHandler, callbackParams:["create"]});
			_gui.addButton("pause", {callback:timerHandler, callbackParams:["pause"]});
			_gui.addButton("resume", {callback:timerHandler, callbackParams:["resume"]});
		}
		
		private function timerHandler(label:String):void {
			switch (label) {
				case "run tests":
					core.run(TimerTests);
					break;
				case "create":
					_id = Time.call(endTimerHandler, 4000, false);
					addEventListener(Event.ENTER_FRAME, loop);
					break;
				case "pause":
					Time.pause(_id);
					break;
				case "resume":
					Time.resume(_id);
					break;
			}
		}

		private function endTimerHandler():void {
			trace("End");
			removeEventListener(Event.ENTER_FRAME, loop);
		}

		private function loop(event:Event):void {
			var label:Label = _gui.components[1] as Label;
			label.text = "Time: " + Time.getTime(_id).toString();
//			trace(Time.print(_id));
		}
		
	}
}
