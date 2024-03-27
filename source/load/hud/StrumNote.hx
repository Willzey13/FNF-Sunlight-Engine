package load.hud;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class StrumNote extends FlxSprite
{
	public function new()
	{
		super();
	}

	public var strumData:Int = 0;
	public var assetModifier:String = "default";

	// use these to modchart
	public var strumSize:Float = 1.0;
	public var scaleOffset:FlxPoint = new FlxPoint(0,0);
	public var initialPos:FlxPoint = new FlxPoint(0,0);
	
	public var strumAngle:Float = 0;
	
	public function reloadStrum(strumData:Int, ?assetModifier:String = "default"):StrumNote
	{
		this.strumData = strumData;
		this.assetModifier = assetModifier;
		strumSize = 1.0;

		var direction = Configs.getNotesDirection(strumData);
		var direct = Configs.getDirection(strumData);

		antialiasing = FlxSprite.defaultAntialiasing;

		switch(assetModifier)
		{
			case "pixel":
				strumSize = 6;
				loadGraphic(Paths.image("hud/notes/pixel/notesPixel_Sunlight"), true, 17, 17);

				animation.add("static",  [strumData], 						12, false);
				animation.add("pressed", [strumData + 8], 					12, false);
				animation.add("confirm", [strumData + 12, strumData + 16], 	12, false);

				antialiasing = false;

			default:
				strumSize = 0.7;
				frames = Paths.getSparrowAtlas("hud/notes/NOTE_assets");
				
				switch(assetModifier)
				{
					case "sunlight":
						frames = Paths.getSparrowAtlas("hud/notes/SunLight_Note_Assets");
				}

				animation.addByPrefix("static",  'arrow' + '$direction',  	24, false);
				animation.addByPrefix("pressed", '$direct' + ' press',		12, false);
				animation.addByPrefix("confirm", '$direct' + ' confirm', 	24, false);
		}
		playAnim("static"); // once to get the scale offset

		scale.set(strumSize, strumSize);
		updateHitbox();
		scaleOffset.set(offset.x, offset.y);

		playAnim("static"); // twice to use the scale offset

		return this;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		//angle += elapsed * 1000 * 180 / data.Conductor.crochet;
		updateOffset();
	}
	
	public function playAnim(animName:String, force:Bool = false)
	{
		animation.play(animName, force);
		updateOffset();
	}
	
	public function updateOffset()
	{
		updateHitbox();
		offset.x += frameWidth * scale.x / 2;
		offset.y += frameHeight* scale.y / 2;
	}
}