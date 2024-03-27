package load.hud;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import data.Conductor;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public function new()
	{
		super();
		//reloadNote(0, 0, "default");
	}

	public var prevNote:Note;
	public var noteSize:Float = 1.0;
	public var assetModifier:String = "base";
	public static var swagWidth:Float = 160 * 0.7;
	
	public function reloadNote(songTime:Float, noteData:Int, ?noteType:String = "default", ?assetModifier:String = "base"):Note
	{
		var storedPos:Array<Float> = [x, y];
		this.songTime = initialSongTime = songTime;
		this.noteData = noteData;
		this.noteType = noteType;
		this.assetModifier = assetModifier;
		noteSize = 1.0;
		mustMiss = false;

		var direction:String = Configs.getDirection(noteData);
		var direColor:String = Configs.getNotesColor(noteData);
		antialiasing = FlxSprite.defaultAntialiasing;
		setAlpha();

		switch(assetModifier)
		{
			case "pixel":
				noteSize = 6;
				if(!isHold)
				{
					loadGraphic(Paths.image("hud/notes/pixel/notesPixel_Sunlight"), true, 17, 17);

					animation.add(direction, [noteData + 4], 0, false);
				}
				else
				{
					loadGraphic(Paths.image("hud/notes/pixel/notesEnds_Sunlight"), true, 7, 6);

					animation.add(direction, [noteData + (isHoldEnd ? 4 : 0)], 0, false);
				}
				antialiasing = false;
				animation.play(direction);

			default:
				switch(noteType)
				{
					default:
						noteSize = 0.7;
						frames = Paths.getSparrowAtlas("hud/notes/NOTE_assets");
						// oxi que
						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						animation.addByPrefix('purpleholdend', 'pruple end hold');
						animation.addByPrefix('greenholdend', 'green hold end');
						animation.addByPrefix('redholdend', 'red hold end');
						animation.addByPrefix('blueholdend', 'blue hold end');

						animation.addByPrefix('purplehold', 'purple hold piece');
						animation.addByPrefix('greenhold', 'green hold piece');
						animation.addByPrefix('redhold', 'red hold piece');
						animation.addByPrefix('bluehold', 'blue hold piece');
				}
		}

		switch(noteType)
		{
			case "EX Note":
				var fold:String = 'base';
				if(assetModifier == 'doido')
					fold = 'doido';
				
				noteSize = ((fold == 'doido') ? 0.95 : 0.7);
				mustMiss = true;
				frames = Paths.getSparrowAtlas('notes/$fold/hurt_notes');
				var typeName:String = (isHold ? (isHoldEnd ? "hold end" : "hold0") : direction);
				
				animation.addByPrefix('hurt', 'hurt $typeName', 0, false);
				animation.play('hurt');
		}

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play(isHoldEnd ? "purpleholdend" : 'purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play(isHoldEnd ? "blueholdend" : 'blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play(isHoldEnd ? "greenholdend" : 'greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play(isHoldEnd ? "redholdend" : 'redScroll');
		}

		if (isHold || isHoldEnd)
		{
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (isHold)
			{
				switch (noteData)
				{
					case 0:
						animation.play(isHoldEnd ? "purpleholdend" : 'purplehold');
					case 1:
						animation.play(isHoldEnd ? "blueholdend" : 'bluehold');
					case 2:
						animation.play(isHoldEnd ? "greenholdend" : 'greenhold');
					case 3:
						animation.play(isHoldEnd ? "redholdend" : 'redhold');
				}
			}
		}
		//if(isHold)
		//	antialiasing = false;

		scale.set(noteSize, noteSize);
		updateHitbox();

		moves = false;
		setPosition(storedPos[0], storedPos[1]);
		return this;
	}

	// you can use this to fix 
	public var noteOffset:FlxPoint = new FlxPoint(0,0);
	
	public var noteAngle:Float = 0;
	
	public var initialSongTime:Float = 0;
	public var songTime:Float = 0;
	public var noteData:Int = 0;
	public var noteType:String = "default";

	public function setSongOffset():Void
		songTime = initialSongTime - Saved.data.get('Song Offset');

	// in case you want to avoid notes this will do
	public var mustMiss:Bool = false;

	// doesnt actually change the scroll speed, just changes the hold note size
	public var scrollSpeed:Float = Math.NEGATIVE_INFINITY;
	
	// hold note stuff
	public var noteCrochet:Float = 0;
	public var isHold:Bool = false;
	public var isHoldEnd:Bool = false;
	public var holdLength:Float = 0;
	public var holdHitLength:Float = 0;
	
	public var children:Array<Note> = [];
	public var parentNote:Note = null;

	// instead of mustPress, the strumline is determined by their strumlineID's
	public var strumlineID:Int = 0;
	
	public var missed:Bool = false;
	public var gotHit:Bool = false;
	public var gotHeld:Bool = false;
	
	public var spawned:Bool = false;
	//public var canDespawn:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	public var realAlpha:Float = 1;
	public function setAlpha():Void
	{
		var multAlpha:Float = 1;
		if(isHold)
			multAlpha = (gotHit ? 0.2 : 0.7);
		if(missed)
			multAlpha = 0.2;
		
		// change realAlpha instead of alpha for this effect
		alpha = realAlpha * multAlpha;
	}

	public function checkActive():Void
	{
		visible = active = alive = (Math.abs(songTime - Conductor.songPosition) < Conductor.crochet * 2);

		// making sure you dont see it anymore
		if(gotHit && !isHold)
			visible = false;
	}
	
	// sets (probably) every value the note has to the default value
	public function resetNote()
	{
		visible = true;
		missed = false;
		gotHit = false;
		gotHeld = false;
		holdHitLength = 0;
		//spawned = false;
		
		clipRect = null;
		setAlpha();
	}
}