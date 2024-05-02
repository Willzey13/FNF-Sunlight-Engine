package states;

import data.Conductor;
import data.MusicBeatState;
import openfl.Assets;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;

import ui.Discord.DiscordClient;
import ui.Alphabet;

class TitleState extends MusicBeatState
{
	static var intro:Bool = false;
	var gf:FlxSprite;
	var curWacky:Array<String> = [];

	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var wackyImage:FlxSprite;

	var blackScreen:FlxSprite;
	static var introEnded:Bool = false;

	override function create()
	{
		super.create();
		Saved.init();

		if(!introEnded) 
		{
			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
				Configs.playMusic("freakyMenu");
			});
		}

		DiscordClient.changePresence("In Game Title", null);

		var allTexts:Array<String> = CoolUtil.coolTextFile('data/introText');
		curWacky = allTexts[FlxG.random.int(0, allTexts.length - 1)].split('--');

		Conductor.setBPM(115);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		gf = new FlxSprite();
		gf.frames = Paths.getSparrowAtlas('menu/title/gfDanceTitle');
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gf.animation.addByIndices('danceRight','gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gf.x = FlxG.width - gf.width - 20;
		gf.antialiasing = Saved.gameSettings.get("Antialiasing");
		gf.screenCenter(Y);
		add(gf);
		gf.animation.play('danceLeft');

		blackScreen = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		blackScreen.screenCenter();
		add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('menu/title/newgrounds_logo'));
		ngSpr.antialiasing = Saved.gameSettings.get("Antialiasing");
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		if(introEnded)
			skipIntro(true);
	}

	var pressedEnter:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(FlxG.sound.music != null)
			if(FlxG.sound.music.playing)
				Conductor.songPosition = FlxG.sound.music.time;
		
		if(FlxG.keys.justPressed.ENTER)
		{
			if(introEnded)
			{
				if(!pressedEnter)
				{
					pressedEnter = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					new FlxTimer().start(2.0, function(tmr:FlxTimer)
					{
						closedState = true;
						MusicBeatState.switchState(new MainMenuState());
					});
				}
			}
			else
				skipIntro();
		}
	}

	var danceLeft:Bool = false;

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	public static var closedState:Bool = false;
	private var sickBeats:Int = 0;
	override function beatHit()
	{
		super.beatHit();
		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					createCoolText(['Toffe And', 'Willzey']);
				case 3:
					addMoreText('Present');
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['In association', 'with'], -40);
				case 7:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
				case 11:
					addMoreText(curWacky[1]);
				case 12:
					deleteCoolText();
				//case 13:
					addMoreText('Friday');
				case 13:
					addMoreText('Night');
				case 14:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';
				case 15:
					addMoreText('Sunlight Engine');

				case 16:
					skipIntro();
			}
		}

		danceLeft = !danceLeft;

		if (danceLeft)
			gf.animation.play('danceRight');
		else
			gf.animation.play('danceLeft');
	}

	public function skipIntro(force:Bool = false)
	{
		if(introEnded && !force) return;
		introEnded = true;

		remove(ngSpr);
		remove(credGroup);

		addMoreText('');

		FlxG.camera.flash(FlxColor.WHITE, 4);
		//ngSpr.visible = false;
		remove(blackScreen);
	}
}