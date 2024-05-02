package load.hud;

class NoteSplash extends FlxSprite
{
	public var data:Int = 0;
	public var alphaSplash:Float = 0;
	public static var configsReset:Array<String> = [];

	public function new()
	{
		super();
		alphaSplash = 0.6;
	}

	public static function resetConfigs()
	{
		configsReset = [];
	}

	public function splashPlay(note:Note, splashTexture:String = 'default')
	{
		var directionSplash = directionMinuscule(note.noteData);
		data = note.noteData;
		switch (splashTexture)
		{
			case "pixel":
				//nothing :>
			default:
				frames = Paths.getSparrowAtlas("hud/notes/noteSplashes");

				animation.addByPrefix('note1-0', 'note impact 1 blue', 24, false);
				animation.addByPrefix('note2-0', 'note impact 1 green', 24, false);
				animation.addByPrefix('note0-0', 'note impact 1 purple', 24, false);
				animation.addByPrefix('note3-0', 'note impact 1 red', 24, false);
				animation.addByPrefix('note1-1', 'note impact 2 blue', 24, false);
				animation.addByPrefix('note2-1', 'note impact 2 green', 24, false);
				animation.addByPrefix('note0-1', 'note impact 2 purple', 24, false);
				animation.addByPrefix('note3-1', 'note impact 2 red', 24, false);

				antialiasing = Saved.gameSettings.get("Antialiasing");
				scale.set(0.7,0.7);
				updateHitbox();
		}

		if (note.isSustain == false)
			idlePlay(note.noteData);
	} 

	inline public static function directionMinuscule(i:Int)
		return ["purple", "blue", "green", "red"][i];

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(animation.finished)
		{
			visible = false;
		}
		setAlpha(0.6);
	}

	public function setAlpha(?bah:Float):Void
	{
		alpha = alphaSplash;
		alphaSplash = bah;
	}

	public function idlePlay(noteData:Int = 0)
	{
		alpha = alphaSplash;
		visible = true;

		animation.play('note' + noteData + '-' + FlxG.random.int(0, 1), true);
		//animation.curAnim.frameRate += FlxG.random.int(-2, 2);
		updateHitbox();

		//offset.set(width * 0.3, height * 0.3);
	}
}