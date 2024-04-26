package states;

//import subStates.OptionsSubState;
import ui.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import data.MusicBeatState;
import data.Song;
import states.editors.*;
import options.OptionsState;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var optionShit:Array<String> = ["story_mode", 'freeplay', "donate", "options"];
	static var curSelected:Int = 0;
	
	var grpOptions:FlxTypedGroup<FlxSprite>;
	
	var bg:FlxSprite;
	var bgMag:FlxSprite;
	var bgPosY:Float = 0;
	
	var flickMag:Float = 1;
	var flickBtn:Float = 1;
	
	override function create()
	{
		super.create();
		Configs.playMusic("freakyMenu");
		
		#if !desktop
			optionShit.remove('donate');
		#end

		persistentUpdate = persistentDraw = true;
		
		DiscordClient.changePresence("Main Menu", null);
		//persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menu/mainmenu/menuBG'));
		bg.scale.set(1.2,1.2);
		bg.updateHitbox();
		bg.antialiasing = Saved.gameSettings.get("Antialiasing");
		bg.screenCenter(X);
		add(bg);
		
		bgMag = new FlxSprite().loadGraphic(Paths.image('menu/mainmenu/menuBGMagenta'));
		bgMag.scale.set(bg.scale.x, bg.scale.y);
		bgMag.updateHitbox();
		bgMag.antialiasing = Saved.gameSettings.get("Antialiasing");
		bgMag.visible = false;
		add(bgMag);
		
		grpOptions = new FlxTypedGroup<FlxSprite>();
		add(grpOptions);
		
		var optionSize:Float = 0.9;
		if(optionShit.length > 4)
		{
			for(i in 0...(optionShit.length - 4))
				optionSize -= 0.05;
		}
		
		//trace('optionSize: ' + optionSize);
		
		for(i in 0...optionShit.length)
		{
			var item = new FlxSprite();
			item.frames = Paths.getSparrowAtlas('menu/mainmenu/options/menu_' + optionShit[i]);
			item.animation.addByPrefix('idle',  optionShit[i] + ' basic', 24, true);
			item.animation.addByPrefix('hover', optionShit[i] + ' white', 24, true);
			item.animation.play('idle');
			grpOptions.add(item);
			
			item.scale.set(optionSize, optionSize);
			item.antialiasing = Saved.gameSettings.get("Antialiasing");
			item.updateHitbox();
			
			var itemSize:Float = (90 * optionSize);
			
			var minY:Float = 70 + itemSize;
			var maxY:Float = FlxG.height - itemSize - 70;
			
			if(optionShit.length < 4)
			for(i in 0...(4 - optionShit.length))
			{
				minY += itemSize;
				maxY -= itemSize;
			}
			
			item.x = FlxG.width / 2;
			item.y = FlxMath.lerp(
				minY, // gets min Y
				maxY, // gets max Y
				i / (optionShit.length - 1) // sorts it according to its ID
			);
			
			item.ID = i;
		}
		
		var doidoSplash:String = 'Sunlight Engine ${CoolUtil.sunlightEngineVersion}';
		var funkySplash:String = 'Friday Night Funkin\' Rewritten';

		var splashTxt = new FlxText(4, 0, 0, '$doidoSplash\n$funkySplash');
		splashTxt.setFormat(CoolUtil.gFont, 18, 0xFFFFFFFF, LEFT);
		splashTxt.setBorderStyle(OUTLINE, 0xFF000000, 1.5);
		splashTxt.y = FlxG.height - splashTxt.height - 4;
		add(splashTxt);

		changeSelection();
		bg.y = bgPosY;
	}
	
	//var itemSin:Float = 0;
	var selectedSum:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(FlxG.keys.justPressed.R)
		{
			//Main.skipStuff();
			//Main.resetState();
		}

		if(Controls.justPressed("debug"))
		{
			MusicBeatState.switchState(new MenuDebug());
		}

		if(FlxG.keys.justPressed.J)
		{
			MusicBeatState.switchState(new AnimationDebug());
		}/*
		if(FlxG.keys.justPressed.K)
		{
			optionShit.push('options');
			Main.skipStuff();
			Main.switchState();
		}*/
		/*itemSin += elapsed * Math.PI;
		for(item in grpOptions.members)
		{
			item.x = (FlxG.width / 2) + (Math.sin(itemSin + item.ID) * FlxG.width / 4);
		}*/
		
		if(!selectedSum)
		{
			if(Controls.justPressed("UI_UP"))
				changeSelection(-1);
			if(Controls.justPressed("UI_DOWN"))
				changeSelection(1);
			
			if(Controls.justPressed("BACK"))
				MusicBeatState.switchState(new TitleState());
			
			if(Controls.justPressed("ACCEPT"))
			{
				if(["donate"].contains(optionShit[curSelected]))
				{
					switch(optionShit[curSelected])
					{
						case "donate":
							CoolUtil.browserLoad("https://ninja-muffin24.itch.io/funkin");
					}
				}
				else
				{
					selectedSum = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					for(item in grpOptions.members)
					{
						if(item.ID != curSelected)
							FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.cubeOut});
					}
					
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						switch(optionShit[curSelected])
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
			}
		}
		else
		{
			if(Saved.data.flashing)
			{
				if(Saved.data.flashing)
				{
					flickMag += elapsed;
					if(flickMag >= 0.15)
					{
						flickMag = 0;
						bgMag.visible = !bgMag.visible;
					}
				}
				
				flickBtn += elapsed;
				if(flickBtn >= 0.15 / 2)
				{
					flickBtn = 0;
					for(item in grpOptions.members)
						if(item.ID == curSelected)
							item.visible = !item.visible;
				}
			}
		}
		
		bg.y = FlxMath.lerp(bg.y, bgPosY, elapsed * 6);
		bgMag.setPosition(bg.x, bg.y);
	}

	public function changeSelection(change:Int = 0)
	{
		if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);
		
		bgPosY = FlxMath.lerp(0, -(bg.height - FlxG.height), curSelected / (optionShit.length - 1));
		
		for(item in grpOptions.members)
		{
			item.animation.play('idle');
			if(curSelected == item.ID)
				item.animation.play('hover');
			
			item.updateHitbox();
			// makes it offset to its middle point
			item.offset.x += (item.frameWidth * item.scale.x) / 2;
			item.offset.y += (item.frameHeight* item.scale.y) / 2;
		}
	}
}
