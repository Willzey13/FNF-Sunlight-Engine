package substate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
import data.MusicBeatSubstate;
import ui.Alphabet;
import states.*;
//import state.menus.*;
import sys.thread.Mutex;
import sys.thread.Thread;

class PauseSubstate extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var menuItems:Array<String> = [
		'Resume', 
		'Restart Song', 
		'Exit to menu'
	];

	var curSelected:Int = 0;
	var pauseMusic:FlxSound;
	var mutex:Mutex;

	public function new()
	{
		super();

		mutex = new Mutex();
		Thread.create(function()
		{
			mutex.acquire();
			pauseMusic = new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song.toLowerCase()), true, true);
			pauseMusic.play(Conductor.songPosition);
			pauseMusic.pitch = 0.9;
			FlxG.sound.list.add(pauseMusic);
			pauseMusic.volume = 0;
			mutex.release();
		});

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += CoolUtil.dashToSpace(PlayState.SONG.song);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += Configs.difficultyFromNumber(PlayState.storyDifficulty);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var levelDeaths:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		levelDeaths.text += "Blue balled: " + PlayState.deathCounter;
		levelDeaths.scrollFactor.set();
		levelDeaths.setFormat(Paths.font('vcr.ttf'), 32);
		levelDeaths.updateHitbox();
		add(levelDeaths);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		levelDeaths.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		levelDeaths.x = FlxG.width - (levelDeaths.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelDeaths, {alpha: 1, y: levelDeaths.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		if (PlayState.charting)
			menuItems.push("Botplay");

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(90, 320 + (20 * i), menuItems[i], true);
			songText.isMenuItem = true;
			songText.targetY = i - curSelected;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = Controls.justPressed("UI_UP");
		var downP = Controls.justPressed("UI_DOWN");
		var accepted = Controls.justPressed("ACCEPT");
		var back:Bool = Controls.justPressed("BACK");
		if (back)
		{
			close();
			return;
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{ 
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{ 
				case "Resume":
					close();
				case "Restart Song":
					MusicBeatState.switchState(new PlayState());
				case "Botplay":
					PlayState.botplay = (PlayState.botplay == 0) ? 1 : 0;
				case "Change Difficulty":
					
				case "Exit to menu":
					//PlayState.resetMusic();
					PlayState.deathCounter = 0;
					MusicBeatState.switchState(new FreeplayState());
			}
		}

		if (pauseMusic != null && pauseMusic.playing)
		{
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;
		}
	}

	override function destroy()
	{
		if (pauseMusic != null)
			pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = flixel.math.FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

		var bullShit:Int = 0;
		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		//
	}
}
