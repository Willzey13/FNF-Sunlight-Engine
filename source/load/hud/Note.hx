package load.hud;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import states.PlayState;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public var parentNote:Note = null;
	public var strumTime:Float = 0;
	public var multSpeed(default, set):Float = 1;

	public var mustPress:Bool = false;
	public var mustMiss:Bool = false;
	public var noteAngle:Float = 0;
	public var noteCrochet:Float = 0;
	public var noteData:Int = 0;
	
	public var noteType:String = "default";
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	private var willMiss:Bool = false;

	public var altNote:Bool = false;
	public var gfNote:Bool = false;
	public var invisNote:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustain:Bool = false;
	public var isSustainEnd:Bool = false;
	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	
	public var noteID:Int = 0;
	public var missed:Bool = false;
	public var gotHit:Bool = false;
	public var gotHeld:Bool = false;

	public var children:Array<Note> = [];

	public var sizeNote:Float = 0;
	public var strumline:Int = 0;
	public static var arrowColors:Array<Float> = [1, 1, 1, 1];
	public var scrollSpeed:Float = Math.NEGATIVE_INFINITY;

	//code Psych
	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		//trace('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) //haha funny twitter shit
	{
		if(isSustain && animation.curAnim != null && animation.curAnim.name != 'end')
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}
	//End

	public function new(strumTime:Float, noteData:Int, noteType:String = "default", strumline:Int, ?isSustain:Bool = false, ?prevNote:Note)
	{
		super();
		reload(strumTime, noteData, noteType, strumline, isSustain, prevNote);
	}

	public var notePosition:FlxPoint = new FlxPoint(0,0);
	public var holdLength:Float = 0;
	public var curTextureNote:String = ""; //nothing :)
	
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick

	//plic function new(strumTime:Float, index:Int, noteType:String, strumline:Int, ?isSustain:Bool = false, ?prevNote:Note)
	public function reload(strumTime:Float, noteData:Int, noteType:String = "default", strumline:Int, ?isSustain:Bool = false, ?prevNote:Note)
	{
		this.strumline = strumline;
		this.prevNote = prevNote;
		this.noteType = noteType;
		this.isSustain = isSustain;
		this.strumTime = strumTime;
		this.noteData = noteData;

		//screenCenter();

		if (prevNote == null)
			prevNote = this;

		var curTextureNote:String = PlayState.skinNotes;
		this.curTextureNote = curTextureNote;
		switch (curTextureNote)
		{
			case "pixel":
				loadGraphic(Paths.image('hud/notes/pixel/notesPixel'));
				sizeNote = 6;

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustain)
				{
					loadGraphic(Paths.image('hud/notes/pixel/arrowEnds'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				updateHitbox();

			default:
				frames = Paths.getSparrowAtlas('hud/notes/NOTE_assets');

				if (curTextureNote == "sunlight"){
					frames = Paths.getSparrowAtlas('hud/notes/SunLight_Note_Assets');
				}

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

				antialiasing = true;
				sizeNote = 0.7;
				updateHitbox();
		}

		//trace('Type of texture load ${curTextureNote}');
		//trace(isSustainEnd ? "This is Sustain Note End: " + isSustainEnd : "This is Sustain Note: " + isSustain);

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		if (isSustain)
		{
			//noteScore * 0.2;
			alpha = 0.6;
			//x += width / 2;

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

			//x -= width / 2;

			if (isSustain)
			{
				switch (noteData)
				{
					case 0:
						animation.play(isSustainEnd ? 'purpleholdend' : 'purplehold');
					case 1:
						animation.play(isSustainEnd ? 'blueholdend' : 'bluehold');
					case 2:
						animation.play(isSustainEnd ? 'greenholdend' : 'greenhold');
					case 3:
						animation.play(isSustainEnd ? 'redholdend' : 'redhold');
				}

				//scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				updateHitbox();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		scale.set(sizeNote, sizeNote);
	}
}
