package states;

import Controls;
import Main;
import ui.Discord.DiscordClient;
import data.Section.SwagSection;
import data.Song.SwagSong;
import data.Song;
import data.Conductor;
import data.MusicBeatState;
import data.Timings;
import load.Character;
import load.Stage;
import load.Saved;
import load.ChartLoader;
import load.Rating;
import substate.PauseSubstate;
import substate.GameOverSubstate;
import states.editors.ChartingState;
import states.editors.AnimationDebug;
import load.hud.Note;
import load.hud.NoteSplash;
import load.hud.Note.EventNote;
import load.hud.HealthIcon;
import load.hud.StrumNote;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.ui.FlxBar;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;

/*
*  So the playstate is what starts the music and the settings while the music plays, feel free
*  It has curState to set the stages
*  There are characters that are dad, gf, boyfriend
*  So here I already say that we got some codes from psych and forever, which in this case was 
*  things like notes like set_playbackRate and set_songSpeed etc etc.
*  Code made by Willzey me :>
*
*  Enjoy :>
*/

class PlayState extends MusicBeatState
{
	//Song Configs
	public static var SONG:SwagSong;
	public static var curStage:String = '';

	public static var isStoryMode:Bool = false;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var campaignScore:Int = 0;
	public static var storyDifficulty:Int = 2;

	//camera follow :D
	public static var camFollow:FlxObject;

	//Notes Spawn
	var unspawnCount:Int = 0;
	public var unspawnNotes:Array<Note> = [];
	public var notes:FlxTypedGroup<Note>;

	//HUD bruh
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var healthBar:FlxBar;
	public var scoreTxt:FlxText;
	public var scoreTxtTween:FlxTween;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var comboGroup:FlxSpriteGroup;

	//Strum Lines 
	public var strumlineOpponent:StrumNote;
	public var strumlinePlayer:StrumNote;
	public var strumLinesNote:FlxTypedGroup<StrumNote>;

	//Characters 
	public var characters:Array<Character> = [];
	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Character;

	public var gfVersion:String = 'gf';

	//Time Song
	public var timeTxt:FlxText;
	public var timeBG:FlxSprite;
	public var timeBar:FlxBar;
	var songPercent:Float = 0;

	//Psych Code
	public var noteKillOffset:Float = 350;
	public var songSpeed(default, set):Float = 1;

	//Botplay Configs
	public static var STRUM_X = 42;
	public var botplayTxt:FlxText;
	public var warningTxt:FlxText;
	public static var botplay:Int = 0;

	//Configs Camera
	public static var cameraSpeed:Float = 1.0;
	public static var defaultCamZoom:Float = 1.0;
	public static var extraCamZoom:Float = 0.0;
	public static var forcedCamPos:Null<FlxPoint>;

	public var stageBuild:Stage;
	public static var skinNotes = Saved.data.skinNotes;

	public var health:Float = 1;
	public var combo:Int = 0;
	public static var songLength:Float = 0;

	//The inicial Song!
	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var musicList:Array<FlxSound> = [];

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	var talking:Bool = true;
	var startedCountdown:Bool = false;
	public static var startedSong:Bool = false;
	var inCutscene:Bool = false;
	private var updateTime:Bool = true;

	public var eventNotes:Array<EventNote> = [];

	var songScore:Int = 0;
	public static var storyWeek:Int = 0;

