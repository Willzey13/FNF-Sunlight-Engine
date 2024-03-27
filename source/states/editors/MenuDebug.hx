package states.editors;

import Controls;
import data.BackgroundEditor;
import data.Song;
import data.Conductor;
import data.MusicBeatState;
import load.Character;
import ui.Discord.DiscordClient;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;

class MenuDebug extends MusicBeatState
{
	public static var camFollow:FlxObject = new FlxObject();
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

	public var gfVersion:String = 'gf';

	public var characters:Array<Character> = [];
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public static var cameraSpeed:Float = 1.0;
	public static var defaultCamZoom:Float = 1.0;
	public static var extraCamZoom:Float = 0.0;
	public static var forcedCamPos:Null<FlxPoint>;

	public var posgfText:FlxText;
	public var posdadText:FlxText;
	public var posbfText:FlxText;
	var flxSpriteShitGroup:FlxTypedGroup<FlxSprite>;

	//editorsFreakyMenu
	var spriteNameInput:FlxUIInputText;

	override public function create()
	{
		super.create();
		Configs.playMusic("editorsMenu");
		DiscordClient.changePresence("in Stage Menu Editor", null);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		bgDefault();

		boyfriend = new Character(1501, 180);
		boyfriend.isPlayer = true;
		dad = new Character(694, 150);
		gf = new Character(962, 150);

		changeChar(boyfriend, "bf");
		changeChar(dad, "dad");
		changeChar(gf, "gf");

		characters.push(gf);
		characters.push(boyfriend);
		characters.push(dad);

		posdadText = new FlxText();
		posdadText.text = " ";
		posdadText.color = FlxColor.WHITE;
		posdadText.size = 24;

		posbfText = new FlxText();
		posbfText.text = " ";
		posbfText.color = FlxColor.WHITE;
		posbfText.size = 24;

		posgfText = new FlxText();
		posgfText.text = " ";
		posgfText.color = FlxColor.WHITE;
		posgfText.size = 24;

		Conductor.setBPM(106);

		var addToList:Array<FlxBasic> = [];
		defaultCamZoom = 0.9;
		for(char in characters)
		{	
			addToList.push(char);
		}

		for(item in addToList)
			add(item);

		add(posgfText);
		add(posdadText);
		add(posbfText);

		flxSpriteShitGroup = new FlxTypedGroup<FlxSprite>();
		add(flxSpriteShitGroup);

		makeUI();

		FlxG.mouse.visible = true;
		FlxG.camera.zoom = defaultCamZoom;
	}

	var shiftMult:Float = 1;
	var ctrlMult:Float = 1;
	var UI_box:FlxUITabMenu;

	function makeUI()
	{
		var tabs = [
			{name: 'Stage Editor', label: 'Stage Editor'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camHUD];

		UI_box.resize(450, 220);
		UI_box.x = FlxG.width - 475;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		add(UI_box);

		addStage();

		UI_box.selected_tab_id = 'Stage Editor';
		charMove = false;
	}

	function addStage()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Stage Editor";
		charMove = false;

		spriteNameInput = new FlxUIInputText(15, 15, 80, "stagecurtains");

        var addSpriteButton = new FlxButton(spriteNameInput.x + 95, spriteNameInput.y - 10, "Add Sprite", function() {
        	reloadBG();
        	charMove = false;
        });

        tab_group.add(new FlxText(15, spriteNameInput.y - 18, 0, 'Image file name:'));
        tab_group.add(addSpriteButton);
        tab_group.add(spriteNameInput);
        UI_box.addGroup(tab_group);
	}

	public function changeChar(char:Character, newChar:String = "bf", ?iconToo:Bool = true)
	{
		var storedPos = new FlxPoint(
			char.x - char.globalOffset.x,
			char.y + char.height - char.globalOffset.y
		);
		char.reloadChar(newChar);
		char.setPosition(
			storedPos.x + char.globalOffset.x,
			storedPos.y - char.height + char.globalOffset.y
		);
	}

	var spriteName:String = "";
	public function addFlxSprite(x:Float = 0, y:Float = 0, stage:String = "", sprite:String = "")
	{
		spriteName = sprite;
        var flxSprite:FlxSprite = new FlxSprite(x, y);
        flxSprite.loadGraphic(Paths.image("backgrounds/" + stage + "/"+ spriteName));
        flxSpriteShitGroup.add(flxSprite);
	}

	public function bgDefault()
	{
		//FlxG.camera.x = ;
		var bg:FlxSprite = new FlxSprite(100, -800);
		bg.loadGraphic(Paths.image("backgrounds/stage/stageback"));
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(0, 0);
		stageFront.loadGraphic(Paths.image("backgrounds/stage/stagefront"));
		add(stageFront);
	}

