package com.soundstep.utils {

	import flash.events.TimerEvent;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	/**
	 * @author Romuald Quantin (romu@soundstep.com)
	 */
	public class Time {
		
		private static var _counter:Number = 0;
		private static var _initialized:Boolean;
		private static var _elements:Dictionary;
		private static var _ids:Dictionary;

		private static function initialize():void {
			if (!_initialized) {
				_initialized = true;
				_elements = new Dictionary(true);
				_ids = new Dictionary();
			}
		}
		
		private static function handleCall(event:TimerEvent):void {
			var timer:Timer = event.currentTarget as Timer;
			var element:Object = _elements[timer];
			element.elapsedTime = element.delay * 1000;
			// call method
			if (element && element.callback) {
				element.callback.apply(null, element.args);
			}
			// destroy
			if (element && element.autoRemove) {
				disposeByID(element.id);
			}
			timer = null;
			element = null;
		}

		public static function call(callback:Function, delay:Number = 0, autoRemove:Boolean = true, args:Array = null):String {
			initialize();
			var id:String = createID();
			var timer:Timer = new Timer(delay, 1);
			timer.addEventListener(TimerEvent.TIMER, handleCall, false, 0, true);
			timer.start();
			_elements[timer] = {callback:callback, delay:delay, args:args, id:id, timer:timer, autoRemove:autoRemove, startTime:getTimer(), lastTime:getTimer(), timeElapsed:0};
			_ids[id] = timer;
			return id;
		}

		public static function getTimerObjectByID(id:String):Object {
			initialize();
			return _elements[_ids[id]];
		}
		
		public static function isRunning(id:String):Object {
			initialize();
			var timer:Timer = _ids[id];
			if (!timer) return false;
			return timer.running;
		}

		public static function pause(id:String):void {
			initialize();
			var timer:Timer = _ids[id];
			if (!timer || !timer.running) return;
			timer.stop();
			var element:Object = _elements[timer];
			element.timeElapsed += (getTimer() - element.lastTime);
		}
		
		public static function resume(id:String):void {
			initialize();
			var timer:Timer = _ids[id];
			if (!timer || timer.running) return;
			var element:Object = _elements[timer];
			if (element.timeElapsed > timer.delay) {
				element.timeElapsed = timer.delay;
			}
			timer.delay = (element.delay) - element.timeElapsed;
			element.lastTime = getTimer();
			timer.start();
		}
		
		public static function getTime(id:String):Number {
			initialize();
			var timer:Timer = _ids[id];
			if (!timer) return 0;
			var element:Object = _elements[timer];
			var currentTime:Number = 0;
			if (timer.running) {
				currentTime = Math.min(element.delay, Math.max(0, element.timeElapsed + (getTimer() - element.lastTime)));
			}
			else {
				if (element.elapsedTime == element.delay) {
					currentTime = element.delay;
				}
				else currentTime = element.timeElapsed;
			}
			return currentTime;
		}

		public static function disposeByID(id:String):void {
			initialize();
			var timer:Timer = _ids[id];
			_ids[id] = null;
			delete _ids[id];
			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, handleCall, false);
				_elements[timer] = null;
				delete _elements[timer];
			}
			timer = null;
		}
		
		public static function disposeByFunction(callback:Function):void {
			for each (var element:Object in _elements) {
				if (element.callback == callback) {
					disposeByID(element.id);
				}
			}
		}
		
		public static function dispose():void {
			initialize();
			for (var id:String in _ids) {
				disposeByID(id);
			}
			_elements = null;
			_ids = null;
			_initialized = false;
		}

		public static function print(id:String):String {
			initialize();
			var timer:Timer = _ids[id];
			if (!timer) return "No time found for the id: " + id;
			var element:Object = _elements[timer];
			var str:String = "[Time] id: " + element.id + "\n";
			str += "       delay: " + element.delay + " sec\n";
			str += "       args: " + element.args + "\n";
			str += "       autoRemove: " + element.autoRemove + "\n";
			str += "       timeElapsed: " + getTime(id) + " ms\n";
			str += "       startTime: " + element.startTime + "(ms\n";
			str += "       lastTime: " + element.lastTime + " ms\n";
			str += "       callback: " + element.callback + "\n";
			str += "       timer: " + element.timer + "\n";
			return str;
		}
		
		/******* CREATE ID *******************************/
		
		private static function createID():String {
			var dt:Date = new Date();
			var id1:Number = dt.getTime();
			var id2:Number = Math.random()*Number.MAX_VALUE;
			var id3:String = Capabilities.serverString;
			var rawID:String = calculate(id1+id3+id2+_counter++).toUpperCase();
			var finalString:String = rawID.substring(0, 8) + "-" + rawID.substring(8, 12) + "-" + rawID.substring(12, 16) + "-" + rawID.substring(16, 20) + "-" + rawID.substring(20, 32);
			return finalString;
		}
	
		private static function calculate(src:String):String {
				return hex_sha1(src);
		}
	
		private static function hex_sha1(src:String):String {
				return binb2hex(core_sha1(str2binb(src), src.length*8));
		}
			
		private static function core_sha1(x:Array, len:Number):Array {
			x[len >> 5] |= 0x80 << (24-len%32);
			x[((len+64 >> 9) << 4)+15] = len;
			var w:Array = new Array(80), a:Number = 1732584193;
			var b:Number = -271733879, c:Number = -1732584194;
			var d:Number = 271733878, e:Number = -1009589776;
			for (var i:Number = 0; i<x.length; i += 16) {
				var olda:Number = a, oldb:Number = b;
				var oldc:Number = c, oldd:Number = d, olde:Number = e;
				for (var j:Number = 0; j<80; j++) {
					if (j<16) w[j] = x[i+j];
					else w[j] = rol(w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16], 1);
					var t:Number = safe_add(safe_add(rol(a, 5), sha1_ft(j, b, c, d)), safe_add(safe_add(e, w[j]), sha1_kt(j)));
					e = d; d = c;
					c = rol(b, 30);
					b = a; a = t;
				}
				a = safe_add(a, olda);
				b = safe_add(b, oldb);
				c = safe_add(c, oldc);
				d = safe_add(d, oldd);
				e = safe_add(e, olde);
			}
			return new Array(a, b, c, d, e);
		}
	
		private static function sha1_ft(t:Number, b:Number, c:Number, d:Number):Number {
			if (t<20) return (b & c) | ((~b) & d);
			if (t<40) return b ^ c ^ d;
			if (t<60) return (b & c) | (b & d) | (c & d);
			return b ^ c ^ d;
		}
	
		private static function sha1_kt(t:Number):Number {
			return (t<20) ? 1518500249 : (t<40) ? 1859775393 : (t<60) ? -1894007588 : -899497514;
		}
	
		private static function safe_add(x:Number, y:Number):Number {
			var lsw:Number = (x & 0xFFFF)+(y & 0xFFFF);
			var msw:Number = (x >> 16)+(y >> 16)+(lsw >> 16);
			return (msw << 16) | (lsw & 0xFFFF);
		}
	
		private static function rol(num:Number, cnt:Number):Number {
			return (num << cnt) | (num >>> (32-cnt));
		}
	
		private static function str2binb(str:String):Array {
			var bin:Array = new Array();
			var mask:Number = (1 << 8)-1;
			for (var i:Number = 0; i<str.length*8; i += 8) {
				bin[i >> 5] |= (str.charCodeAt(i/8) & mask) << (24-i%32);
			}
			return bin;
		}
	
		private static function binb2hex(binarray:Array):String {
			var str:String = new String("");
			var tab:String = new String("0123456789abcdef");
			for (var i:Number = 0; i<binarray.length*4; i++) {
				str += tab.charAt((binarray[i >> 2] >> ((3-i%4)*8+4)) & 0xF) + tab.charAt((binarray[i >> 2] >> ((3-i%4)*8)) & 0xF);
			}
			return str;
		}

	}
}