	override public function create()
	{
		super.create();
		Timings.init();
		NoteSplash.resetConfigs();
		Paths.clearUnusedMemory();

		songSpeed = PlayState.SONG.speed;
		FlxG.camera.zoom = defaultCamZoom;

		Conductor.mapBPMChanges(SONG);
		Conductor.setBPM(SONG.bpm);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (SONG == null)
			SONG = Song.loadFromJson('debuggin-hard', 'debuggin');

		if (SONG.isPixel == true)
		{
			skinNotes = "pixel";
		}
		else
			skinNotes = "base";

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		strumLinesNote = new FlxTypedGroup();
		strumLinesNote.cameras = [camHUD];
		add(strumLinesNote);

		bgDefault();

		boyfriend = new Character(1501, -585);
		boyfriend.isPlayer = true;
		boyfriend.reloadChar(SONG.player1);

		gf = new Character(962, -507);
		gf.reloadChar(gfVersion);

		dad = new Character(694, -585);
		dad.reloadChar(SONG.player2);

		stageBuild = new Stage("stage");
		add(stageBuild);

		add(stageBuild.layers);

		if (dad.isSpectator)
			dad.setPosition(gf.x, gf.y);
		else if (stageBuild.addGirlfriend)
			characters.push(gf);

		dad.y = dad.y + dad.height;
		boyfriend.y = boyfriend.y + boyfriend.height;

		ghostTapping = Saved.gameSettings.get("Ghost Tapping");
		var downscroll:Bool = Saved.gameSettings.get("Downscroll");

		//Strum lines Characters
		strumlineOpponent = new StrumNote(skinNotes, dad, downscroll);
		strumlineOpponent.isPlayer = false;
		//strumlineOpponent.gayMode = false;
		strumlineOpponent.botplay = 1;
		strumlineOpponent.ID = 0;
		strumLinesNote.add(strumlineOpponent);
		
		strumlinePlayer = new StrumNote(skinNotes, boyfriend, downscroll);
		strumlinePlayer.isPlayer = true;
		strumlinePlayer.botplay = 0;
		strumlinePlayer.ID = 1;
		strumLinesNote.add(strumlinePlayer);

		comboGroup = new FlxSpriteGroup();
		add(comboGroup);

		characters.push(boyfriend);
		characters.push(dad);

		add(stageBuild.foreground);
		//this stage fuck very fuck lol
		curStage = "stage";
		if (SONG.stage != null)
			curStage = SONG.stage;

		daSong();

		var addToList:Array<FlxBasic> = [];
		defaultCamZoom = 0.9;
		for(char in characters)
		{	
			addToList.push(char);
		}

		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 1;
		timeTxt.borderSize = 2;

		timeBG = new FlxSprite(timeTxt.x , timeTxt.y + (timeTxt.height / 4));
		timeBG.loadGraphic(Paths.image('hud/timeBar'));
		timeBG.antialiasing = true;
		timeBG.screenCenter(X);

		timeBar = new FlxBar(timeBG.x + 4, timeBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBG.width - 8), 
			Std.int(timeBG.height - 8), this, 'songPercent', 0, 1);
		timeBar.numDivisions = 800;
		timeBar.screenCenter(X);
		timeBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
		timeBar.antialiasing = true;

		add(timeBG);
		add(timeBar);
		add(timeTxt);

		var healthBarBG = new FlxSprite(0, FlxG.height * 0.89);
		healthBarBG.loadGraphic(Paths.image('hud/healthBar'));
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.screenCenter(X);
		// healthBar
		add(healthBar);
		reloadHealthBarColors();

		iconP1 = new HealthIcon('bf', true);
		iconP1.y = healthBar.y - 75;
		add(iconP1);

