package {

	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.display.Sprite;

	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	[Bindable]
	public class Square extends Sprite {

		private var _offset:Point;
		private var _halfTransparent:Boolean;
		private var _color:uint = Math.random() * 0xFFFFFF;

		public function Square() {
			
			draw();
			
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
		}

		private function draw():void {
			graphics.clear();
			graphics.beginFill(_color);
			graphics.drawRect(0, 0, 50, 50);
			graphics.endFill();
		}
		
		private function mouseDownHandler(event:MouseEvent):void {
			_offset = new Point(event.localX, event.localY);
			startDragging();
		}

		private function startDragging():void {
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}

		private function mouseMoveHandler(event:MouseEvent):void {
			updatePosition();
		}

		private function updatePosition():void {
			x = stage.mouseX - _offset.x;
			y = stage.mouseY - _offset.y;
		}

		private function mouseUpHandler(event:MouseEvent):void {
			stopDragging();
		}

		private function stopDragging():void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		override public function get x():Number {
			return super.x;
		}

		override public function set x(value:Number):void {
			super.x = value;
		}

		override public function get y():Number {
			return super.y;
		}

		override public function set y(value:Number):void {
			super.y = value;
		}

		public function get halfTransparent():Boolean {
			return _halfTransparent;
		}

		public function set halfTransparent(halfTransparent:Boolean):void {
			_halfTransparent = halfTransparent;
			alpha = (_halfTransparent) ? 0.5 : 1;
		}

		public function get color():uint {
			return _color;
		}

		public function set color(color:uint):void {
			_color = color;
			draw();
		}

	}
}
