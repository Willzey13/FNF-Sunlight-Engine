package;

import flixel.input.gamepad.FlxGamepadInputID as FlxPad;
import sys.io.File;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput.FlxInputState;

class Controls 
{
    public static var JUST_PRESSED:FlxInputState = FlxInputState.JUST_PRESSED;
    public static var PRESSED:FlxInputState = FlxInputState.PRESSED;
    public static var JUST_RELEASED:FlxInputState = FlxInputState.JUST_RELEASED;

    public static var allControls:Map<String, Array<Dynamic>> = [
        'LEFT' =>         [[A, FlxKey.LEFT], 0],
        'DOWN' =>         [[S, FlxKey.DOWN], 1],
		'UP' =>           [[W, FlxKey.UP], 2],
        'RIGHT' =>        [[D, FlxKey.RIGHT], 3],
        'UI_LEFT' =>      [[A, FlxKey.LEFT], 4],
        'UI_DOWN' =>      [[S, FlxKey.DOWN], 5],
        'UI_UP' =>        [[W, FlxKey.UP], 6],
        'UI_RIGHT' =>     [[D, FlxKey.RIGHT], 7],
        'ACCEPT' =>       [[Z, FlxKey.SPACE, FlxKey.ENTER], 8],
        'BACK' =>         [[X, FlxKey.BACKSPACE, FlxKey.ESCAPE], 9],
        'PAUSE' =>        [[P, FlxKey.ENTER], 10],
        'RESET' =>        [[R, null], 11],
        'BOTPLAY' =>      [[FlxKey.B, null], 12],
		'debug' =>        [[FlxKey.SEVEN, FlxKey.SEVEN], [FlxPad.A, FlxPad.X, FlxPad.START],
        ],
	];

    public static function justPressed(bind:String):Bool
    {
        return checkBind(bind, JUST_PRESSED);
    }

    public static function pressed(bind:String):Bool
    {
        return checkBind(bind, PRESSED);
    }

    public static function released(bind:String):Bool
    {
        return checkBind(bind, JUST_RELEASED);
    }

    public static function checkBind(bind:String, inputState:FlxInputState):Bool
    {
        if(!allControls.exists(bind))
        {
            trace("Este atalho não existe.");
            return false;
        }

        for(i in 0...allControls.get(bind)[0].length)
        {
            var key:FlxKey = allControls.get(bind)[0][i];
            if(FlxG.keys.checkStatus(key, inputState) && key != FlxKey.NONE)
                return true;
        }

        if(FlxG.gamepads.lastActive != null)
        for(i in 0...allControls.get(bind)[1].length)
        {
            var key:FlxPad = allControls.get(bind)[1][i];
            if(FlxG.gamepads.lastActive.checkStatus(key, inputState) && key != FlxPad.NONE)
                return true;
        }

        return false;
    }
    
    public static function setControls(bind:String, keys:Array<FlxKey>, gamepadKeys:Array<FlxPad>):Void
    {
        allControls.set(bind, [keys, gamepadKeys]);
    }

    public static function saveControls(filename:String):Void {
        var file = File.write(filename, false);
        for (bind in allControls.keys()) {
            file.writeString(bind + ":");
            file.writeString("\nKeyboard:");
            for (key in allControls.get(bind)) {
                file.writeString(" " + key.toString());
            }
            file.writeString("\nGamepad:");
            for (key in allControls.get(bind)) {
                file.writeString(" " + key.toString());
            }
            file.writeString("\n");
        }
        file.close();
        trace("Controles salvos em: " + filename);
    }

    public static function loadControls(filename:String):Void {
        var file = File.read(filename);
        allControls = new Map<String, Array<Dynamic>>();
        var bind:String = "";
        var keyboardKeys:Array<FlxKey> = [];
        var gamepadKeys:Array<FlxPad> = [];
        while (!file.eof()) {
            var line = file.readLine().trim();
            if (line == "") continue;
            if (line.indexOf(":") != -1) {
                if (bind != "") {
                    allControls.set(bind, [keyboardKeys, gamepadKeys]);
                    keyboardKeys = [];
                    gamepadKeys = [];
                }
                bind = line.split(":")[0];
            } else if (line.indexOf("Keyboard:") != -1) {
                var keys = line.split(":")[1].split(" ");
                for (key in keys) {
                    if (key != "") keyboardKeys.push(FlxKey.fromString(key));
                }
            } else if (line.indexOf("Gamepad:") != -1) {
                var keys = line.split(":")[1].split(" ");
                for (key in keys) {
                    if (key != "") gamepadKeys.push(FlxPad.fromString(key));
                }
            }
        }
        if (bind != "") {
            allControls.set(bind, [keyboardKeys, gamepadKeys]);
        }
        file.close();
        trace("Controles carregados de: " + filename);
    }
}
