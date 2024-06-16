package states;

import Controls;
import data.*;
import data.Song.SwagSong;
import data.MusicBeatState;
import ui.Discord.DiscordClient;
import ui.Highscore;
import ui.Alphabet;
import load.Highscore;
import load.hud.HealthIcon;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.media.Sound;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;

using StringTools;

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, songColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songColor = songColor;
	}
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var mainColor = FlxColor.WHITE;
	private var bg:FlxSprite;
	private var scoreBG:FlxSprite;

	private var existingSongs:Array<String> = [];
	private var existingDifficulties:Array<Array<String>> = [];

	override function create()
	{
		super.create();
		//Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		Configs.playMusic('freakyMenu');

		mutex = new Mutex();
		var folderSongs:Array<String> = Paths.returnAssetsLibrary('data', 'assets');

		// addWeek[Songs - NumberWeek - Character] Songs Week FNF
		addWeek(["tutorial"], 0, ["gf"], FlxColor.fromRGB(222, 7, 54));
		addWeek(["bopeebo", "fresh", "dad-battle"], 1, ["dad"], FlxColor.fromRGB(158, 0, 142));
		addWeek(["spookeez", "south", "monster"], 2, ["spooky"], FlxColor.fromRGB(105, 97, 92));
		addWeek(["pico", "philly-nice", "blammed"], 3, ["pico"], FlxColor.fromRGB(80, 235, 100));
		addWeek(["satin-panties", "high", "milf"], 4, ["mom"], FlxColor.fromRGB(216, 85, 142));
		addWeek(["cocoa", "eggnog", "winter-horrorland"], 5, ["parents"], FlxColor.fromRGB(255, 255, 255));
		addWeek(["senpai", "roses", "thorns"], 6, ["senpai"], FlxColor.fromRGB(245, 159, 83));
		addWeek(["ugh", "guns", "stress"], 7, ["tankman"], FlxColor.WHITE);

		// addSong[Song - NumberWeek - Character] Others Songs
		addSong("debuggin",	8, "bf-pixel", FlxColor.fromRGB(7, 211, 222));

		for (i in folderSongs)
		{
			if (!existingSongs.contains(i.toLowerCase()))
			{
				var icon:String = 'gf';
				var chartExists:Bool = FileSystem.exists(Paths.songJson(i, i));
				if (chartExists)
				{
					var castSong:SwagSong = Song.loadFromJson(i, i);
					icon = (castSong != null) ? castSong.player2 : 'gf';
					//addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, FlxColor.WHITE);
				}
			}
		}

		DiscordClient.changePresence('FREEPLAY MENU', null);

		bg = new FlxSprite().loadGraphic(Paths.image('menu/mainmenu/menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.isMenuItem = true;
			songText.targetY = i - curSelected;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);

			songText.x = FlxG.width + 200;
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		//add(selector);
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, ?songColor:FlxColor)
	{
		var coolDifficultyArray = [];
		for (i in Configs.difficultyArray)
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + i))
				|| (FileSystem.exists(Paths.songJson(songName, songName))))
				coolDifficultyArray.push(i);

		if (coolDifficultyArray.length > 0)
		{
			songs.push(new SongMetadata(songName, weekNum, songCharacter, songColor));
			existingDifficulties.push(coolDifficultyArray);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?songColor:FlxColor)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		if (songColor == null)
			songColor = FlxColor.WHITE;

		var num:Array<Int> = [0, 0];
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num[0]], songColor);

			if (songCharacters.length != 1)
				num[0]++;
			//if (songColor.length != 1)
				//num[1]++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxTween.color(bg, 0.35, bg.color, mainColor);

		if (Controls.justPressed("UP"))
			changeSelection(-1);
		if (Controls.justPressed("DOWN"))
			changeSelection(1);

		if (Controls.justPressed("LEFT"))
			changeDiff(-1);
		if (Controls.justPressed("RIGHT"))
			changeDiff(1);

		if (Controls.justPressed("BACK"))
		{
			threadActive = false;
			MusicBeatState.switchState(new MainMenuState());
		}

		if (Controls.justPressed("ACCEPT"))
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(),
				Configs.difficultyArray.indexOf(existingDifficulties[curSelected][curDifficulty]));

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			threadActive = false;

			MusicBeatState.switchState(new PlayState());
		}

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.width = scoreText.width + 8;
		scoreBG.x = FlxG.width - scoreBG.width;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
	}

	var lastDifficulty:String;

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (lastDifficulty != null && change != 0)
			while (existingDifficulties[curSelected][curDifficulty] == lastDifficulty)
				curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = existingDifficulties[curSelected].length - 1;
		if (curDifficulty > existingDifficulties[curSelected].length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		diffText.text = '< ' + existingDifficulties[curSelected][curDifficulty] + ' >';
		lastDifficulty = existingDifficulties[curSelected][curDifficulty];
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		//selector.y = (70 * curSelected) + 30;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		mainColor = songs[curSelected].songColor;
		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			//item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				//item.setGraphicSize(Std.int(item.width));
			}
		}

		changeDiff();
	}

	var playingSongs:Array<FlxSound> = [];
}
