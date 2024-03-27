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

class SunlightModule 
{
    public var interp:Interp;
    public var assetGroup:String;
    public var path:Paths;
    public var alive:Bool = true;

    public function new(?contents:Expr, ?assetGroup:String, ?extraParams:StringMap<Dynamic>) {
        interp = new Interp();
        for (key in ScriptData.load.keys()) {
            var value = ScriptData.load.get(key);
            interp.variables.set(key, value);
        }
        if (extraParams != null) {
            for (key in extraParams.keys()) {
                interp.variables.set(key, extraParams.get(key));
            }
        }
        this.assetGroup = assetGroup;
        interp.variables.set('getAsset', getAsset);
        var path = new LocalPath(assetGroup);
        interp.variables.set('Paths', path);
        interp.execute(contents);
    }
    //lol
    public function get(field:String):Dynamic
        return interp.variables.get(field);

    public function set(field:String, value:Dynamic):Void
        interp.variables.set(field, value);

    public function exists(field:String):Bool
        return interp.variables.exists(field);

    public function getAsset(directory:String, type:AssetType) {
        var path:String = LoaderManager.getPath(directory, assetGroup, type);
        if (FileSystem.exists(path))
            return LoaderManager.getAsset(directory, type, assetGroup);
        else {
            trace('path not found');
            return LoaderManager.getAsset(directory, type);
        }
    }
}
