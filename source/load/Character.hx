package load;

//import haxe.Json;
//import flixel.FlxG;
import load.LoaderManager;
import data.ScriptData;
import data.SunlightModule;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import haxe.ds.StringMap;
import sys.FileSystem;
import sys.io.File;
import load.hud.HealthIcon;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>> = [];
	public var curChar:String = "bf";
	public var isPlayer:Bool = false;

	public var holdTimer:Float = Math.NEGATIVE_INFINITY;
	public var holdLength:Float = 0.7;
	public var holdLoop:Int = 4;

	public var idleAnims:Array<String> = [];

	public var quickDancer:Bool = false;
	public var specialAnim:Bool = false;
	public var deathChar:String = "bf";
	public var isSpectator:Bool = false;

	public var globalOffset:FlxPoint = new FlxPoint();
	public var cameraPosition:Array<Float> = [0, 0];
	public var ratingsOffset:FlxPoint = new FlxPoint();
	private var scaleOffset:FlxPoint = new FlxPoint();
	
	public var healthColorArray:Array<Int> = [255, 0, 0];
	public var size:Float = 1;
	public var icon:String = "bf";

	public function new(x:Float = 0, y:Float = 0)
		super(x, y);

	public function reloadChar(character:String = "bf"):Character
	{
		this.curChar = character;

		holdLoop = 4;
		holdLength = 0.7;
		idleAnims = ["idle"];

		quickDancer = false;

		flipX = flipY = false;
		scale.set(1,1);
		antialiasing = Saved.gameSettings.get("Antialiasing");
		deathChar = "bf";

		animOffsets = new Map<String, Array<Dynamic>>();
		var storedPos:Array<Float> = [x, y];
		globalOffset.set();
		ratingsOffset.set();

		var path:String = LoaderManager.getPath('$character', 'images/characters/$character', MODULE);

		if (FileSystem.exists(path))
		{
			var exposure:StringMap<Dynamic> = new StringMap<Dynamic>();
			exposure.set('character', this);
			var character:SunlightModule = ScriptData.loadModule(character, 'images/characters/$character', exposure);
			if (character.exists("loadAnimations"))
				character.get("loadAnimations")();
		}
		else
			trace('Character not found, loading default character ${curChar}');

		if (!FileSystem.exists(path))
		{
			var exposure:StringMap<Dynamic> = new StringMap<Dynamic>();
			exposure.set('character', this);
			var defaultChar:SunlightModule = ScriptData.loadModule('bf', 'images/characters/bf', exposure);
			if (defaultChar.exists("loadAnimations"))
				defaultChar.get("loadAnimations")();
		}

		if (size != 1) {
			scale.set(size, size);
			updateHitbox();
		}

		if (icon == null)
			icon = "face";

		if(isPlayer)
			flipX = !flipX;

		dance();

		return this;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0):Void
		animOffsets[name] = [x, y];

	private var curDance:Int = 0;

	public function dance(forced:Bool = false)
	{
		if (specialAnim) return;

		switch(curChar)
		{
			default:
				playAnim(idleAnims[curDance]);
				curDance++;

				if (curDance >= idleAnims.length)
					curDance = 0;
		}
	}

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		animation.play(animName, forced, reversed, frame);
	
		var daOffset = animOffsets.get(animName);
		if (animOffsets.exists(animName))
			offset.set(daOffset[0], daOffset[1]);
	}
}