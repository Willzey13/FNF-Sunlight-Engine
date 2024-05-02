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
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;
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

	public static var gameSettings:Map<String, Dynamic> = [
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
		"UI Skin" => [
			'default', Selector,
			'Choose a UI Skin for judgements, combo, etc.', NOT_FORCED,
			''
		],
		"Note Skin" => [
			'default', Selector, 
			'Choose a note skin.', NOT_FORCED, 
			''
		],
		"Framerate" => [
			60, Selector, 
			'Define your maximum FPS.', NOT_FORCED, 
			[]
		],
		'Ghost Tapping' => [
			false, Checkmark,
			"Enables Ghost Tapping, allowing you to press inputs without missing.", NOT_FORCED
		],
		'Centered Notefield' => [
			false, Checkmark, 
			"Center the notes, disables the enemy's notes."
		],
		"Custom Titlescreen" => [
			false, Checkmark,
			"Enables the custom Forever Engine titlescreen! (only effective with a restart)", FORCED
		],
		'Skip Text' => [
			'freeplay only', Selector,
			'Decides whether to skip cutscenes and dialogue in gameplay. May be always, only in freeplay, or never.', NOT_FORCED,
			['never', 'freeplay only', 'always']
		],
		'Fixed Judgements' => [
			false, Checkmark,
			"Fixes the judgements to the camera instead of to the world itself, making them easier to read.", NOT_FORCED
		],
		'Simply Judgements' => [
			false, Checkmark,
			"Simplifies the judgement animations, displaying only one judgement / rating sprite at a time.", NOT_FORCED
		],
	];

	public static var data:OptionSaved = {};

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