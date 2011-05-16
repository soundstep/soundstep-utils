package {

	import com.bit101.charts.BarChart;
	import com.bit101.charts.LineChart;
	import com.bit101.components.CheckBox;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.HUISlider;
	import com.bit101.components.IndicatorLight;
	import com.bit101.components.InputText;
	import com.bit101.components.Knob;
	import com.bit101.components.Label;
	import com.bit101.components.Meter;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.Text;
	import com.bit101.components.TextArea;
	import com.bit101.components.VBox;
	import com.bit101.components.VUISlider;
	import com.bit101.components.Window;
	import com.bit101.utils.MinimalConfigurator;
	import com.soundstep.utils.BinderUI;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;


	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	
	public class MainBinderUI extends Sprite {

		public var config:MinimalConfigurator;

		public function MainBinderUI() {
			
			stage.frameRate = 31;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			buildInterface();
			bindInterface();
		}

		private function buildInterface():void {
				var xml:XML = <comps>
				<Window id="window" title="Debug Panel" x="5" y="5" hasMinimizeButton="true">
					<Knob id="knobX" x="150" y="45"/>
					<Knob id="knobY" x="200" y="45"/>
					<HBox x="5" y="5">
						<VBox>
							<InputText id="inputX" width="40"/>
							<InputText id="inputY" width="40"/>
							<ColorChooser id="color"/>
							<CheckBox id="halfTransparent" label="half transparent"/>
							<IndicatorLight id="indicator" label="indicator half transparent"/>
							<NumericStepper id="stepX"/>
							<NumericStepper id="stepY"/>
						</VBox>
						<VBox>
							<Label id="labelX" width="40"/>
							<Label id="labelY" width="40"/>
						</VBox>
						<VBox>
							<HUISlider id="sliderHX"/>
							<HUISlider id="sliderHY"/>
						</VBox>
						<HBox spacing="10">
							<VUISlider id="sliderVX"/>
							<VUISlider id="sliderVY"/>
						</HBox>
						<HBox>
							<VBox>
								<HBox>
									<TextArea id="textareaX" width="140" height="70"/>
									<TextArea id="textareaY" width="140" height="70"/>
								</HBox>
								<HBox>
									<Meter id="meterX" width="140" height="70"/>
									<Meter id="meterY" width="140" height="70"/>
								</HBox>
							</VBox>
							<VBox id="box1"/>
							<VBox id="box2"/>
						</HBox>
					</HBox>
				</Window>
			</comps>;
			
			config = new MinimalConfigurator(this);
			config.parseXML(xml);
			
			var window:Window = config.getCompById("window") as Window;
			window.width = stage.stageWidth - 10;
			window.height = 180;
		}

		private function bindInterface():void {
			var s:Square = new Square();
			s.x = (stage.stageWidth - s.width) >> 1;
			s.y = (stage.stageHeight - s.height) >> 1;
			
			var box1:VBox = config.getCompById("box1") as VBox;
			var box2:VBox = config.getCompById("box2") as VBox;
			
			BinderUI.displayLabel(this, s, "x", config.getCompById("labelX") as Label);
			BinderUI.displayLabel(this, s, "y", config.getCompById("labelY") as Label);
			
			BinderUI.displayColorChooser(this, s, "color", config.getCompById("color") as ColorChooser);
			
			BinderUI.displayCheckBox(this, s, "halfTransparent", null, config.getCompById("halfTransparent") as CheckBox);
			BinderUI.displayIndicatorLight(this, s, "halfTransparent", null, config.getCompById("indicator") as IndicatorLight);
			
			BinderUI.displayNumericStepper(this, s, "x", 5, config.getCompById("stepX") as NumericStepper, 0, stage.stageWidth - s.width, 1);
			BinderUI.displayNumericStepper(this, s, "y", 5, config.getCompById("stepY") as NumericStepper, 0, stage.stageHeight - s.height, 1);
			
			BinderUI.displayInput(this, s, "x", config.getCompById("inputX") as InputText);
			BinderUI.displayInput(this, s, "y", config.getCompById("inputY") as InputText);
			
			BinderUI.displaySliderHorizontal(this, s, "x", "x", config.getCompById("sliderHX") as HUISlider, 0.1, 1, 0, stage.stageWidth - s.width);
			BinderUI.displaySliderHorizontal(this, s, "y", "y", config.getCompById("sliderHY") as HUISlider, 0.1, 1, 0, stage.stageHeight - s.height);
			
			BinderUI.displaySliderVertical(this, s, "x", "x", config.getCompById("sliderVX") as VUISlider, 0.1, 1, 0, stage.stageWidth - s.width);
			BinderUI.displaySliderVertical(this, s, "y", "y", config.getCompById("sliderVY") as VUISlider, 0.1, 1, 0, stage.stageHeight - s.height);
			
			BinderUI.displayTextarea(this, s, "x", config.getCompById("textareaX") as TextArea);
			BinderUI.displayTextarea(this, s, "y", config.getCompById("textareaY") as TextArea);
			
			BinderUI.displayKnob(this, s, "x", "x", config.getCompById("knobX") as Knob, Knob.VERTICAL, 20, 0, stage.stageWidth - s.width);
			BinderUI.displayKnob(this, s, "y", "y", config.getCompById("knobY") as Knob, Knob.VERTICAL, 20, 0, stage.stageHeight - s.height);
			
			BinderUI.displayMeter(this, s, "x", "x", config.getCompById("meterX") as Meter, 0, stage.stageWidth - s.width);
			BinderUI.displayMeter(this, s, "y", "y", config.getCompById("meterY") as Meter, 0, stage.stageHeight - s.height);
			
			var barChartX:BarChart = box1.addChild(BinderUI.displayBarChart(this, s, "x", 20, null, false, 0, stage.stageWidth - s.width, 0, false, false)) as BarChart;
			barChartX.width = 140;
			barChartX.height = 60;
			var barChartY:BarChart = box1.addChild(BinderUI.displayBarChart(this, s, "y", 20, null, false, 0, stage.stageHeight - s.height, 0, false, false)) as BarChart;
			barChartY.width = 140;
			barChartY.height = 60;
			
			var lineChartX:LineChart = box2.addChild(BinderUI.displayLineChart(this, s, "x", 150, null, false, 0, stage.stageWidth - s.width, 0, false, false)) as LineChart;
			lineChartX.width = 140;
			lineChartX.height = 60;
			lineChartX.x = -55;
			var lineChartY:LineChart = box2.addChild(BinderUI.displayLineChart(this, s, "y", 150, null, false, 0, stage.stageHeight - s.height, 0, false, false)) as LineChart;
			lineChartY.width = 140;
			lineChartY.height = 60;
			lineChartY.x = -55;
			
			addInfo();
			
			addChild(s);
			
//			EasyDebugUI.disposeByTarget(s);
//			EasyDebugUI.disposeByComponent(c2)
//			EasyDebugUI.dispose();
		}

		private function addInfo():void {
			new Label(this, 10, stage.stageHeight - 25, "Drag the square");
			var str:String = "";
			str += 'BinderUI.displayLabel(this, s, "x")\n';
			str += 'BinderUI.displayColorChooser(this, sprite, "color");\n';
			str += 'BinderUI.displayCheckBox(this, sprite, "halfTransparent", "half transparent");\n';
			str += 'BinderUI.displayIndicatorLight(this, sprite, "halfTransparent", "half transparent");\n';
			str += 'BinderUI.displayNumericStepper(this, sprite, "x", 5, null, 0, 900, 1);\n';
			str += 'BinderUI.displayInput(this, sprite, "x");\n';
			str += 'BinderUI.displaySliderHorizontal(this, sprite, "x", "x", null, 0.1, 1, 0, 900);\n';
			str += 'BinderUI.displaySliderVertical(this, sprite, "x", "x", null, 0.1, 1, 0, 900);\n';
			str += 'BinderUI.displayTextarea(this, sprite, "x");\n';
			str += 'BinderUI.displayKnob(this, sprite, "x", "x", null, Knob.VERTICAL, 20, 0, 900);\n';
			str += 'BinderUI.displayMeter(this, sprite, "x", "x", null, 0, 900);\n';
			var text:Text = new Text(this, stage.stageWidth - 390, stage.stageHeight - 180, str);
			text.width = 380;
			text.height = 170;
			text.editable = false;
		}

	}
}
