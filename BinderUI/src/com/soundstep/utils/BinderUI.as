package com.soundstep.utils {

	import flash.geom.Transform;
	import flash.geom.ColorTransform;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.Meter;
	import com.bit101.charts.LineChart;
	import com.bit101.components.Knob;
	import com.bit101.components.IndicatorLight;
	import flash.display.DisplayObject;
	import com.bit101.components.ColorChooser;
	import flash.events.MouseEvent;
	import com.bit101.components.CheckBox;
	import com.bit101.charts.BarChart;
	import com.bit101.components.Component;
	import com.bit101.components.HUISlider;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.TextArea;
	import com.bit101.components.UISlider;
	import com.bit101.components.VUISlider;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	[Bindable]
	public class BinderUI {
		
		public static var _components:Dictionary = new Dictionary(true);
		public static var _textarea:Dictionary = new Dictionary(true);
		
		private static function createObjectInfo(target:Object, property:String, container:DisplayObjectContainer, watcher:ChangeWatcher, buffer:int = 100):ObjectInfo {
			var info:ObjectInfo = new ObjectInfo();
			info.target = target;
			info.property = property;
			info.container = container;
			info.watcher = watcher;
			info.buffer = buffer;
			return info;
		}

		private static function removeFromParent(comp:Component):void {
			if (comp.parent.contains(comp)) {
				comp.parent.removeChild(comp);
			}
		}

		private static function disposeDictionaryItem(comp:Component, info:ObjectInfo):void {
			// dispose textarea disctionary
			if (_textarea[info.watcher]) {
				_textarea[info.watcher] = null;
				delete _textarea[info.watcher];
			}
			// dispose object info
			info.dispose();
			// dispose components disctionary
			_components[comp] = null;
			delete _components[comp];
		}

		private static function inputTextHandler(event:Event):void {
			var component:InputText = event.currentTarget as InputText;
			var info:Object = _components[component];
			info.target[info.property] = component.text;
		}
		
		private static function sliderChangeHandler(event:Event):void {
			var component:UISlider = event.currentTarget as UISlider;
			var info:Object = _components[component];
			info.target[info.property] = component.value;
		}

		private static function checkboxHandler(event:MouseEvent):void {
			var component:CheckBox = event.currentTarget as CheckBox;
			var info:Object = _components[component];
			info.target[info.property] = component.selected;
		}

		private static function knobHandler(event:Event):void {
			var component:Knob = event.currentTarget as Knob;
			var info:Object = _components[component];
			info.target[info.property] = component.value;
		}

		private static function getComponentsByType(target:Object, property:Object, type:Class):Array {
			var list:Array = [];
			for (var obj:Object in _components) {
				var comp:Component = obj as Component;
				var info:ObjectInfo = _components[obj];
				if (info.target == target && info.property == property && comp is type) {
					list[list.length] = comp;
				}
			}
			return list;
		}

		private static function textareaLogHandler(event:PropertyChangeEvent):void {
			var components:Array = getComponentsByType(event.source, event.property, TextArea);
			var i:Number = 0;
			var l:Number = components.length;
			for (; i<l; ++i) {
				var comp:TextArea = components[i];
				comp.text = event.property + ": " + event.newValue + " | timestamp: " + getTimer() + "\n"+ comp.text;
			}
		}

		private static function barChartLogHandler(event:PropertyChangeEvent):void {
			var components:Array = getComponentsByType(event.source, event.property, BarChart);
			var i:Number = 0;
			var l:Number = components.length;
			for (; i<l; ++i) {
				var comp:BarChart = components[i];
				var info:ObjectInfo = _components[comp];
				if (!comp.data) comp.data = [0];
				if (comp.data.length > info.buffer) {
					comp.data.shift();
				}
				comp.data[comp.data.length] = event.newValue;
				comp.draw();
			}
		}

		private static function lineChartLogHandler(event:PropertyChangeEvent):void {
			var components:Array = getComponentsByType(event.source, event.property, LineChart);
			var i:Number = 0;
			var l:Number = components.length;
			for (; i<l; ++i) {
				var comp:LineChart = components[i];
				var info:ObjectInfo = _components[comp];
				if (!comp.data) comp.data = [0];
				if (comp.data.length > info.buffer) {
					comp.data.shift();
				}
				comp.data[comp.data.length] = event.newValue;
				comp.draw();
			}
		}

		private static function indicatorLightHandler(event:PropertyChangeEvent):void {
			var components:Array = getComponentsByType(event.source, event.property, IndicatorLight);
			var i:Number = 0;
			var l:Number = components.length;
			for (; i<l; ++i) {
				var comp:IndicatorLight = components[i];
				comp.color = (event.newValue) ? 0x00FF00 : 0;
			}
		}

		private static function colorHandler(event:Event) : void {
			var component:ColorChooser = event.currentTarget as ColorChooser;
			var info:Object = _components[component];
			if (info.target is Transform) {
				var ct:ColorTransform = new ColorTransform();
				ct.blueMultiplier = Transform(info.target).colorTransform.blueMultiplier;
				ct.blueOffset = Transform(info.target).colorTransform.blueOffset;
				ct.greenMultiplier = Transform(info.target).colorTransform.greenMultiplier;
				ct.greenOffset = Transform(info.target).colorTransform.greenOffset;
				ct.redMultiplier = Transform(info.target).colorTransform.redMultiplier;
				ct.redOffset = Transform(info.target).colorTransform.redOffset;
				ct.color = component.value;
				ct.alphaMultiplier = Transform(info.target).colorTransform.alphaMultiplier;
				ct.alphaOffset = Transform(info.target).colorTransform.alphaOffset;
				Transform(info.target).colorTransform = ct;
			}
			else {
				info.target[info.property] = component.value;
			}
		}
		
		private static function meterChangeHandler(event:Event):void {
			var component:UISlider = event.currentTarget as UISlider;
			var info:Object = _components[component];
			info.target[info.property] = component.value;
		}

		private static function numericStepperChangeHandler(event:Event):void {
			var component:NumericStepper = event.currentTarget as NumericStepper;
			var info:Object = _components[component];
			info.target[info.property] = component.value;
		}

		public static function displayLabel(container:DisplayObjectContainer, target:Object, property:String, component:Label = null):Label {
			var comp:Label = (component == null) ? new Label(container, 0, 0) : component;
			var watcher:ChangeWatcher = BindingUtils.bindProperty(comp, "text", target, property);
			watcher.useWeakReference = true;
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function displayTextarea(container:DisplayObjectContainer, target:Object, property:String, component:TextArea = null):TextArea {
			var comp:TextArea = (component == null) ? new TextArea(container, 0, 0) : component;
			var watcher:ChangeWatcher = BindingUtils.bindProperty(new ObjectInfo(), "trash", target, property);
			watcher.useWeakReference = true;
			watcher.setHandler(textareaLogHandler);
			_components[comp] = createObjectInfo(target, property, container, watcher);
			_textarea[watcher] = comp;
			return comp;
		}

		public static function displayInput(container:DisplayObjectContainer, target:Object, property:String, component:InputText = null):InputText {
			var comp:InputText = (component == null) ? new InputText(container, 0, 0) : component;
			comp.addEventListener(Event.CHANGE, inputTextHandler);
			var watcher:ChangeWatcher = BindingUtils.bindProperty(comp, "text", target, property);
			watcher.useWeakReference = true;
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function displaySliderHorizontal(container:DisplayObjectContainer, target:Object, property:String, label:String = null, component:HUISlider = null, tick:Number = NaN, labelPrecision:int = 0, minimumValue:Number = NaN, maximumValue:Number = NaN):HUISlider {
			var comp:HUISlider = (component == null) ? new HUISlider(container, 0, 0, label) : component;
			if (label != null) comp.label = label;
			if (!isNaN(tick)) comp.tick = tick;
			comp.labelPrecision = labelPrecision;
			if (!isNaN(minimumValue)) comp.minimum = minimumValue;
			if (!isNaN(maximumValue)) comp.maximum = maximumValue;
			comp.addEventListener(Event.CHANGE, sliderChangeHandler);
			var watcher:ChangeWatcher = BindingUtils.bindProperty(comp, "value", target, property);
			watcher.useWeakReference = true;
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function displaySliderVertical(container:DisplayObjectContainer, target:Object, property:String, label:String = null, component:VUISlider = null, tick:Number = NaN, labelPrecision:int = 0, minimumValue:Number = NaN, maximumValue:Number = NaN):VUISlider {
			var comp:VUISlider = (component == null) ? new VUISlider(container, 0, 0, label) : component;
			if (label != null) comp.label = label;
			if (!isNaN(tick)) comp.tick = tick;
			comp.labelPrecision = labelPrecision;
			if (!isNaN(minimumValue)) comp.minimum = minimumValue;
			if (!isNaN(maximumValue)) comp.maximum = maximumValue;
			comp.addEventListener(Event.CHANGE, sliderChangeHandler);
			var watcher:ChangeWatcher = BindingUtils.bindProperty(comp, "value", target, property);
			watcher.useWeakReference = true;
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function displayBarChart(container:DisplayObjectContainer, target:Object, property:String, buffer:int = 100, component:BarChart = null, autoScale:Boolean = true, minimumValue:Number = NaN, maximumValue:Number = NaN, labelPrecision:int = 0, showGrid:Boolean = false, showScaleLabels:Boolean = true, spacing:Number = NaN, barColor:uint = 0x999999, gridColor:uint = 0xD0D0D0, gridSize:Number = NaN):BarChart {
			var comp:BarChart = (component == null) ? new BarChart(container, 0, 0) : component;
			comp.autoScale = autoScale;
			if (!isNaN(minimumValue)) comp.minimum = minimumValue;
			if (!isNaN(maximumValue)) comp.maximum = maximumValue;
			if (!isNaN(labelPrecision)) comp.labelPrecision = labelPrecision;
			comp.showGrid = showGrid;
			comp.showScaleLabels = showScaleLabels;
			if (!isNaN(spacing)) comp.spacing = int(spacing);
			comp.barColor = barColor;
			comp.gridColor = gridColor;
			if (!isNaN(gridSize)) comp.gridSize = gridSize;
			var watcher:ChangeWatcher = BindingUtils.bindProperty(new ObjectInfo(), "trash", target, property);
			watcher.useWeakReference = true;
			watcher.setHandler(barChartLogHandler);
			_components[comp] = createObjectInfo(target, property, container, watcher, buffer);
			return comp;
		}
		
		public static function displayLineChart(container:DisplayObjectContainer, target:Object, property:String, buffer:int = 100, component:LineChart = null, autoScale:Boolean = true, minimumValue:Number = NaN, maximumValue:Number = NaN, labelPrecision:int = 0, showGrid:Boolean = false, showScaleLabels:Boolean = true, lineWidth:Number = NaN, lineColor:uint = 0x999999, gridColor:uint = 0xD0D0D0, gridSize:Number = NaN):LineChart {
			var comp:LineChart = (component == null) ? new LineChart(container, 0, 0) : component;
			comp.autoScale = autoScale;
			if (!isNaN(minimumValue)) comp.minimum = minimumValue;
			if (!isNaN(maximumValue)) comp.maximum = maximumValue;
			if (!isNaN(labelPrecision)) comp.labelPrecision = labelPrecision;
			comp.showGrid = showGrid;
			comp.showScaleLabels = showScaleLabels;
			if (!isNaN(lineWidth)) comp.lineWidth = lineWidth;
			comp.lineColor = lineColor;
			comp.gridColor = gridColor;
			if (!isNaN(gridSize)) comp.gridSize = gridSize;
			var watcher:ChangeWatcher = BindingUtils.bindProperty(new ObjectInfo(), "trash", target, property);
			watcher.useWeakReference = true;
			watcher.setHandler(lineChartLogHandler);
			_components[comp] = createObjectInfo(target, property, container, watcher, buffer);
			return comp;
		}
		
		public static function displayCheckBox(container:DisplayObjectContainer, target:Object, property:String, label:String = null, component:CheckBox = null):CheckBox {
			var comp:CheckBox = (component == null) ? new CheckBox(container, 0, 0) : component;
			if (label != null) comp.label = label;
			comp.addEventListener(MouseEvent.CLICK, checkboxHandler);
			var watcher:ChangeWatcher = BindingUtils.bindProperty(comp, "selected", target, property);
			watcher.useWeakReference = true;
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function displayColorChooser(container:DisplayObjectContainer, target:Object, property:String, component:ColorChooser = null, usePopup:Boolean = true, popupAlign:String = "bottom", model:DisplayObject = null):ColorChooser {
			var comp:ColorChooser = (component == null) ? new ColorChooser(container, 0, 0) : component;
			comp.usePopup = usePopup;
			comp.popupAlign = popupAlign;
			if (model) comp.model = model;
			comp.addEventListener(Event.CHANGE, colorHandler);
			var watcher:ChangeWatcher;
			if (target is Transform) {
				watcher = BindingUtils.bindProperty(new ObjectInfo(), "trash", Transform(target).colorTransform, property);
			}
			else {
				watcher = BindingUtils.bindProperty(comp, "value", target, property);
			}
			watcher.useWeakReference = true;
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function displayIndicatorLight(container:DisplayObjectContainer, target:Object, property:String, label:String = null, component:IndicatorLight = null):IndicatorLight {
			var comp:IndicatorLight = (component == null) ? new IndicatorLight(container, 0, 0) : component;
			if (label != null) comp.label = label;
			comp.isLit = true;
			comp.color = 0;
			var watcher:ChangeWatcher = BindingUtils.bindProperty(new ObjectInfo(), "trash", target, property);
			watcher.useWeakReference = true;
			watcher.setHandler(indicatorLightHandler);
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function displayKnob(container:DisplayObjectContainer, target:Object, property:String, label:String = null, component:Knob = null, mode:String = "vertical", radius:Number = NaN, minimumValue:Number = NaN, maximumValue:Number = NaN, labelPrecision:int = 1, mouseRange:Number = NaN):Knob {
			var comp:Knob = (component == null) ? new Knob(container, 0, 0, label) : component;
			comp.addEventListener(Event.CHANGE, knobHandler);
			if (label != null) comp.label = label;
			comp.mode = mode;
			if (!isNaN(radius)) comp.radius = radius;
			if (!isNaN(minimumValue)) comp.minimum = minimumValue;
			if (!isNaN(maximumValue)) comp.maximum = maximumValue;
			comp.labelPrecision = labelPrecision;
			if (!isNaN(mouseRange)) comp.mouseRange = mouseRange;
			var watcher:ChangeWatcher = BindingUtils.bindProperty(comp, "value", target, property);
			watcher.useWeakReference = true;
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function displayMeter(container:DisplayObjectContainer, target:Object, property:String, label:String = null, component:Meter = null, minimumValue:Number = NaN, maximumValue:Number = NaN, showValues:Boolean = true, damp:Number = 0.8):Meter {
			var comp:Meter = (component == null) ? new Meter(container, 0, 0, label) : component;
			if (label != null) comp.label = label;
			if (!isNaN(minimumValue)) comp.minimum = minimumValue;
			if (!isNaN(maximumValue)) comp.maximum = maximumValue;
			comp.showValues = showValues;
			comp.damp = damp;
			comp.addEventListener(Event.CHANGE, meterChangeHandler);
			var watcher:ChangeWatcher = BindingUtils.bindProperty(comp, "value", target, property);
			watcher.useWeakReference = true;
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function displayNumericStepper(container:DisplayObjectContainer, target:Object, property:String, step:Number = NaN, component:NumericStepper = null, minimumValue:Number = NaN, maximumValue:Number = NaN, labelPrecision:int = 0):NumericStepper {
			var comp:NumericStepper = (component == null) ? new NumericStepper(container, 0, 0) : component;
			if (!isNaN(step)) comp.step = step;
			comp.labelPrecision = labelPrecision;
			if (!isNaN(minimumValue)) comp.minimum = minimumValue;
			if (!isNaN(maximumValue)) comp.maximum = maximumValue;
			comp.addEventListener(Event.CHANGE, numericStepperChangeHandler);
			var watcher:ChangeWatcher = BindingUtils.bindProperty(comp, "value", target, property);
			watcher.useWeakReference = true;
			_components[comp] = createObjectInfo(target, property, container, watcher);
			return comp;
		}

		public static function disposeByTarget(target:Object):void {
			for (var obj:Object in _components) {
				var comp:Component = obj as Component;
				var info:ObjectInfo = _components[comp];
				if (info.target == target) {
					removeFromParent(comp);
					disposeDictionaryItem(comp, info);
				}
			}
		}
		
		public static function disposeByComponent(component:Component):void {
			for (var obj:Object in _components) {
				var comp:Component = obj as Component;
				if (comp == component) {
					var info:ObjectInfo = _components[comp];
					removeFromParent(comp);
					disposeDictionaryItem(comp, info);
				}
			}
		}
		
		public static function dispose():void {
			for (var obj:Object in _components) {
				var comp:Component = obj as Component;
				var info:ObjectInfo = _components[comp];
				removeFromParent(comp);
				disposeDictionaryItem(comp, info);
			}
			_components = new Dictionary(true);
			_textarea = new Dictionary(true);
		}

	}
}

import mx.binding.utils.ChangeWatcher;

import flash.display.DisplayObjectContainer;

class ObjectInfo {
	public var target:Object;
	public var property:String;
	public var container:DisplayObjectContainer;
	public var watcher:ChangeWatcher;
	public var trash:String;
	public var buffer:int;

	public function dispose():void {
		target = null;
		property = null;
		container = null;
		watcher.unwatch();
		watcher = null;
		trash = null;
	}
}
