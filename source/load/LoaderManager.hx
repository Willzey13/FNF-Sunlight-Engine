package load;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;

@:enum abstract AssetType(String) to String
{
	var IMAGE = 'image';
	var SPARROW = 'sparrow';
	var SOUND = 'sound';
	var MUSIC = 'music';
	var FONT = 'font';
	var DIRECTORY = 'directory';
	var MODULE = 'module';
	var JSON = 'json';
}

class LoaderManager
{
	public static var keyedAssets:Map<String, Dynamic> = [];
	public static function getAsset(directory:String, ?type:AssetType = DIRECTORY, ?group:String):Dynamic
	{
		var gottenPath = getPath(directory, group, type);
		switch (type)
		{
			case JSON:
				return File.getContent(gottenPath);
			case IMAGE:
				return returnGraphic(gottenPath, false);
			case SPARROW:
				var graphicPath = getPath(directory, group, IMAGE);
				var graphic:FlxGraphic = returnGraphic(graphicPath, false);
				return FlxAtlasFrames.fromSparrow(graphic, File.getContent(gottenPath));
			default:
				return gottenPath;
		}
		trace('NULL was returned for $gottenPath');
		return null;
	}

	public static function returnGraphic(key:String, ?gpuRender:Bool = false)
	{
		if (FileSystem.exists(key))
		{
			if (!Paths.currentTrackedAssets.exists(key))
			{
				var bitmap = BitmapData.fromFile(key);
				var newGraphic:FlxGraphic;
				if (gpuRender)
				{
					var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true);
					texture.uploadFromBitmapData(bitmap);
					Paths.currentTrackedTextures.set(key, texture);
					bitmap.dispose();
					bitmap.disposeImage();
					bitmap = null;
					// trace('new texture $key, bitmap is $bitmap');
					newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
				}
				else
				{
					newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
				}
				newGraphic.persist = true;
				Paths.currentTrackedAssets.set(key, newGraphic);
			}
			Paths.localTrackedAssets.push(key);
			return Paths.currentTrackedAssets.get(key);
		}
		trace('The graph returned as null $key with gpu rendering $gpuRender');
		return null;
	}

	public static function getPath(directory:String, group:String, ?type:AssetType = DIRECTORY):String
	{
		var pathBase:String = 'assets/';
		var directoryExtension:String = '$group/$directory';
		return filterExtensions('$pathBase$directoryExtension', type);
	}

	public static function filterExtensions(directory:String, type:String)
	{
		if (!FileSystem.exists(directory))
		{
			var extensions:Array<String> = [];
			switch (type)
			{
				case IMAGE:
					extensions = ['.png'];
				case JSON:
					extensions = ['.json'];
				case SPARROW:
					extensions = ['.xml'];
				case SOUND:
					extensions = ['.ogg', '.wav'];
				case FONT:
					extensions = ['.ttf', '.otf'];
				case MODULE:
					extensions = ['.hxs', '.hx'];
			}
			for (i in extensions)
			{
				var returnDirectory:String = '$directory$i';
				if (FileSystem.exists(returnDirectory))
				{
					return returnDirectory;
				}
			}
		}
		return directory;
	}
}

class LocalPath
{
	public var localPath:String;

	public function new(localPath:String)
	{
		this.localPath = localPath;
	}

	private function image(key:String, ?gpuRender:Bool = false)
	{
		return LoaderManager.getAsset(key, IMAGE, localPath);
	}

	private function getSparrowAtlas(key:String)
	{
		return LoaderManager.getAsset(key, SPARROW, localPath);
	}
}
