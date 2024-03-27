package load;

//import haxe.Json;
//import flixel.FlxG;
import load.LoaderManager;
import data.ScriptData;
import data.SunlightModule;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import load.CharacterOffsets.DoidoOffsets;
import haxe.ds.StringMap;
import sys.FileSystem;
import sys.io.File;

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
	public var cameraOffset:FlxPoint = new FlxPoint();
	public var ratingsOffset:FlxPoint = new FlxPoint();
	private var scaleOffset:FlxPoint = new FlxPoint();
	
	public var healthColorArray:Array<Int> = [255, 0, 0];

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
		antialiasing = FlxSprite.defaultAntialiasing;
		deathChar = "bf";

		animOffsets = new Map<String, Array<Dynamic>>();
		var storedPos:Array<Float> = [x, y];
		globalOffset.set();
		cameraOffset.set();
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
			trace('Character not load, Character as NULL');

		if (!FileSystem.exists(path))
		{
			var exposure:StringMap<Dynamic> = new StringMap<Dynamic>();
			exposure.set('character', this);
			var defaultChar:SunlightModule = ScriptData.loadModule('bf', 'images/characters/bf', exposure);
			if (defaultChar.exists("loadAnimations"))
				defaultChar.get("loadAnimations")();
		}

		// what
		/*switch(curChar)
		{
			case "bf":
				frames = Paths.getSparrowAtlas("characters/bf/BOYFRIEND");

				animation.addByPrefix('idle', 			'BF idle dance', 		24, false);
				animation.addByPrefix('singUP', 		'BF NOTE UP0', 			24, false);
				animation.addByPrefix('singLEFT', 		'BF NOTE LEFT0', 		24, false);
				animation.addByPrefix('singRIGHT', 		'BF NOTE RIGHT0', 		24, false);
				animation.addByPrefix('singDOWN', 		'BF NOTE DOWN0', 		24, false);
				animation.addByPrefix('singUPmiss', 	'BF NOTE UP MISS', 		24, false);
				animation.addByPrefix('singLEFTmiss', 	'BF NOTE LEFT MISS', 	24, false);
				animation.addByPrefix('singRIGHTmiss', 	'BF NOTE RIGHT MISS', 	24, false);
				animation.addByPrefix('singDOWNmiss', 	'BF NOTE DOWN MISS', 	24, false);
				animation.addByPrefix('hey', 			'BF HEY!!', 			24, false);

				animation.addByPrefix('firstDeath', 	"BF dies", 			24, false);
				animation.addByPrefix('deathLoop', 		"BF Dead Loop", 	24, true);
				animation.addByPrefix('deathConfirm', 	"BF Dead confirm", 	24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				flipX = true;
				loadOffsetFile("bf");

			case "gf" | "gf-tutorial":
				// GIRLFRIEND CODE
				frames = Paths.getSparrowAtlas('characters/gf/GF_assets' + ((curChar == "gf-tutorial") ? "_singer" : ""));
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				if(curChar == 'gf-tutorial')
				{
					animation.addByPrefix('singLEFT', 	'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 	'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 	'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 	'GF Down Note', 24, false);
				}
				animation.addByIndices('sad', 		'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight','GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				//animation.addByIndices('hairBlow', 	"GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				//animation.addByIndices('hairFall', 	"GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				idleAnims = ["danceLeft", "danceRight"];
				quickDancer = true;
				flipX = isPlayer;
				loadOffsetFile("gf");

			case "dad":
				// DAD ANIMATION LOADING CODE
				frames = Paths.getSparrowAtlas("characters/dad/DADDY_DEAREST");
				animation.addByPrefix('idle', 		'Dad idle dance', 		24, false);
				animation.addByPrefix('singUP', 	'Dad Sing Note UP', 	24, false);
				animation.addByPrefix('singRIGHT', 	'Dad Sing Note RIGHT', 	24, false);
				animation.addByPrefix('singDOWN', 	'Dad Sing Note DOWN', 	24, false);
				animation.addByPrefix('singLEFT', 	'Dad Sing Note LEFT', 	24, false);

				animation.addByIndices('idle-loop', 	'Dad idle dance',  [11,12,13,14], "", 24, true);
				animation.addByIndices('singUP-loop', 	'Dad Sing Note UP',    [3,4,5,6], "", 24, true);
				animation.addByIndices('singRIGHT-loop','Dad Sing Note RIGHT', [3,4,5,6], "", 24, true);
				animation.addByIndices('singLEFT-loop', 'Dad Sing Note LEFT',  [3,4,5,6], "", 24, true);
				loadOffsetFile("dad");

			default:
				return reloadChar(isPlayer ? "bf" : "dad");
		}*/
		
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
		if(specialAnim) return;

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