	public function reloadBG(sprite:String = "")
	{
		sprite = spriteNameInput.text;
		addFlxSprite(0, -700, "stage", sprite);
	}

	var charMove:Bool = true;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.sound.music != null)
            if(FlxG.sound.music.playing)
                Conductor.songPosition = FlxG.sound.music.time;

        if(FlxG.keys.pressed.SHIFT)
		{
			shiftMult = 4;
		}

		if(charMove)
		{
        	if(FlxG.mouse.overlaps(boyfriend))
        	{
        		posbfText.text = boyfriend.x + " / " + boyfriend.y;
        		posbfText.x = boyfriend.x + 50;
        		posbfText.y = boyfriend.y + 50;
        		if(FlxG.mouse.pressed){
        			boyfriend.setPosition(FlxG.mouse.getPosition().x - boyfriend.width /2,
        			FlxG.mouse.getPosition().y - boyfriend.height /2);
        			posbfText.text = boyfriend.x + " / " + boyfriend.y;
        			posbfText.x = boyfriend.x + 50;
        			posbfText.y = boyfriend.y + 50;
        		}
        	}
        	else
        	{
        		posbfText.text = " ";
        	}

        	if(FlxG.mouse.overlaps(dad))
        	{
        		posdadText.text = dad.x + " / " + dad.y;
        		posdadText.x = dad.x + 50;
        		posdadText.y = dad.y + 50;
        		if(FlxG.mouse.pressed){
        			dad.setPosition(FlxG.mouse.getPosition().x - dad.width /2,
        			FlxG.mouse.getPosition().y - dad.height /2);
        			posdadText.text = dad.x + " / " + dad.y;
        			posdadText.x = dad.x + 50;
        			posdadText.y = dad.y + 50;
        		}
        	}
        	else
        	{
        		posdadText.text = " ";
        	}

        	if(FlxG.mouse.overlaps(gf))
        	{
        		posgfText.text = gf.x + " / " + gf.y;
        		posgfText.x = gf.x + 50;
        		posgfText.y = gf.y + 50;
        		if(FlxG.mouse.pressed){
        			gf.setPosition(FlxG.mouse.getPosition().x - gf.width /2,
        			FlxG.mouse.getPosition().y - gf.height /2);
        			posgfText.text = gf.x + " / " + gf.y;
        			posgfText.x = gf.x + 50;
        			posgfText.y = gf.y + 50;
        		}
        	}
        	else
        	{
        		posgfText.text = " ";
        	}
    	}

        for (char in characters){
        	if (FlxG.mouse.overlaps(char)){
        		if(FlxG.mouse.pressed && !charMove){
        			//Nothing
        			charMove = false;
        		}
        		else
        			charMove = true;
        	}
        }

        if (Controls.pressed("LEFT")) 
        	FlxG.camera.scroll.x -= elapsed * 500 * shiftMult * ctrlMult;
		if (Controls.pressed("DOWN")) 
			FlxG.camera.scroll.y += elapsed * 500 * shiftMult * ctrlMult;
		if (Controls.pressed("RIGHT")) 
			FlxG.camera.scroll.x += elapsed * 500 * shiftMult * ctrlMult;
		if (Controls.pressed("UP")) 
			FlxG.camera.scroll.y -= elapsed * 500 * shiftMult * ctrlMult;

		if(FlxG.keys.justPressed.R && !FlxG.keys.pressed.CONTROL) 
			FlxG.camera.zoom = 1;
		else if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3) 
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom * shiftMult * ctrlMult;
			if (FlxG.camera.zoom > 3) 
				FlxG.camera.zoom = 3;
		}
		else if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1) 
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom * shiftMult * ctrlMult;
			if (FlxG.camera.zoom < 0.1) 
				FlxG.camera.zoom = 0.1;
		}
		
		function lerpCamZoom(daCam:FlxCamera, target:Float = 1.0, speed:Int = 6)
			daCam.zoom = FlxMath.lerp(daCam.zoom, target, elapsed * speed);
			
		lerpCamZoom(camGame, defaultCamZoom + extraCamZoom);
		lerpCamZoom(camHUD);
	}

	public var paused:Bool = false;
	var canPause:Bool = true;

	override function beatHit()
	{
		super.beatHit();
		if(curBeat % 4 == 0){
			boyfriend.dance();

			dad.dance();
			camZoom(0.05, 0.025);
		}
	}

	public var gfSpeed:Int = 1;

	public function camZoom(gameZoom:Float = 0, hudZoom:Float = 0)
	{
		camGame.zoom += gameZoom;
		camHUD.zoom += hudZoom;
	}
}
