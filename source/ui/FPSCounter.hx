package ui;

import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

class FPSCounter extends TextField
{
	var times:Array<Float> = [];
	var memPeak:UInt = 0;

	static var displayFps = true;
	static var displayMemory = true;
	static var displayExtra = true;

	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = x;

		autoSize = LEFT;
		selectable = false;

		defaultTextFormat = new TextFormat(Paths.font("comicz.ttf"), 18, 0xFFFFFF);
		text = "";

		addEventListener(Event.ENTER_FRAME, update);
	}

	static final intervalArray:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB'];

	public static function getInterval(num:UInt):String
	{
		var size:Float = num;
		var data = 0;
		while (size > 1000 && data < intervalArray.length - 1)
		{
			data++;
			size = size / 1000;
		}

		size = Math.round(size * 100) / 100;
		return size + " " + intervalArray[data];
	}

	function update(_:Event)
	{
		var now:Float = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		var mem = System.totalMemory;
		if (mem > memPeak)
			memPeak = mem;

		if (visible)
		{
			text = ''
				+ (displayFps ? (times.length > Saved.data.framerate ? Saved.data.framerate : times.length)
					+ " FPS\n" : '')
			+ (displayMemory ? '${getInterval(mem)} / ${getInterval(memPeak)}\n' : ''); // Current and Total Memory Usage
		}
	}

	public static function updateDisplayInfo(shouldDisplayFps:Bool, shouldDisplayExtra:Bool, shouldDisplayMemory:Bool)
	{
		displayFps = shouldDisplayFps;
		displayExtra = shouldDisplayExtra;
		displayMemory = shouldDisplayMemory;
	}
}
