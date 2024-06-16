package states;

//import subStates.OptionsSubState;
import ui.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import data.MusicBeatState;
import data.Song;
import states.editors.MenuDebug;
import options.OptionsState;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var magenta:FlxSprite;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'donate',
		'credits',
		'options'
	];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	override function create()
	{
		super.create();
		Configs.playMusic("freakyMenu");
		DiscordClient.changePresence("in Main Menu", null);
		persistentUpdate = true;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menu/mainmenu/menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = Saved.gameSettings.get("Antialiasing");
		add(bg);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menu/mainmenu/menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = Saved.gameSettings.get("Antialiasing");
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		
		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for(i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var item:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			item.scale.x = scale;
			item.scale.y = scale;
			item.frames = Paths.getSparrowAtlas('menu/mainmenu/options/menu_' + optionShit[i]);
			item.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			item.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			item.animation.play('idle');
			item.ID = i;
			item.screenCenter(X);
			menuItems.add(item);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			item.scrollFactor.set(0, scr);
			item.antialiasing = Saved.gameSettings.get("Antialiasing");
			//item.setGraphicSize(Std.int(item.width * 0.58));
			item.updateHitbox();
		}
		FlxG.camera.follow(camFollowPos, null, 1);

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Sunlight Engine V" + CoolUtil.sunlightEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' V" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);

		changeOption();
	}
	
	var selectedOption:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			//if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var debugButton:Bool = FlxG.keys.justPressed.SEVEN;
		var lerpVal:Float = Configs.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if(!selectedOption)
		{
			if(Controls.justPressed("UI_UP"))
			{
				changeOption(-1);
			}
			if(Controls.justPressed("UI_DOWN"))
			{
				changeOption(1);
			}
			
			if(Controls.justPressed("BACK"))
			{
				MusicBeatState.switchState(new TitleState());
			}
			
			if(Controls.justPressed("ACCEPT"))
			{
				if(optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad("https://ninja-muffin24.itch.io/funkin");
				}
				else
				{
					selectedOption = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					if (Saved.gameSettings.get("Flashlight")) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
					
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch(daChoice)
								{
									case "story_mode":
										MusicBeatState.switchState(new PlayState());
									case "options":
										MusicBeatState.switchState(new OptionsState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
								}
							});
						}
					});
				}
			}
		}
 
		if (debugButton)
		{
			selectedOption = true;
			MusicBeatState.switchState(new MenuDebug());
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	public function changeOption(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected += change;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
