package states.editors;

import ui.Alphabet;
import ui.Discord.DiscordClient;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;

class MenuDebug extends MusicBeatState
{
	var option:Array<String> = [
		'Stage Editor',
		'Character Editor',
		'Charter Editor'
	];

	public static var curSelect:Int = 0;
	public var newGroup:FlxTypedGroup<Alphabet>;

	override function create()
	{
		super.create();
		DiscordClient.changePresence("in MasterMenu", null);

		var bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menu/mainmenu/menuDesat'));
		bg.alpha = 0.7;
		add(bg);

		newGroup = new FlxTypedGroup<Alphabet>();
		add(newGroup);

		for (i in 0...option.length)
		{
			var thisOption:Alphabet = new Alphabet(0, 0, option[i], true);
			thisOption.screenCenter();
			thisOption.y += (90 * (i - Math.floor(option.length / 2)));
			thisOption.targetY = i - curSelect;
			thisOption.ID = i;
			thisOption.changeX = true;
			thisOption.changeY = true;
			thisOption.alpha = 0.6;
			newGroup.add(thisOption);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.justPressed("UI_UP"))
			changeSelection(-1);
		if (Controls.justPressed("UI_DOWN"))
			changeSelection(1);

		if (Controls.justPressed("ACCEPT")) 
		{
			var daSelected:String = "";
			for (item in newGroup.members) {
    			var alphabet:Alphabet = cast(item, Alphabet);
    			if (alphabet != null && alphabet.ID == curSelect) {
        			daSelected = alphabet.text; // Assumindo que você quer acessar o texto do Alphabet
    			}
			}

			switch (daSelected){
				case "Stage Editor": MusicBeatState.switchState(new StageEditor());
				case "Character Editor": MusicBeatState.switchState(new AnimationDebug());
				case "Charter Editor": MusicBeatState.switchState(new ChartingState());
			}
		}
	}

	public function changeSelection(bruh:Int = 0)
	{
		curSelect += bruh;

		curSelect = FlxMath.wrap(curSelect, 0, option.length - 1);
				
		for(item in newGroup.members)
		{
			item.alpha = 0.6;
			if(curSelect == item.ID)
				item.alpha = 1;
		}
	}
}