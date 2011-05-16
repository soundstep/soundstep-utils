package test {

	import org.hamcrest.object.instanceOf;
	import org.hamcrest.assertThat;
	import org.flexunit.Assert;
	import com.soundstep.utils.Time;

	import org.flexunit.async.Async;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class TimerTests {

		private var _timer:Timer;
		private var _called:Boolean;
		private var _arguments:Array;
		private var _id:String;

	    [Before]
	    public function setUp():void {
	    	_called = false;
	    	_arguments = null;
	    	_id = null;
	        _timer = new Timer(100, 1);
	    }
	
	    [After]
	    public function tearDown():void {
	        if (_timer) _timer.stop();
	        _timer = null;
	    }
	
	    private function handleTimeout(passThroughData:Object):void {
	    	passThroughData;
	        Assert.fail("Time out");
	    }
	    
		private function validateCall(... args):void {
			_called = true;
			_arguments = args;
		}
	
		private function testDisposeFailed():void {
			Assert.fail("Test dispose failed");
		}
		
		private function shouldNotBeCalled():void {
			Assert.fail("Function should not be called triggered");
		}
	    
	    [Test(async)]
	    public function testCall():void {
	        _timer.delay = 200;
	        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, Async.asyncHandler(this, testCallComplete, 500, null, handleTimeout), false, 0, true);
	        _timer.start();
			Time.call(validateCall, 100);
	    }
	
	    protected function testCallComplete(event:TimerEvent, passThroughData:Object):void {
	    	passThroughData;
	        Assert.assertTrue(_called);
	    }
	    
	    [Test(async)]
	    public function testArguments():void {
	    	var arguments:Array = [true, 1.2, "my string", {data:"object"}];
	        _timer.delay = 200;
	        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, Async.asyncHandler(this, testArgumentsComplete, 500, arguments, handleTimeout), false, 0, true);
	        _timer.start();
			Time.call(validateCall, 100, true, arguments);
	    }
	
	    protected function testArgumentsComplete(event:TimerEvent, passThroughData:Object):void {
	    	passThroughData;
	        Assert.assertTrue(_called);
	        // test boolean
	        Assert.assertEquals(passThroughData[0], _arguments[0]);
	        Assert.assertTrue(arguments[0]);
	        // test Number
	        Assert.assertEquals(passThroughData[1], _arguments[1]);
	        assertThat(_arguments[1], instanceOf(Number));
	        // test String
	        Assert.assertEquals(passThroughData[2], _arguments[2]);
	        assertThat(_arguments[2], instanceOf(String));
	        // test Object
	        Assert.assertNotNull(_arguments[3]);
	        Assert.assertEquals(passThroughData[3].data, _arguments[3].data);
	    }
	
	    [Test(async)]
	    public function testGetID():void {
			_id = Time.call(validateCall, 100, false);
	        _timer.delay = 200;
	        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, Async.asyncHandler(this, testGetIDComplete, 500, _id, handleTimeout), false, 0, true);
	        _timer.start();
	    }
	
	    protected function testGetIDComplete(event:TimerEvent, passThroughData:Object):void {
	    	Assert.assertNotNull(Time.getTimerObjectByID(_id));
	    	Assert.assertEquals(_id, passThroughData);
	    	Assert.assertEquals(_id, Time.getTimerObjectByID(_id).id);
	    	Time.disposeByID(_id);
	    }

	    [Test(async)]
	    public function testGetIDIsNull():void {
			_id = Time.call(validateCall, 100);
	        _timer.delay = 200;
	        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, Async.asyncHandler(this, testGetIDIsNullComplete, 500, null, handleTimeout), false, 0, true);
	        _timer.start();
	    }
	
	    protected function testGetIDIsNullComplete(event:TimerEvent, passThroughData:Object):void {
	    	passThroughData;
	    	Assert.assertNull(Time.getTimerObjectByID(_id));
	    }
	    
	    [Test(async)]
	    public function testDisposeByID():void {
			_id = Time.call(validateCall, 100, false);
	        _timer.delay = 200;
	        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, Async.asyncHandler(this, testDisposeByIDComplete, 500, null, handleTimeout), false, 0, true);
	        _timer.start();
	    }
	
	    protected function testDisposeByIDComplete(event:TimerEvent, passThroughData:Object):void {
	    	passThroughData;
	    	Assert.assertNotNull(Time.getTimerObjectByID(_id));
	    	Time.disposeByID(_id);
	    	Assert.assertNull(Time.getTimerObjectByID(_id));
	    }
	    
	    [Test]
	    public function testDispose():void {
			var id1:String = Time.call(testDisposeFailed, 100, false);
			var id2:String = Time.call(testDisposeFailed, 100, false);
			var id3:String = Time.call(testDisposeFailed, 100, false);
			var id4:String = Time.call(testDisposeFailed, 100);
			var id5:String = Time.call(testDisposeFailed, 100);
	        Time.dispose();
	    	Assert.assertNull(Time.getTimerObjectByID(id1));
	    	Assert.assertNull(Time.getTimerObjectByID(id2));
	    	Assert.assertNull(Time.getTimerObjectByID(id3));
	    	Assert.assertNull(Time.getTimerObjectByID(id4));
	    	Assert.assertNull(Time.getTimerObjectByID(id5));
		}

	    [Test]
	    public function testDisposeByFunction():void {
			var id1:String = Time.call(shouldNotBeCalled, 100);
			var id2:String = Time.call(shouldNotBeCalled, 100, false);
	        Time.disposeByFunction(shouldNotBeCalled);
	        Assert.assertNull(Time.getTimerObjectByID(id1));
	        Assert.assertNull(Time.getTimerObjectByID(id2));
		}

	    [Test]
	    public function testIsRunning():void {
			_id = Time.call(validateCall, 100);
			Assert.assertTrue(Time.isRunning(_id));
			Time.pause(_id);
			Assert.assertFalse(Time.isRunning(_id));
			Time.resume(_id);
			Assert.assertTrue(Time.isRunning(_id));
		}

	}
}
