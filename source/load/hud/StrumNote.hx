package load.hud;

import states.PlayState;
import flixel.group.FlxGroup.FlxTypedGroup;

class StrumNote extends FlxGroup
{
	public var strumPos:FlxPoint = new FlxPoint(0,0);
	public var downscroll:Bool = false;
	public var scrollSpeed:Float = 2.8;

	public var notesGrp:FlxTypedGroup<NoteStrum>;
	public var noteGroup:FlxTypedGroup<Note>;
	public var holdGroup:FlxTypedGroup<Note>;
	public var allNotes:FlxTypedGroup<Note>;
	public var splashNotes:FlxTypedGroup<NoteSplash>;

	public var x:Float = 0;
	public var y:Float = 0;

	public var isPlayer:Bool = false;
	public var botplay:Int = 0;
	//public var gayMode:Bool = true;

	public var missed:Bool = false;
	public var curTexture = PlayState.skinNotes;
	public var character:Character;

	public var strumAmountNotes:Int = 4;

	public function new(?curTexture:String = "default", ?character:Character, ?downscroll:Bool, ?isPlayer:Bool = false, ?botplay:Int = 1, scrollSpeed:Float = 2.8)
	{
		super();
		this.isPlayer = isPlayer;
		this.botplay = botplay;
		this.curTexture = curTexture;
		this.character = character;
		this.downscroll = downscroll;

		allNotes = new FlxTypedGroup<Note>();
		add(notesGrp = new FlxTypedGroup<NoteStrum>());
		add(holdGroup = new FlxTypedGroup<Note>());
		add(noteGroup = new FlxTypedGroup<Note>());
		add(splashNotes = new FlxTypedGroup<NoteSplash>());

		for (i in 0...strumAmountNotes)
		{
			var notes:NoteStrum = new NoteStrum(i, curTexture);
			//notes.screenCenter();
			notesGrp.add(notes);
		}

		noteHitboxUpdate();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function noteHitboxUpdate()
	{
		for(strum in notesGrp)
		{
			strum.y = (!downscroll ? 100 : FlxG.height - 100);
			
			strum.x = x;
			strum.x += Configs.noteWidth() * strum.data;
			
			strum.x -= (Configs.noteWidth() * (notesGrp.members.length - 1)) / 2;
			
			strum.initialPos.set(strum.x, strum.y);
		}
	}

	public function addNote(note:Note)
	{
		allNotes.add(note);
		if(note.isSustain)
			holdGroup.add(note);
		else
			noteGroup.add(note);
	}

	public function addSplash(note:Note)
	{
		//nothing
		switch (Saved.gameSettings.get('Note Splashes'))
		{
			case false: 
				if(!isPlayer) 
					return;
			case true: 
				return;
		}
		var pref:String = '-' + directionMinuscule(note.noteData) + '-' + note.noteID;
		if (!NoteSplash.configsReset.contains(note.curTextureNote + pref))
		{
			NoteSplash.configsReset.push(note.curTextureNote + pref);

			var splashs:NoteSplash = new NoteSplash();
			splashs.splashPlay(note, curTexture);
			splashNotes.add(splashs);
		}

		for(splash in splashNotes.members)
		{
			if (splash.data == note.noteData)
			{
				var thisStrum = notesGrp.members[splash.data];
				splash.x = thisStrum.x - splash.width / 2;
				splash.y = thisStrum.y - splash.height/ 2;

				splash.idlePlay(note.noteData);
			}
		}
	}

	public function removeNote(note:Note)
	{
		allNotes.remove(note);
		if(note.isSustain)
			holdGroup.remove(note);
		else
			noteGroup.remove(note);
	}

	inline public static function direction(i:Int)
		return ["LEFT", "DOWN", "UP", "RIGHT"][i];

	inline public static function directionMinuscule(i:Int)
		return ["left", "down", "up", "right"][i];
}

class NoteStrum extends FlxSprite
{
	public var data:Int = 0;
	public var initialPos:FlxPoint = new FlxPoint(0,0);
	public var strumAngle:Float = 0;
	public var sizeNote:Float = 0;

	public function new(data:Int, ?curTexture:String = "base")
	{
		super();
		this.data = data;

		var direction = StrumNote.direction(data);
		var namesPose = StrumNote.directionMinuscule(data);

		for (i in 0...4)
		{
			switch (curTexture)
			{
				case 'pixel':
					loadGraphic(Paths.image('hud/notes/pixel/notesPixel'), true, 17, 17);
					animation.add("confirm", [data + 12, data + 16], 12, false);
					animation.add("pressed", [data + 8], 12, false);
					animation.add("static",  [data], 12, false);

					animation.play(direction);
					antialiasing = false;
					updateHitbox();
					sizeNote = 6;

				default:
					frames = Paths.getSparrowAtlas("hud/notes/NOTE_assets");
					animation.addByPrefix('green', 'arrowUP');
					animation.addByPrefix('blue', 'arrowDOWN');
					animation.addByPrefix('purple', 'arrowLEFT');
					animation.addByPrefix('red', 'arrowRIGHT');

					antialiasing = Saved.gameSettings.get("Antialiasing");
					setGraphicSize(Std.int(width * 0.7));

					switch (Math.abs(data) % 4)
					{
						case 0:
							animation.addByPrefix('static', 'arrowLEFT');
							animation.addByPrefix('pressed', 'left press', 24, false);
							animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							animation.addByPrefix('static', 'arrowDOWN');
							animation.addByPrefix('pressed', 'down press', 24, false);
							animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							animation.addByPrefix('static', 'arrowUP');
							animation.addByPrefix('pressed', 'up press', 24, false);
							animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							animation.addByPrefix('static', 'arrowRIGHT');
							animation.addByPrefix('pressed', 'right press', 24, false);
							animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}
		}

		updateHitbox();
		scrollFactor.set();

		/*if (!isStoryMode)
		{
			y -= 10;
			alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
		}*/

		//if (isPlayer)
			//trace("A strum do bf é muito coisa de gay tlgd?");
			//playerStrums.add(babyArrow);

		animation.play('static');
		//x += 50;
		//x += ((FlxG.width / 2) * 1);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		scale.set(sizeNote, sizeNote);
		setOffsetPosition();
	}

	public function playAnim(nameAnimation:String, reforce:Bool = false)
	{
		animation.play(nameAnimation, reforce);
		setOffsetPosition();
	}

	public function setOffsetPosition()
	{
		updateHitbox();

		offset.x += frameWidth * 
		scale.x / 2;

		offset.y += frameHeight* 
		scale.y / 2;
	}
}