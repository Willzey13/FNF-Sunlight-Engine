package states;

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
import states.editors.MenuDebug;
import options.OptionsState;

using StringTools;

class CreditsState extends MusicBeatState
{
	override function create()
	{
		super.create();
		Configs.playMusic("freakyMenu");
	}

	var selectedSum:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(!selectedSum)
		{
			if(Controls.justPressed("UI_UP"))
				changeSelection(-1);
			if(Controls.justPressed("UI_DOWN"))
				changeSelection(1);
			
			if(Controls.justPressed("BACK"))
				MusicBeatState.switchState(new TitleState());
			
		}
	}
}
