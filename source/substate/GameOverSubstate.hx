package substate;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import load.Character;
import data.MusicBeatSubstate;
import data.Conductor.BPMChangeEvent;
import data.Conductor;
import states.*;

class GameOverSubstate extends MusicBeatSubstate
{
	//
	var bf:Character;
	var camFollow:FlxObject;
	var playingDeathSound:Bool = false;

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var stageSuffix:String = "";

	public function new()
	{
		var dabfType = PlayState.boyfriend.curChar;
		var daBf:String = '';
		switch (dabfType)
		{
			case 'bf-og':
				daBf = dabfType;
			case 'bf-pixel':
				daBf = 'bf-pixel-dead';
				stageSuffix = '-pixel';
			default:
				daBf = 'bf-dead';
		}

		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		//bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		//cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		Conductor.songPosition = 0;

		bf = new Character(PlayState.boyfriend.getScreenPosition().x, PlayState.boyfriend.getScreenPosition().y);
		bf.reloadChar(daBf);
		add(bf);

		PlayState.boyfriend.destroy();

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(bf.getGraphicMidpoint().x + bf.cameraPosition[0], bf.getGraphicMidpoint().y + bf.cameraPosition[1]);
		FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
		add(camFollow);

		Conductor.setBPM(100);

		FlxG.camera.followLerp = 1;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	public var startedDeath:Bool = false;
	var moveCamera:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.justPressed("ACCEPT"))
			endBullshit();

		if (Controls.justPressed("BACK"))
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;

			/*if (PlayState.isStoryMode)
			{
				Main.switchState(this, new StoryMenuState());
			}
			else*/
				MusicBeatState.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim != null)
		{
			if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && startedDeath)
				bf.playAnim('deathLoop');

			if(bf.animation.curAnim.name == 'firstDeath')
			{
				if(bf.animation.curAnim.curFrame >= 12 && !moveCamera)
				{
					FlxG.camera.follow(camFollow, LOCKON, 0.6);
					moveCamera = true;
				}

				if (bf.animation.curAnim.finished && !playingDeathSound)
				{
					startedDeath = true;
					if (PlayState.SONG.stage == 'tank')
					{
						playingDeathSound = true;
						coolStartDeath(0.2);
						
						var exclude:Array<Int> = [];
						//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

						FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
							if(!isEnding)
							{
								FlxG.sound.music.fadeIn(0.2, 1, 4);
							}
						});
					}
					else coolStartDeath();
				}
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
				{
					MusicBeatState.switchState(new PlayState());
				});
			});
			//
		}
	}
}
