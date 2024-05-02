package data;

import flixel.FlxState;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import options.object.*;

class CoolUtil
{
	public static var gFont:String = Paths.font("vcr.ttf");
	public static final savePath:String = "Toffee&Willzey/Funkin Sunlight";
	public static var sunlightEngineVersion:String = '1.0.0';

	public static function dashToSpace(string:String):String
	{
		return string.replace("-", " ");
	}

	public static function spaceToDash(string:String):String
	{
		return string.replace(" ", "-");
	}

	public static function swapSpaceDash(string:String):String
	{
		return StringTools.contains(string, '-') ? dashToSpace(string) : spaceToDash(string);
	}

	//add CameraLerpZoom
	public static function setLerpCamZoom(daCam:FlxCamera, target:Float = 1.0, speed:Int = 6):Void 
	{
		var elapsed:Float = FlxG.elapsed;
		daCam.zoom = FlxMath.lerp(daCam.zoom, target, elapsed * speed);
	}

	//add camPosLerp
	public static function camPosLerp(cam:flixel.FlxCamera, target:flixel.FlxObject, lerp:Float = 1):Void
	{
		var centerX:Float = target.x - FlxG.width / 2;
		var centerY:Float = target.y - FlxG.height / 2;
		
		cam.scroll.x = FlxMath.lerp(cam.scroll.x, centerX, lerp);
		cam.scroll.y = FlxMath.lerp(cam.scroll.y, centerY, lerp);
	}

	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
	
	public static function coolTextFile(key:String):Array<String> 
	{
		// Lê o conteúdo do arquivo de texto usando a chave fornecida
		var content:String = Paths.txt(key);
		var lines:Array<String> = content.split('\n');// Divide o conteúdo do arquivo em linhas
		
		// Remove os espaços em branco extras em cada linha
		for (i in 0...lines.length) {
			lines[i] = lines[i].trim();
		}
		
		return lines;
	}

	public static function killMusic(songsArray:Array<FlxSound>)
	{
		// neat function thing for songs
		for (i in 0...songsArray.length)
		{
			// stop
			songsArray[i].stop();
			songsArray[i].destroy();
		}
	}

	public static function generateCheckmark(x:Float, y:Float, asset:String, assetModifier:String = 'base')
	{
		var newCheckmark:Checkmark = new Checkmark(x, y);
		switch (assetModifier)
		{
			default:
				newCheckmark.frames = Paths.getSparrowAtlas(asset);
				newCheckmark.antialiasing = true;

				newCheckmark.animation.addByPrefix('false finished', 'uncheckFinished');
				newCheckmark.animation.addByPrefix('false', 'uncheck', 12, false);
				newCheckmark.animation.addByPrefix('true finished', 'checkFinished');
				newCheckmark.animation.addByPrefix('true', 'check', 12, false);

				// for week 7 assets when they decide to exist
				// animation.addByPrefix('false', 'Check Box unselected', 24, true);
				// animation.addByPrefix('false finished', 'Check Box unselected', 24, true);
				// animation.addByPrefix('true finished', 'Check Box Selected Static', 24, true);
				// animation.addByPrefix('true', 'Check Box selecting animation', 24, false);
				newCheckmark.setGraphicSize(Std.int(newCheckmark.width * 0.7));
				newCheckmark.updateHitbox();

				///*
				var offsetByX = 45;
				var offsetByY = 5;
				newCheckmark.addOffset('false', offsetByX, offsetByY);
				newCheckmark.addOffset('true', offsetByX, offsetByY);
				newCheckmark.addOffset('true finished', offsetByX, offsetByY);
				newCheckmark.addOffset('false finished', offsetByX, offsetByY);
				// */

				// addOffset('true finished', 17, 37);
				// addOffset('true', 25, 57);
				// addOffset('false', 2, -30);
		}
		return newCheckmark;
	}
}
