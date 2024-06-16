package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSort;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import load.hud.Note;
import load.Saved;
import states.PlayState;

class Configs
{
	public static var curMusic:String = "none";
	public static var difficultyArray:Array<String> = [
		'Easy', 
		'Normal', 
		'Hard'
	];

	public static function difficultyFromNumber(number:Int):String
	{
		return difficultyArray[number];
	}

	public static function playMusic(?key:String, ?forceRestart:Bool = false, ?vol:Float = 0.5)
	{
		if (Paths.dumpExclusions.contains('music/' + curMusic + '.ogg'))
			Paths.dumpExclusions.remove  ('music/' + curMusic + '.ogg');
		
		if(key == null)
		{
			curMusic = "none";
			FlxG.sound.music.stop();
		}
		else
		{
			Paths.dumpExclusions.push('music/' + key + '.ogg');

			if(curMusic != key || forceRestart)
			{
				curMusic = key;
				FlxG.sound.playMusic(Paths.music(key), vol);
				//FlxG.sound.music.loadEmbedded(Paths.music(key), true, false);
				FlxG.sound.music.play(true);
			}
		}
	}

	public static var defaultDifficulty:String = 'Normal';
	public static var difficulties:Array<String> = [];
	
	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function coolTextFile(key:String):Array<String>
	{
		var daList:Array<String> = Paths.txt(key).split('\n');

		for(i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	inline public static function getDirection(i:Int)
		return ["left", "down", "up", "right"][i];

	inline public static function getNotesDirection(i:Int)
		return ["LEFT", "DOWN", "UP", "RIGHT"][i];

	inline public static function getNotesColor(i:Int)
		return ["purple", "blue", "green", "red"][i];

	inline public static function noteWidth()
		return (160 * 0.7);

	public static function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	public static function setNotePos(note:FlxSprite, target:FlxSprite, angle:Float, offsetX:Float, offsetY:Float)
	{
		note.x = target.x
			+ (Math.cos(FlxAngle.asRadians(angle)) * offsetX)
			+ (Math.sin(FlxAngle.asRadians(angle)) * offsetY);
		note.y = target.y
			+ (Math.cos(FlxAngle.asRadians(angle)) * offsetY)
			+ (Math.sin(FlxAngle.asRadians(angle)) * offsetX);
	}

	public static function flash(?camera:FlxCamera, ?duration:Float = 0.5, ?color:FlxColor, ?forced:Bool = false)
	{
		if(camera == null)
			camera = FlxG.camera;
		if(color == null)
			color = 0xFFFFFFFF;
		
		if(!forced)
		{
			if(!Saved.gameSettings.get("Flashlight")) return;

			if(Saved.gameSettings.get("Flashlight"))
				color.alphaFloat = 0.4;
		}
		camera.flash(color, duration, null, true);
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}
}