package load;

import data.ScriptData;
import data.SunlightModule;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import haxe.ds.StringMap;
import states.PlayState;

class Stage extends FlxTypedGroup<FlxBasic>
{
	public var defaultCamZoom(never, set):Float;
	public var addGirlfriend:Bool = true;

	public var bfPos:FlxPoint  = new FlxPoint();
	public var dadPos:FlxPoint = new FlxPoint();
	public var gfPos:FlxPoint  = new FlxPoint();
	public var gfVersion:String = "";

	function set_defaultCamZoom(value:Float):Float
	{
		PlayState.defaultCamZoom = value;
		return value;
	}

	public var stageModule:SunlightModule;
	public var foreground:FlxTypedGroup<FlxBasic>;
	public var layers:FlxTypedGroup<FlxBasic>;

	public function new(stage:String, ?camPos:FlxPoint)
	{
		super();
		//gfPos.set(650, 550);
		//dadPos.set(100,700);
		//bfPos.set(850, 700);

		foreground = new FlxTypedGroup<FlxBasic>();
		layers = new FlxTypedGroup<FlxBasic>();

		var exposure:StringMap<Dynamic> = new StringMap<Dynamic>();
		exposure.set('add', add);
		exposure.set('$stage', this);
		exposure.set('foreground', foreground);
		stageModule = ScriptData.loadModule('$stage', 'stages/$stage', exposure);
		if (stageModule.exists("onCreate"))
			stageModule.get("onCreate")();
		trace('The $stage was loaded and added successfully');
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (stageModule.exists('onCreate'))
			stageModule.get("onUpdate")(elapsed);
	}

	public function onStep(curStep:Int)
	{
		if (stageModule.exists("onStep"))
			stageModule.get("onStep")(curStep);
	}

	public function onBeat(curBeat:Int)
	{
		if (stageModule.exists("onBeat"))
			stageModule.get("onBeat")(curBeat);
	}

	public function dispatchEvent(myEvent:String)
	{
		if (stageModule.exists("onEvent"))
			stageModule.get("onEvent")(myEvent);
	}
}
