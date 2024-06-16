package load;

import data.CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import options.object.*;

@:enum abstract SettingType(Int)
{
	var Checkmark = 0;
	var Selector = 1;
}

@:structInit class OptionSaved
{		
	public static var data:Map<String, Dynamic> = [];
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var opponentStrums:Bool = true;
	public var showFPS:Bool = true;
	public var flashing:Bool = true;
	public var autoPause:Bool = true;
	public var antialiasing:Bool = true;
	public var skinNotes:String = 'Default';
	public var splashSkin:String = 'Psych';
	public var splashAlpha:Float = 0.6;
	public var lowQuality:Bool = false;

	public var shaders:Bool = true;
	public var cacheOnGPU:Bool = #if !switch false #else true #end; //From Stilic
	public var framerate:Int = 60;
	public var camZooms:Bool = true;
	public var hideHud:Bool = false;
	public var noteOffset:Int = 0;
	public var offset:Float = 0;

	public var ghostTapping:Bool = true;
	public var timeBarType:String = 'Time Left';
	public var scoreZoom:Bool = true;
	public var noReset:Bool = false;
	public var healthBarAlpha:Float = 1;

	public var hitsoundVolume:Float = 0;
	public var typeHitsound:Array<String> = ['osu', 'psych', 'kade'];
	public var hitsound:Bool = false;

	public var pauseMusic:String = 'Tea Time';
	public var checkForUpdates:Bool = true;
	public var comboStacking:Bool = true;

	public var comboOffset:Array<Int> = [0, 0, 0, 0];
	public var ratingOffset:Int = 0;

	public var safeFrames:Float = 10;
	public var guitarHeroSustains:Bool = true;
	public var discordRPC:Bool = true;
	public var noteSplashs:Bool = true;
	public var discordRpc:Bool = true;
}

class Saved
{
	//options
	public static var trueSettings:Map<String, Dynamic> = [];
	public static var FORCED = 'forced';
	public static var NOT_FORCED = 'not forced';

	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;

	public static var gameSettings:Map<String, Dynamic> = [
		'Flashlight' => [
			true, Checkmark,
			'Unchecking the option, all Flashlight will be disable', NOT_FORCED
		],
		'Cache GPU' => [
			true, Checkmark,
			'Unchecking the option, all Flashlight will be disable', NOT_FORCED
		],
		'Downscroll' => [
			false, Checkmark,
			'Whether to have the strumline vertically flipped in gameplay.', NOT_FORCED
		],
		'Shaders' => [
			false, Checkmark,
			'When enabling or disabling this option, It will either add or remove the shader, respectively.', NOT_FORCED
		],
		'Controller Mode' => [
			false, Checkmark,
			'Whether to use a controller instead of the keyboard to play.', NOT_FORCED
		],
		'Auto Pause' => [
			true, Checkmark,
			'Whether to pause the game automatically if the window is unfocused.', NOT_FORCED
		],
		'FPS Counter' => [
			true, Checkmark, 
			'Whether to display the FPS counter.', NOT_FORCED
		],
		'Memory Counter' => [
			true, Checkmark,
			'Whether to display approximately how much memory is being used.', NOT_FORCED
		],
		'Counter' => [
			'None', Selector,
			'Choose whether you want somewhere to display your judgements, and where you want it.', NOT_FORCED,
			['None', 'Left', 'Right']
		],
		'Antialiasing' => [
			false, Checkmark,
			'Whether to disable Anti-aliasing. Helps improve performance in FPS.', NOT_FORCED
		],
		'Note Splashes' => [
			false, Checkmark,
			'Whether to disable note splashes in gameplay. Useful if you find them distracting.', NOT_FORCED
		],
		'Botplay Visible' => [
			false, Checkmark,
			'Whether to disable note splashes in gameplay. Useful if you find them distracting.', NOT_FORCED
		],
		'Offset' => [
			Checkmark, 
			3
		],
		"Note Skin" => [
			'default', Selector, 
			'Choose a note skin.', NOT_FORCED, 
			''
		],
		"Framerate" => [
			60, Selector, 
			'Define your FPS.', NOT_FORCED, 
			[]
		],
		"Note Offset" => [
			0, Selector, 
			'Define your FPS.', NOT_FORCED, 
			[]
		],
		'Ghost Tapping' => [
			false, Checkmark,
			"Enables Ghost Tapping, allowing you to press inputs without missing.", NOT_FORCED
		],
		'Hide HUD' => [
			false, Checkmark,
			"Enables Ghost Tapping, allowing you to press inputs without missing.", NOT_FORCED
		],
		'Middlescroll' => [
			false, Checkmark, 
			"Center the notes, disables the enemy's notes."
		],//comboStacking
		'Combo Stacking' => [
			true, Checkmark, 
			"Center the notes, disables the enemy's notes."
		],
		'Discord RPC' => [
			true, Checkmark, 
			"Center the notes, disables the enemy's notes."
		],
	];

	public static var data:OptionSaved = {};
	public static var comboOffset:Array<Int> = [0, 0, 0, 0];

	public static function init()
	{
		FlxG.save.bind('foreverengine-options');
		saveSettings();
		//Controls.load();
		loadControls();
		saveControls();
		//Highscore.load();
		//subStates.editors.ChartAutoSaveSubState.load(); // uhhh
	}

	public static var allControls = Controls.allControls;

	public static function loadControls():Void
	{
		FlxG.save.bind('sunlight-options');
		if ((FlxG.save.data.allControls != null) && (Lambda.count(FlxG.save.data.allControls) == Lambda.count(allControls)))
			allControls = FlxG.save.data.allControls;

		saveControls();
	}

	public static function saveControls():Void
	{
		FlxG.save.data.allControls = allControls;
		FlxG.save.bind('sunlight-options');
		FlxG.save.flush();
	}

	public static function saveSettings():Void
	{
		FlxG.save.data.settings = trueSettings;
		FlxG.save.bind('sunlight-options');
		FlxG.save.flush();
	}
}