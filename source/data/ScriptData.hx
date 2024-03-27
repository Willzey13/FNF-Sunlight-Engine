package data;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import load.LoaderManager;
import load.hud.Note;
import load.hud.Strumline;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import states.PlayState;
import sys.io.File;
import sys.FileSystem;

class ScriptData 
{
    public static var load:StringMap<Dynamic> = new StringMap<Dynamic>();
    public static var parser:Parser = new Parser();

    public static function initialize() 
    {
        load.set("Sys", Sys);
        load.set("Std", Std);
        load.set("Math", Math);
        load.set("StringTools", StringTools);
        load.set("FlxG", FlxG);
        load.set("FlxSprite", FlxSprite);
        load.set("FlxMath", FlxMath);
        load.set("FlxTween", FlxTween);
        load.set("FlxEase", FlxEase);
        load.set("FlxTimer", FlxTimer);
        load.set("Conductor", Conductor);
        load.set("Note", Note);
        load.set("Strumline", Strumline);
        load.set("PlayState", PlayState);

        parser.allowTypes = true;
    }

    public static function loadModule(path:String, ?assetGroup:String, ?extraParams:StringMap<Dynamic>):SunlightModule {
        trace('Creating and loading the path $path');
        var curModule:SunlightModule = null;
        var modulePath:String = LoaderManager.getAsset(path, MODULE, assetGroup);
        if (FileSystem.exists(modulePath))
            curModule = new SunlightModule(parser.parseString(File.getContent(modulePath), modulePath), assetGroup, extraParams);
        return curModule;
    }
}