package options.object;

import data.FNFSprite;

using StringTools;

class Checkmark extends FNFSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('checkmark');
		antialiasing = true;

		animation.addByPrefix('false finished', 'uncheckFinished');
		animation.addByPrefix('false', 'uncheck', 12, false);
		animation.addByPrefix('true finished', 'checkFinished');
		animation.addByPrefix('true', 'check', 12, false);

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		///*
		var offsetByX = 45;
		var offsetByY = 5;
		addOffset('false', offsetByX, offsetByY);
		addOffset('true', offsetByX, offsetByY);
		addOffset('true finished', offsetByX, offsetByY);
		addOffset('false finished', offsetByX, offsetByY);
		// */
	}

	override public function update(elapsed:Float)
	{
		if (animation != null)
		{
			if (animation.finished)
				playAnim('true finished');
			if (animation.finished)
				playAnim('false finished');
		}

		super.update(elapsed);
	}
}
