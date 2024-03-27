package options;

import data.MusicBeatState;
import load.CustomFadeTransition;
import states.*;

class OptionsState extends MusicBeatState
{
    override function create()
    {
        super.create();
    }

    var contador:Int = 0;

    override function update(elapsed:Float)
    {
    	super.update(elapsed);
    
    	if (Controls.justPressed("BACK"))
    	{
    		MusicBeatState.switchState(new MainMenuState());
    	}

    	if (FlxG.keys.justPressed.Y)
    	{
    		contador = 1;
    		Saved.downScroll = !Saved.downScroll;
    	}else if (FlxG.keys.justPressed.Y && contador >= 0){
    		Saved.downScroll = !Saved.downScroll;
    	}
    }
}