		iconP2 = new HealthIcon('dad', false);
		iconP2.y = healthBar.y - 75;
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTextUpdate();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);

		botplayTxt = new FlxText(FlxG.height / 2, 153.8, 400, " ", 35);//0.89
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.screenCenter(X);
		botplayTxt.alpha = 1;
		botplayTxt.visible = false;
		botplayTxt.borderSize = 3;
		add(botplayTxt);

		warningTxt = new FlxText(0, FlxG.height * 0.79, 0, " ", 27);
		warningTxt.setFormat(Paths.font("vcr.ttf"), 27, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warningTxt.scrollFactor.set();
		warningTxt.screenCenter(X);
		warningTxt.alpha = 1;
		warningTxt.visible = false;
		warningTxt.borderSize = 2;
		add(warningTxt);

		warningTxt.text = "< Score wont't be saved with botplay active >";
		botplayTxt.text = "< BOTPLAY >";

		healthBarBG.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		warningTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		comboGroup.cameras = [camHUD];

		/*var store:Note = new Note(2, 3, "default", 1, true);
		store.cameras = [camHUD];
		store.screenCenter();
		add(store);*/

		camFollow = new FlxObject();
		followCamSection(SONG.notes[0]);
		FlxG.camera.focusOn(camFollow.getPosition());

		if (isStoryMode)
			DiscordClient.changePresence("Playing Week: " + SONG.song.toUpperCase().replace("-", " "), null);
		else
			DiscordClient.changePresence("Playing Freeplay: " + SONG.song.toUpperCase().replace("-", " "), null);

		//Conductor.setBPM(115);
		Conductor.songPosition = -Conductor.crochet * 5;
		//startSong();

		unspawnNotes = ChartLoader.generateChartType(SONG);
		unspawnNotes.sort(sortByShit);

		for(note in unspawnNotes)
		{
			var thisStrumline = strumlineOpponent;
			for(strumline in strumLinesNote)
				if(note.noteID == strumline.ID)
					thisStrumline = strumline;
			note.reload(note.strumTime, note.noteData, "default", note.strumline);
			thisStrumline.addSplash(note);
		}

		for(strumline in strumLinesNote.members)
		{
			var strumMult:Int = (strumline.downscroll ? 1 : -1);
			for(strum in strumline.notesGrp)
			{
				strum.y += Configs.noteWidth() * 0.6 * strumMult;
				strum.alpha = 0.0001;
			}
		}

		for (strumline in strumLinesNote.members) 
		{
    		var strumPos:Array<Float> = [FlxG.width / 2, FlxG.width / 4];

    		if (strumline.isPlayer) {
        		strumline.x = strumPos[0] + strumPos[1];
    		} else {
        		strumline.x = strumPos[0] - strumPos[1];
    		}

			// trace in Cmd Position StrumNotes Of Player And Opponent too
    		/*trace("bf y :" + strumlinePlayer.x +
    		"dad x :" + strumlineOpponent.x);*/

    		strumline.scrollSpeed = SONG.speed;
    		strumline.noteHitboxUpdate();
		}

		switch (SONG.song){
			default:
				startCountdown();
		}

		for(item in addToList){
			add(item);
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	public function syncSong():Void
	{
		//song conductor time :]
		if(inst.playing)
		{
			Conductor.songPosition = inst.time;
			vocals.time = Conductor.songPosition;
			inst.play();
			vocals.play();

			if(Math.abs(Conductor.songPosition - inst.time) >= 40)
				{
					trace('New resync vocals time ${Conductor.songPosition}');
				}
		}

		//Conductor finish calling endSong(); function
		if (Conductor.songPosition >= songLength){
			endingSong = true;
			endSong();
		}
	}

	var endingSong:Bool = false;

	public function bgDefault()
	{
		//FlxG.camera.x = ;
		var bg:FlxSprite = new FlxSprite(100, -800);
		bg.loadGraphic(Paths.image("backgrounds/stage/stageback"));
		bg.scrollFactor.set(0.9, 0.9);
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(0, 0);
		stageFront.loadGraphic(Paths.image("backgrounds/stage/stagefront"));
		stageFront.scale.set(1.5, 1);
		add(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(0, -700);
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.updateHitbox();
		add(stageCurtains);
	}

	public function startSong()
	{
		startedSong = true;
		checkEventNote();
		for(music in musicList)
		{
			music.stop();
			music.play();

			syncSong();

			if(paused) {
				music.pause();
			}
		}
	}

	public function endSong()
	{
		if (endingSong)
		{
			if (!isStoryMode)
			{
				MusicBeatState.switchState(new FreeplayState());
			}
			else
			{
				var difficulty:String = '-' + Configs.difficultyFromNumber(storyDifficulty).toLowerCase();
				difficulty = difficulty.replace('-normal', '');

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				CoolUtil.killMusic([inst, vocals]);
				FlxG.switchState(new PlayState());
			}
		}
	}

	public var curSong:String = "";

	public function startCountdown()
	{
		var daCount:Int = 0;
		
		var countTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			Conductor.songPosition = -Conductor.crochet * (4 - daCount);

			if(daCount == 0)
			{
				startedCountdown = true;
				for(strumline in strumLinesNote.members)
				{
					for(strum in strumline.notesGrp)
					{	
						// dad's notes spawn backwards
						var strumMult:Int = (strumline.isPlayer ? strum.data : 3 - strum.data);
						// actual tween
						FlxTween.tween(strum, {y: strum.initialPos.y, alpha: 0.7}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeOut,
							startDelay: Conductor.crochet / 2 / 1000 * strumMult,
						});
					}
				}
			}
			
			if(daCount == 0)
			{
				startedCountdown = true;
				
			}
			if(daCount == 4)
			{
				startSong();
			}

			if(daCount != 4)
			{
				var soundName:String = ["3", "2", "1", "Go"][daCount];	
				FlxG.sound.play(Paths.sound('intro$soundName'));
				
				if(daCount >= 1)
				{
					var countName:String = ["ready", "set", "go"][daCount - 1];
					
					var countSprite = new FlxSprite();
					countSprite.loadGraphic(Paths.image('hud/$countName'));
					countSprite.updateHitbox();
					countSprite.screenCenter();
					countSprite.cameras = [camHUD];
					add(countSprite);

					FlxTween.tween(countSprite, {alpha: 0}, Conductor.stepCrochet * 2.8 / 1000, {
						startDelay: Conductor.stepCrochet * 1 / 1000,
						onComplete: function(twn:FlxTween)
						{
							countSprite.destroy();
						}
					});
				}
			}

			//trace(daCount);

			daCount++;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;
	var misses:Int = 0;

	public final separator:String = " | ";
	public final finalTxt:Array<String> = ["< ", " >"];

	public function scoreTextUpdate()
	{
		scoreTxt.text = "";
		
		scoreTxt.text += finalTxt[0] + 'Score: ' + Timings.score + 
			separator + 'Accuracy: ' + Timings.accuracy + "%" + ' [${Timings.getRank()}]' + 
			separator + 'Misses: '	+ misses + finalTxt[1];

		scoreTxt.screenCenter(X);
		scoreTxt.scale.x = 1.075;
		scoreTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});
	}

	public function reloadHealthBarColors() 
	{
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	var pressed:Array<Bool> = [];
	var justPressed:Array<Bool> = [];
	var released:Array<Bool> = [];

	public var ghostTapping:Bool = true;
	public var playbackRate(default, set):Float = 1;
	public var spawnTime:Float = 2000;
	public static var charting:Bool = false;
	
	var playerSinging:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var followLerp:Float = cameraSpeed * 3 * elapsed;
		if(followLerp > 1) followLerp = 1;

		//Set Default Camera Pos And Zoom
		CoolUtil.camPosLerp(camGame, camFollow, followLerp);
		CoolUtil.setLerpCamZoom(camGame, defaultCamZoom + extraCamZoom);
		CoolUtil.setLerpCamZoom(camHUD);

		if (Controls.justPressed("BACK"))
		{
			paused = true;
			openSubState(new PauseSubstate());
		}

		if(startedCountdown) Conductor.songPosition += elapsed * 1000;

		if (FlxG.keys.justPressed.B) {
    		botplay = (botplay == 0) ? 1 : 0;
    		strumlinePlayer.botplay = botplay;

    		if (Saved.gameSettings.get("Botplay Visible")) 
    			botplayTxt.visible = true;
    			warningTxt.visible = true;
		}

		if (FlxG.keys.justPressed.SEVEN){
			charting = true;
			MusicBeatState.switchState(new ChartingState());
		}

		if (strumlinePlayer.botplay == 1){
			if (!Saved.gameSettings.get("Botplay Visible")) 
    			botplayTxt.visible = true;
    			warningTxt.visible = true;
    			warningTxt.updateHitbox();
    			warningTxt.screenCenter(X);
		}
		else 
		{
			warningTxt.visible = false;
			botplayTxt.visible = false;
		}

		pressed = [
			Controls.pressed("LEFT"),
			Controls.pressed("DOWN"),
			Controls.pressed("UP"),
			Controls.pressed("RIGHT"),
		];
		justPressed = [
			Controls.justPressed("LEFT"),
			Controls.justPressed("DOWN"),
			Controls.justPressed("UP"),
			Controls.justPressed("RIGHT"),
		];
		released = [
			Controls.released("LEFT"),
			Controls.released("DOWN"),
			Controls.released("UP"),
			Controls.released("RIGHT"),
		];

		if (FlxG.keys.justPressed.SPACE){
			boyfriend.playAnim('hey');
		}

		if(startedCountdown)
		{
			var lastSteps:Int = 0;
			var curSect:SwagSection = null;
			for(section in SONG.notes)
			{
				if(curStep >= lastSteps)
					curSect = section;

				lastSteps += section.lengthInSteps;
			}
			if(curSect != null)
			{
				followCamSection(curSect);
			}

			checkEventNote();
		}

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, Configs.boundTo(1 - (elapsed * 9 ), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, Configs.boundTo(1 - (elapsed * 9 ), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		//bah diogotv lol
		health = FlxMath.bound(health, 0, 2);

		if(unspawnCount < unspawnNotes.length)
		{
			var unsNote = unspawnNotes[unspawnCount];
			
			var thisStrumline = strumlineOpponent;
			for(strumline in strumLinesNote)
				if(unsNote.noteID == strumline.ID)
					thisStrumline = strumline;
			
			var spawnTime:Int = 3200;
			if(thisStrumline.scrollSpeed <= 1.5)
				spawnTime *= 2;
			
			if(unsNote.strumTime - Conductor.songPosition <= spawnTime)
			{
				unsNote.y = FlxG.height * 4;
				//unsNote.spawned = true;
				thisStrumline.addNote(unsNote);
				unspawnCount++;
			}
		}

		for (strumline in strumLinesNote.members) 
		{
    		if (strumline.isPlayer) {
        		strumline.botplay = botplay;
    		}

            for (note in strumline.allNotes) {
                var despawnTime:Int = 300;
                
                if (Conductor.songPosition >= note.strumTime + note.holdLength + Conductor.crochet + despawnTime) {
                    if (!note.gotHit && !note.missed && !note.mustMiss && strumline.botplay == 0) {
                        missNote(note, strumline);
                    }
                    
                    note.clipRect = null;
                    strumline.removeNote(note);
                    note.destroy();
                    continue;
                }
                
                //note.set_alpha();
                note.updateHitbox();
                note.offset.x += note.frameWidth * note.scale.x / 2;
                if (note.isSustain) {
                    note.offset.y = 0;
                    note.origin.y = 0;
                } else {
                    note.offset.y += note.frameHeight * note.scale.y / 2;
                }
            }
            
            for(hold in strumline.holdGroup)
			{
				if(hold.scrollSpeed != strumline.scrollSpeed)
				{
					hold.scrollSpeed = strumline.scrollSpeed;
					
					if(!hold.isSustainEnd)
					{
						var newHoldSize:Array<Float> = [
							hold.frameWidth * hold.scale.x,
							hold.noteCrochet * (strumline.scrollSpeed * 0.45) + 1
						];
						
						hold.setGraphicSize(Math.floor(newHoldSize[0]), Std.int(newHoldSize[1]));
					}
					
					hold.updateHitbox();
				}
				
				var holdParent = hold.parentNote;
				if(holdParent != null)
				{
					var thisStrum = strumline.notesGrp.members[hold.noteData];
					
					if(holdParent.gotHeld && !hold.missed)
					{
						hold.gotHeld = true;
						
						hold.sustainLength = (Conductor.songPosition - hold.strumTime);
							
						var daRect = new FlxRect(
							0, 0,
							hold.frameWidth,
							hold.frameHeight
						);
						
						var holdID:Float = hold.ID;
						if(hold.isSustainEnd)
							holdID -= 0.4999; // 0.5
						
						// calculating the clipping by how much you held the note
						var minSize:Float = hold.sustainLength - (hold.noteCrochet * holdID);
						var maxSize:Float = hold.noteCrochet;
						if(minSize > maxSize)
							minSize = maxSize;
						
						if(minSize > 0)
							daRect.y = (minSize / maxSize) * hold.frameHeight;
						
						hold.clipRect = daRect;
						
						//if(hold.holdHitLength >= holdParent.holdLength - Conductor.stepCrochet)
						var notPressed = !pressed[hold.noteData] && strumline.isPlayer;
						var holdPercent:Float = (hold.sustainLength / holdParent.holdLength);

						if (hold.isSustain && !notPressed)
							onNoteHold(hold, strumline);
						
						if(notPressed || holdPercent >= 1.0)
						{
							if(holdPercent > 0.3)
							{
								if(hold.isSustainEnd && !hold.gotHit)
									goodNoteHit(hold, strumline);
								hold.missed = false;
								hold.gotHit = true;
							}
							else
							{
								missNote(hold, strumline);
							}
						}
					}
					
					if(holdParent.missed && !hold.missed)
						missNote(hold, strumline);
				}
			}
			
            for (note in strumline.noteGroup) {
                var thisStrum = strumline.notesGrp.members[note.noteData];
                
                // follows the strum
                var offsetX = note.notePosition.x;
                var offsetY = (note.strumTime - Conductor.songPosition) * (strumline.scrollSpeed * 0.45);
                // offsetY *= downMult;
                
                var noteAngle:Float = (note.noteAngle + thisStrum.strumAngle);
                if (strumline.downscroll) {
                    noteAngle += 180;
                }
                
                note.angle = thisStrum.angle;
                setNotePosition(note, thisStrum, noteAngle, offsetX, offsetY);
                
                // aligns the hold notes
                for (hold in note.children) {
                    var offsetX = note.notePosition.x;
                    var offsetY = hold.noteCrochet * (strumline.scrollSpeed * 0.45) * hold.ID;
                    
                    hold.angle = -noteAngle;
                    setNotePosition(hold, thisStrum, noteAngle, offsetX, offsetY);
                }
                
                if (strumline.botplay == 1) {
                    // hitting notes automatically
                    if (note.strumTime - Conductor.songPosition <= 0 && !note.gotHit && !note.mustMiss) {
                        if(!note.mustMiss)
							goodNoteHit(note, strumline);
						else
							missNote(note, strumline);
                    }
                } else {
                    // missing notes automatically
                    if (Conductor.songPosition >= note.strumTime + Timings.getTimings("good")[1]
					&& !note.gotHit && !note.missed && !note.mustMiss) 
					{
                        missNote(note, strumline);
                    }
                }
                
                // doesn't actually do anything
                if (note.scrollSpeed != strumline.scrollSpeed) {
                    note.scrollSpeed = strumline.scrollSpeed;
                }
            }
    
    		for (strum in strumline.notesGrp) 
    		{
        		// No botplay animations
        		if (strumline.isPlayer && strumline.botplay == 0) 
        		{
            		handlePlayerStrum(strum);
        		}else{ // Botplay animations handling
            		handleBotplayStrum(strum);
        		}
    		}

    		if (justPressed.contains(true) && strumline.botplay == 0 && strumline.isPlayer) {
    			for (i in 0...justPressed.length) {
        			if (justPressed[i]) {
            			var possibleHitNotes:Array<Note> = []; // gets the possible ones
						var canHitNote:Note = null;
						
						for(note in strumline.noteGroup)
						{
							var noteDiff:Float = (note.strumTime - Conductor.songPosition);
							
							var minTiming:Float = Timings.minTiming;
							if(note.mustMiss)
								minTiming = Timings.getTimings("good")[1];
							
							if(noteDiff <= minTiming && !note.missed && !note.gotHit && note.noteData == i)
							{
								if(note.mustMiss
								&& Conductor.songPosition >= note.strumTime + Timings.getTimings("sick")[1])
								{
									continue;
								}
								
								possibleHitNotes.push(note);
								canHitNote = note;
							}
						}
						
						// if the note actually exists then you got it
						if(canHitNote != null)
						{
							for(note in possibleHitNotes)
							{
								if(note.strumTime < canHitNote.strumTime)
									canHitNote = note;
							}

							if(!canHitNote.mustMiss)
								goodNoteHit(canHitNote, strumline);
							else
								missNote(canHitNote, strumline);
						}
						else // you ghost tapped lol
						{
							handleGhostTapping(i, strumline);
						}
        			}
    			}
			}
		}

		for(char in characters)
		{
			if(char.holdTimer != Math.NEGATIVE_INFINITY)
			{
				if(char.holdTimer < char.holdLength)
					char.holdTimer += elapsed;
				else
				{
					char.holdTimer = Math.NEGATIVE_INFINITY;
					if(!playerSinging)
						char.dance();
				}
			}
		}

		if (updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			var secondsTotal2:Int = Math.floor(songLength / 1000);
			if(secondsTotal2 < 0) secondsTotal2 = 0;

			var totalTime:Dynamic = FlxStringUtil.formatTime(secondsTotal2, false);
			timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false) + " • " + totalTime;
			timeTxt.screenCenter(X);
		}

		if (health == 0)
			openSubState(new GameOverSubstate());
	}

	// actual note functions
	function goodNoteHit(note:Note, strumline:StrumNote)
	{
    	// anything else
    	note.gotHeld = true;
    	note.gotHit = true;
    	note.missed = false;
    	if (!note.isSustain) {
        	note.visible = false;
    	} else {
        	//note.setAlpha();
    	}

    	if (note.mustMiss) return;

    	strumline.notesGrp.members[note.noteData].playAnim("confirm", true);

    	// when the player hits notes
    	vocals.volume = 1;
    	if (strumline.isPlayer) {
        	popUpRating(note, strumline, false);
        	if (!note.isSustain && Saved.data.hitsound) {
            	FlxG.sound.play(
                	Paths.sound('hitsounds/${Saved.data.typeHitsound}'),
                	Saved.data.hitsoundVolume / 10
            	);
        	}
    	}

    	if (!note.isSustain) {
        	var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
        	if (noteDiff <= Timings.getTimings("sick")[1] || strumline.botplay == 1) 
        	{
            	strumline.addSplash(note);
        	}
    	}

    	if (strumline.character != null && !note.isSustain && note.noteType != "no animation") {
        	strumline.character.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.noteData], true);
        	strumline.character.holdTimer = 0;
    	}
	}

	public var songDiff:String = "normal";
	public var ratingsData:Array<Rating> = Rating.loadDefault();

	public function popUpRating(note:Note, strumline:StrumNote, miss:Bool = false)
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
		if(strumline.botplay == 1) noteDiff = 0;

		if (!Saved.data.comboStacking && comboGroup.members.length > 0) {
			for (spr in comboGroup) {
				spr.destroy();
				comboGroup.remove(spr);
			}
		}

		if(note.isSustain && !miss)
		{
			noteDiff = Timings.minTiming;
			var holdPercent:Float = (note.sustainLength / note.holdLength);
			for(timing in Timings.holdTimings)
			{
				if(holdPercent >= timing[0] && noteDiff > timing[1])
					noteDiff = timing[1];
			}
		}

		var rating:String = Timings.diffToRating(noteDiff);
		var judge:Float = Timings.diffToJudge(noteDiff);
		if(miss)
		{
			rating = "miss";
			judge = Timings.getTimings("miss")[2];
		}

		if (!miss)
		{
			if(Timings.combo < 0)
				Timings.combo = 0;
			Timings.combo++;
			
			// regains your health only if you hold it entirely
			if(note.isSustain)
				health += 0.05 * (note.sustainLength / note.holdLength);

			/*if(rating == "sick")
				trace("Perfect Hit Note Step!!!");*/
		}

		var healthJudge:Float = 0.05 * judge;
		if(judge < 0)
			healthJudge *= 2;

		if(healthJudge < 0)
		{
			if(songDiff == "easy")
				healthJudge *= 0.5;
			if(songDiff == "normal")
				healthJudge *= 0.8;
		}

		var daRating:Rating = Timings.judgeNote(ratingsData, noteDiff / playbackRate);
		note.ratingMod = daRating.ratingMod;

		var uiPrefix:String = "hud/";
		var uiSuffix:String = '';
		var antialias:Bool = true;
		var placement:Float = FlxG.width * 0.35;

		var showRating:FlxSprite = new FlxSprite();
		showRating.loadGraphic(Paths.image(uiPrefix + daRating.image + uiSuffix));
		showRating.screenCenter();
		showRating.x = placement - 40;
		showRating.y -= 60;
		showRating.acceleration.y = 550 * playbackRate * playbackRate;
		showRating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		showRating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		showRating.visible = (!Saved.data.hideHud);
		showRating.x += Saved.data.comboOffset[0];
		showRating.y -= Saved.data.comboOffset[1];
		showRating.antialiasing = antialias;

		var xThing:Float = 0;
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'combo' + uiSuffix));
		comboSpr.screenCenter();
		comboSpr.x = placement;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!Saved.data.hideHud);
		comboSpr.x += Saved.data.comboOffset[0];//Saved.data.comboOffset[0]
		comboSpr.y -= Saved.data.comboOffset[1];
		comboSpr.antialiasing = antialias;
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
		comboGroup.add(showRating);

		showRating.setGraphicSize(Std.int(showRating.width * 0.7));
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));

		comboSpr.x = xThing + 50;
		FlxTween.tween(showRating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				showRating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});

		health += healthJudge;
		Timings.score += Math.floor(100 * judge);
		Timings.addAccuracy(judge);
		scoreTextUpdate();
	}

	function missNote(note:Note, strumline:StrumNote) 
	{
    	note.gotHit = false;
    	note.missed = true;
    	note.alpha = 0.5;
    	//trace("Note type: " + note.noteData);
    
    	// put stuff inside if(onlyOnce)
    	var onlyOnce:Bool = false;
    	//var onlyOnce:Bool = false;
		if(!note.isSustain){
			misses += 1;
			onlyOnce = true;
		}
		else
		{
			//if(note.isSustainEnd && note.sustainLength > 0)
				//onlyOnce = true;
			misses += 1;
		}
    	// onlyOnce is to prevent the game punishing you for missing a bunch of hold notes pieces
    	if (onlyOnce) {
        	vocals.volume = 0;
        
        	FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), 0.3);
        
        	if (strumline.character != null && note.noteType != "no animation") {
            	strumline.character.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.noteData] + 'miss', true);
            	strumline.character.holdTimer = 0;
        	}
        
        	// when the player misses notes
        	if (strumline.isPlayer) 
        	{
            	popUpRating(note, strumline, true);

            	switch (note.noteType) {
                	case "EX Note":
                    	//startGameOver();
                    return;
            	}
            
            	switch (SONG.song) {
                	case 'defeat':
                    	if (Timings.misses > 5) {
                        	//startGameOver();
                        	return;
                    	}
            	}
        	}
    	}
	}

	function onNoteHold(note:Note, strumline:StrumNote):Void {
		// runs until you hold it enough
		if(note.sustainLength > note.holdLength) return;
		
		var thisStrum = strumline.notesGrp.members[note.noteData];
		var thisChar = strumline.character;
		
		vocals.volume = 1;
		thisStrum.playAnim("confirm", true);
		
		// DIE!!!
		if(note.mustMiss)
			health -= 0.005;
		
		if(note.gotHit || thisChar == null) 
			return;
		
		if(note.noteType != "no animation")
		{
			if(thisChar.animation.curAnim.curFrame == thisChar.holdLoop)
				thisChar.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.noteData], false);
			
			//thisChar.holdTimer = 0;
		}
	}

	function handleGhostTapping(i:Int, strumline:StrumNote) 
	{
    	if (!ghostTapping && startedCountdown) 
    	{
        	vocals.volume = 0;

        	var note = new Note(0, i, skinNotes, 0, false);
        	//note.reload(0, i, "none", 0, false);
        	missNote(note, strumline);
    	}
	}

	//Psych Code
	public var safeFrames:Float = 10;
	public static var safeZoneOffset:Float = 0;

	function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if(generatedMusic)
		{
			vocals.pitch = value;
			inst.pitch = value;
			//opponentVocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		SONG.speed = value;
		playbackRate = value;
		FlxG.animationTimeScale = value;
		safeZoneOffset = (safeFrames / 60) * 1000 * value;
		#else
		playbackRate = 1.0; // ensuring -Crow
		#end
		return playbackRate;
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed;
			if(ratio != 1)
			{
				for (note in notes.members) note.scrollSpeed = SONG.speed / value;
				for (note in unspawnNotes) note.scrollSpeed = SONG.speed / value;
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}
	//End

	public static function setNotePosition(note:Note, strum:NoteStrum, angle:Float, offsetX:Float, offsetY:Float)
	{
    	/* Sets the note position based on the given parameters
    	* Suppose Note has properties like x and y to position the note
    	* and Strum have properties like x and y for the position of the strum
		*
    	* Calculates the new position of the note based on displacement and angle
    	*/
    	var radAngle:Float = angle * Math.PI / 180; // Converte o ângulo para radianos
    	var newX:Float = strum.x + offsetX * Math.cos(radAngle) - offsetY * Math.sin(radAngle);
    	var newY:Float = strum.y + offsetX * Math.sin(radAngle) + offsetY * Math.cos(radAngle);

    	// Sets the note position
    	note.x = newX;
    	note.y = newY;
	}

	public function daSong()
	{
		var daSong:String = SONG.song.toLowerCase();

		inst = new FlxSound();
		inst.loadEmbedded(Paths.inst(daSong), false, false);

		vocals = new FlxSound();
		if(SONG.needsVoices)
		{
			vocals.loadEmbedded(Paths.voices(daSong), false, false);
		}

		songLength = inst.length;
		function addMusic(music:FlxSound):Void
		{
			FlxG.sound.list.add(music);

			if(music.length > 0)
			{
				musicList.push(music);

				if(music.length < songLength)
					songLength = music.length;
			}

			music.play();
			music.stop();
		}

		addMusic(inst);
		addMusic(vocals);

		generatedMusic = true;
	}

	public var paused:Bool = false;
	var canPause:Bool = true;

	override function openSubState(Substate:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				inst.pause();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);
		}

		super.openSubState(Substate);
	}

	public function followCamSection(sect:SwagSection):Void
	{
		followCamera(strumlineOpponent.character);
		
		if(sect != null)
		{
			if(sect.mustHitSection){
				followCamera(strumlinePlayer.character);
			}
			else if (!sect.mustHitSection){
				followCamera(strumlineOpponent.character);
			}

			switchSong(sect);
		}
	}

	function handlePlayerStrum(strum:NoteStrum) 
	{
    	if (pressed[strum.data]) 
    	{
        	if (!["pressed", "confirm"].contains
        	(strum.animation.curAnim.name)) 
        	{
            	strum.playAnim("pressed");
        	}
    	} else {
        	strum.playAnim("static");
    	}

    	if (strum.animation.curAnim.name == "confirm") {
        	playerSinging = true;
    	}
	}

	function handleBotplayStrum(strum:NoteStrum)
	{
    	if (strum.animation.curAnim.name == "confirm" && strum.animation.curAnim.finished) {
        	strum.playAnim("static");
    	}
	}

	public function switchSong(sect:SwagSection)
	{
		switch(SONG.song)
		{
			case "tutorial":
				FlxTween.tween(PlayState, {extraCamZoom: (sect.mustHitSection ? 0 : 0.5)}, Conductor.crochet / 1000, {
					ease: !sect.mustHitSection ? FlxEase.cubeOut : FlxEase.cubeInOut
				});
		}
	}

	public function checkEventNote() 
	{
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Screen Shake':
				trace("tremeu na base");
			case 'Change Character':
				trace("o evento tentou mudar os personagens");
		}
	}

	override function beatHit()
	{
		super.beatHit();

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		for(change in Conductor.bpmChangeMap)
		{
			if(curStep >= change.stepTime && Conductor.bpm != change.bpm)
				Conductor.setBPM(change.bpm);
		}

		if(curBeat % 4 == 0)
		{
			camZoom(0.05, 0.025);
		}

		for(char in characters)
		{
			if(curBeat % 2 == 0 || char.quickDancer)
			{
				var canIdle = (char.holdTimer == Math.NEGATIVE_INFINITY);

				if(canIdle)
					char.dance();
			}
		}

		switch (SONG.song) {
			case 'bopeebo':
				if(curBeat % 8 == 4)
				{
					boyfriend.playAnim('hey');
				}
		}
	}

	var startTimer:FlxTimer = new FlxTimer();
	public var gfSpeed:Int = 1;

	public function camZoom(gameZoom:Float = 0, hudZoom:Float = 0)
	{
		camGame.zoom += gameZoom;
		camHUD.zoom += hudZoom;
	}

	public function followCamera(?char:Character, ?offsetX:Float = 0, ?offsetY:Float = 0)
	{
		camFollow.setPosition(0,0);

		if(char != null)
		{
			var playerMult:Int = (char.isPlayer ? -1 : 1);

			camFollow.setPosition(char.getMidpoint().x + (200 * playerMult), char.getMidpoint().y - 20);

			camFollow.x += char.cameraPosition[0] * playerMult;
			camFollow.y += char.cameraPosition[0];
		}

		camFollow.x += offsetX;
		camFollow.y += offsetY;
	}

	override function stepHit()
	{
		super.stepHit();
		DiscordClient.changePresence("Playing: " + SONG.song.toUpperCase().replace("-", " "), null);
		if (inst.time >= Conductor.songPosition + 20 || inst.time <= Conductor.songPosition - 20)
			syncSong();
	}
}
