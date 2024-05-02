package load.hud;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;
	public var charName:String = "";

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.charName = char;
		updateIcon(char, isPlayer);
	}

	public function changeIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		updateIcon(char, isPlayer);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function updateIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		var trimmedCharacter:String = char;
		if (trimmedCharacter.contains('-'))
			trimmedCharacter = trimmedCharacter.substring(0, trimmedCharacter.indexOf('-'));

		var iconPath = char;
		if (!FileSystem.exists(Paths.getPath('images/icons/icon-' + iconPath + '.png', IMAGE)))
		{
			if (iconPath != trimmedCharacter)
				iconPath = trimmedCharacter;
			else
				iconPath = 'face';
			trace('$char icon trying $iconPath instead you fuck');
		}

		var graphic = Paths.image('icons/icon-' + iconPath);
		loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));

		iconOffsets[0] = (width - 150) / 2;
		iconOffsets[1] = (height - 150) / 2;
		updateHitbox();

		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		antialiasing = true;

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function getCharacter():String {
		return charName;
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}
}
