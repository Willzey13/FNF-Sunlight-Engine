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
import load.hud.Note;
import load.hud.Note.EventNote;
import load.hud.Strumline;
import load.hud.SplashNote;
import load.hud.HealthIcon;
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

class PlayState extends MusicBeatState
{
	public static var SONG:SwagSong;
	public static var curStage:String = '';

	public static var isStoryMode:Bool = false;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var campaignScore:Int = 0;
	public static var storyDifficulty:Int = 2;

	//camera follow :D
	public static var camFollow:FlxObject = new FlxObject();

	//Notes Spawn
	var unspawnCount:Int = 0;
	public var unspawnNotes:Array<Note> = [];

	//HUD bruh
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var healthBar:FlxBar;
	public var scoreTxt:FlxText;
	public var scoreTxtTween:FlxTween;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

	public var strumlines:FlxTypedGroup<Strumline>;
	public var bfStrumline:Strumline;
	public var dadStrumline:Strumline;

	public var gfVersion:String = 'gf';

	public var characters:Array<Character> = [];
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var timeTxt:FlxText;
	public var timeBG:FlxSprite;
	public var timeBar:FlxBar;
	var songPercent:Float = 0;

	public static var cameraSpeed:Float = 1.0;
	public static var defaultCamZoom:Float = 1.0;
	public static var extraCamZoom:Float = 0.0;
	public static var forcedCamPos:Null<FlxPoint>;

	public var stageBuild:Stage;
	public static var assetModifier:String = "base";

	public var health:Float = 1;
	public var combo:Int = 0;
	public static var songLength:Float = 0;

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
	public static var STRUM_X = 42;
	public static var storyWeek:Int = 0;

	override public function create()
	{
		super.create();
		SplashNote.resetStatics();
		Timings.init();
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (SONG == null)
			SONG = Song.loadFromJson('debuggin-hard', 'debuggin');

		if (SONG.isPixel == true)
		{
			assetModifier = "pixel";
		}
		else
			assetModifier = "base";

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		//bgDefault();

		boyfriend = new Character(0, 0);
		boyfriend.isPlayer = true;
		boyfriend.reloadChar(SONG.player1);

		gf = new Character(962, 88);
		changeChar(gf, "gf");

		dad = new Character(694, -238);
		dad.reloadChar(SONG.player2);

		stageBuild = new Stage("stage");
		add(stageBuild);

		add(stageBuild.layers);

		if (dad.isSpectator)
			dad.setPosition(gf.x, gf.y);
		else if (stageBuild.addGirlfriend)
			characters.push(gf);

		characters.push(boyfriend);
		characters.push(dad);

		add(stageBuild.foreground);

		strumlines = new FlxTypedGroup();
		add(strumlines);

		ghostTapping = Saved.ghostTapping;
		var downscroll:Bool = Saved.downScroll;
		
		dadStrumline = new Strumline(0, dad, downscroll, false, true, assetModifier);
		dadStrumline.ID = 0;
		strumlines.add(dadStrumline);
		
		bfStrumline = new Strumline(0, boyfriend, downscroll, true, false, assetModifier);
		bfStrumline.ID = 1;
		strumlines.add(bfStrumline);

		//this stage fuck very fuck lol
		curStage = "stage";
		if (SONG.stage != null)
			curStage = SONG.stage;

		daSong();

		Conductor.mapBPMChanges(SONG);
		Conductor.setBPM(SONG.bpm);

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

		if (isStoryMode)
			DiscordClient.changePresence("Playing Week: " + SONG.song.toUpperCase().replace("-", " "), null);
		else
			DiscordClient.changePresence("Playing Freeplay: " + SONG.song.toUpperCase().replace("-", " "), null);

		for(strumline in strumlines.members)
		{
			strumline.x = setDefaultPositionStrumlines()[strumline.ID];
			strumline.scrollSpeed = SONG.speed;
			strumline.updateHitbox();
		}

		switch (SONG.song){
			default:
				startCountdown();
		}

		//Conductor.setBPM(115);
		Conductor.songPosition = -Conductor.crochet * 5;

		//startSong();

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

		iconP1 = new HealthIcon('bf', true);
		iconP1.y = healthBar.y - 75;
		add(iconP1);

		iconP2 = new HealthIcon('dad', false);
		iconP2.y = healthBar.y - 75;
		add(iconP2);

		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);

		healthBarBG.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		strumlines.cameras = [camHUD];

		//followCamera(dad);
		followCamSection(SONG.notes[0]);
		//FlxG.camera.follow(camFollow, LOCKON, 1);
		FlxG.camera.focusOn(camFollow.getPosition());

		unspawnNotes = ChartLoader.getChart(SONG);
		for(note in unspawnNotes)
		{
			var thisStrumline = dadStrumline;
			for(strumline in strumlines)
				if(note.strumlineID == strumline.ID)
					thisStrumline = strumline;
			
			var noteAssetMod:String = assetModifier;
			note.reloadNote(note.songTime, note.noteData, note.noteType, noteAssetMod);
			note.setSongOffset();
			thisStrumline.addSplash(note);
		}

		for(strumline in strumlines.members)
		{
			var strumMult:Int = (strumline.downscroll ? 1 : -1);
			for(strum in strumline.strumGroup)
			{
				strum.y += Configs.noteWidth() * 0.6 * strumMult;
				strum.alpha = 0.0001;
			}
		}

		for(item in addToList)
			add(item);

		FlxG.camera.zoom = defaultCamZoom;
	}

	public function syncSong():Void
	{
		//song conductor time :]
		if(inst.playing)
		{
			Conductor.songPosition = inst.time;
			vocals.time = Conductor.songPosition;
			inst.play();
			vocals.play();

			if(Math.abs(Conductor.songPosition - inst.time) >= 40 && 
				Conductor.songPosition - inst.time <= 5000)
				{
					trace('New resync vocals time ${Conductor.songPosition}');
				}
		}

		//Conductor finish calling endSong(); function
		if(Conductor.songPosition >= songLength)
			endSong();
	}

	public function bgDefault()
	{
		//FlxG.camera.x = ;
		var bg:FlxSprite = new FlxSprite(100, -800);
		bg.loadGraphic(Paths.image("backgrounds/stage/stageback"));
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(0, 0);
		stageFront.loadGraphic(Paths.image("backgrounds/stage/stagefront"));
		stageFront.scale.set(1.5, 1);
		add(stageFront);
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

	public var curSong:String = "";

	public function changeChar(char:Character, newChar:String = "bf", ?iconToo:Bool = true)
	{
		// gets the original position
		var storedPos = new FlxPoint(
			char.x - char.globalOffset.x,
			char.y + char.height - char.globalOffset.y
		);
		// changes the character
		char.reloadChar(newChar);
		// returns it to the correct position
		char.setPosition(
			storedPos.x + char.globalOffset.x,
			storedPos.y - char.height + char.globalOffset.y
		);
	}

	public function startCountdown()
	{
		var daCount:Int = 0;
		
		var countTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			Conductor.songPosition = -Conductor.crochet * (4 - daCount);
			
			if(daCount == 0)
			{
				startedCountdown = true;
				for(strumline in strumlines.members)
				{
					for(strum in strumline.strumGroup)
					{	
						// dad's notes spawn backwards
						var strumMult:Int = (strumline.isPlayer ? strum.strumData : 3 - strum.strumData);
						// actual tween
						FlxTween.tween(strum, {y: strum.initialPos.y, alpha: 0.9}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeOut,
							startDelay: Conductor.crochet / 2 / 1000 * strumMult,
						});
					}
				}
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
	public final separator:String = " | ";

	public function updateText()
	{
		scoreTxt.text = "";
		
		scoreTxt.text += 			'Score: '		+ Timings.score;
		scoreTxt.text += separator + 'Accuracy: '	+ Timings.accuracy + "%" + ' [${Timings.getRank()}]';
		scoreTxt.text += separator + 'Misses: '		+ Timings.misses;

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

	public function popUpRating(note:Note, strumline:Strumline, miss:Bool = false)
	{
		// return;
		var noteDiff:Float = Math.abs(note.songTime - Conductor.songPosition);
		if(strumline.botplay)
			noteDiff = 0;

		if(note.isHold && !miss)
		{
			noteDiff = Timings.minTiming;
			var holdPercent:Float = (note.holdHitLength / note.holdLength);
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
		
		var healthJudge:Float = 0.05 * judge;
		if(judge < 0)
			healthJudge *= 2;

		// handling stuff
		health += healthJudge;
		Timings.score += Math.floor(100 * judge);
		Timings.addAccuracy(judge);

		if(miss)
		{
			Timings.misses++;

			if(Timings.combo > 0)
				Timings.combo = 0;
			Timings.combo--;
		}
		else
		{
			if(Timings.combo < 0)
				Timings.combo = 0;
			Timings.combo++;
			
			// regains your health only if you hold it entirely
			if(note.isHold)
				health += 0.05 * (note.holdHitLength / note.holdLength);
			
			if(rating == "shit")
			{
				//note.onMiss();
				// forces a miss anyway
				onNoteMiss(note, strumline);
			}
		}
		
		updateText();
		
		//var daRating = new Rating(rating, Timings.combo, note.assetModifier);
	}

	var pressed:Array<Bool> 	= [];
	var justPressed:Array<Bool> = [];
	var released:Array<Bool> 	= [];

	public static var botplay:Bool = false;
	public var ghostTapping:Bool = true;
	
	var playerSinging:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		var followLerp:Float = cameraSpeed * 3 * elapsed;
		if(followLerp > 1) followLerp = 1;

		if(startedCountdown)
			Conductor.songPosition += elapsed * 1000;
		
		Main.camPosLerpVeryLerp(camGame, camFollow, followLerp);

		if (Controls.justPressed("BACK"))
		{
			MusicBeatState.switchState(new MainMenuState());
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

		if(unspawnCount < unspawnNotes.length)
		{
			var unsNote = unspawnNotes[unspawnCount];
			
			var thisStrumline = dadStrumline;
			for(strumline in strumlines)
				if(unsNote.strumlineID == strumline.ID)
					thisStrumline = strumline;
			
			var spawnTime:Int = 3200;
			if(thisStrumline.scrollSpeed <= 1.5)
				spawnTime *= 2;
			
			if(unsNote.songTime - Conductor.songPosition <= spawnTime)
			{
				unsNote.y = FlxG.height * 4;
				//unsNote.spawned = true;
				thisStrumline.addNote(unsNote);
				unspawnCount++;
			}
		}

		for(strumline in strumlines.members)
		{
			if(strumline.isPlayer)
				strumline.botplay = botplay;

			for(strum in strumline.strumGroup)
			{
				if(strumline.isPlayer && !strumline.botplay)
				{
					if(pressed[strum.strumData])
					{
						if(!["pressed", "confirm"].contains(strum.animation.curAnim.name))
							strum.playAnim("pressed");
					}
					else
						strum.playAnim("static");
					
					if(strum.animation.curAnim.name == "confirm")
						playerSinging = true;
				}
				else // how botplay handles it
				{
					if(strum.animation.curAnim.name == "confirm"
					&& strum.animation.curAnim.finished)
						strum.playAnim("static");
				}
			}

			for(note in strumline.allNotes)
			{
				var despawnTime:Int = 300;
				
				if(Conductor.songPosition >= note.songTime + note.holdLength + Conductor.crochet + despawnTime)
				{
					if(!note.gotHit && !note.missed && !note.mustMiss && !strumline.botplay)
						onNoteMiss(note, strumline);
					
					note.clipRect = null;
					strumline.removeNote(note);
					note.destroy();
					continue;
				}
				
				note.setAlpha();
				note.updateHitbox();
				note.offset.x += note.frameWidth * note.scale.x / 2;
				if(note.isHold)
				{
					note.offset.y = 0;
					note.origin.y = 0;
				}
				else
					note.offset.y += note.frameHeight * note.scale.y / 2;
			}

			for(note in strumline.noteGroup)
			{
				var thisStrum = strumline.strumGroup.members[note.noteData];
				var offsetX = note.noteOffset.x;
				var offsetY = (note.songTime - Conductor.songPosition) * (strumline.scrollSpeed * 0.45);
				
				var noteAngle:Float = (note.noteAngle + thisStrum.strumAngle);
				if(strumline.downscroll)
					noteAngle += 180;
				
				note.angle = thisStrum.angle;
				Configs.setNotePos(note, thisStrum, noteAngle, offsetX, offsetY);

				for(hold in note.children)
				{
					var offsetX = note.noteOffset.x;
					var offsetY = hold.noteCrochet * (strumline.scrollSpeed * 0.45) * hold.ID;
					
					hold.angle = -noteAngle;
					Configs.setNotePos(hold, note, noteAngle, offsetX, offsetY);
				}
				
				if(strumline.botplay)
				{
					if(note.songTime - Conductor.songPosition <= 0 && !note.gotHit && !note.mustMiss)
						checkNoteHit(note, strumline);
				}
				else
				{
					if(Conductor.songPosition >= note.songTime + Timings.getTimings("good")[1]
					&& !note.gotHit && !note.missed && !note.mustMiss)
					{
						onNoteMiss(note, strumline);
					}
				}
				if (note.scrollSpeed != strumline.scrollSpeed)
					note.scrollSpeed = strumline.scrollSpeed;
			}
			
			for(hold in strumline.holdGroup)
			{
				if(hold.scrollSpeed != strumline.scrollSpeed)
				{
					hold.scrollSpeed = strumline.scrollSpeed;
					
					if(!hold.isHoldEnd)
					{
						var newHoldSize:Array<Float> = [
							hold.frameWidth * hold.scale.x,
							hold.noteCrochet * (strumline.scrollSpeed * 0.45) + 1
						];
						
						hold.setGraphicSize(
							Math.floor(newHoldSize[0]),
							Std.int(newHoldSize[1])
						);
					}
					
					hold.updateHitbox();
				}
				
				var holdParent = hold.parentNote;
				if(holdParent != null)
				{
					var thisStrum = strumline.strumGroup.members[hold.noteData];
					
					if(holdParent.gotHeld && !hold.missed)
					{
						hold.gotHeld = true;
						
						hold.holdHitLength = (Conductor.songPosition - hold.songTime);
							
						var daRect = new FlxRect(
							0, 0,
							hold.frameWidth,
							hold.frameHeight
						);
						
						var holdID:Float = hold.ID;
						if(hold.isHoldEnd)
							holdID -= 0.4999;

						var minSize:Float = hold.holdHitLength - (hold.noteCrochet * holdID);
						var maxSize:Float = hold.noteCrochet;
						if(minSize > maxSize)
							minSize = maxSize;
						
						if(minSize > 0)
							daRect.y = (minSize / maxSize) * hold.frameHeight;
						
						hold.clipRect = daRect;
						
						//if(hold.holdHitLength >= holdParent.holdLength - Conductor.stepCrochet)
						var notPressed = (!pressed[hold.noteData] && !strumline.botplay && strumline.isPlayer);
						var holdPercent:Float = (hold.holdHitLength / holdParent.holdLength);

						if(hold.isHoldEnd && !notPressed)
							onNoteHold(hold, strumline);
						
						if(notPressed || holdPercent >= 1.0)
						{
							if(holdPercent > 0.3)
							{
								if(hold.isHoldEnd && !hold.gotHit)
									onNoteHit(hold, strumline);
								hold.missed = false;
								hold.gotHit = true;
							}
							else
							{
								onNoteMiss(hold, strumline);
							}
						}
					}
					
					if(holdParent.missed && !hold.missed)
						onNoteMiss(hold, strumline);
				}
			}
			
			if(justPressed.contains(true) && !strumline.botplay && strumline.isPlayer)
			{
				for(i in 0...justPressed.length)
				{
					if(justPressed[i])
					{
						var possibleHitNotes:Array<Note> = [];
						var canHitNote:Note = null;
						
						for(note in strumline.noteGroup)
						{
							var noteDiff:Float = (note.songTime - Conductor.songPosition);
							
							var minTiming:Float = Timings.minTiming;
							if(note.mustMiss)
								minTiming = Timings.getTimings("good")[1];
							
							if(noteDiff <= minTiming && !note.missed && !note.gotHit && note.noteData == i)
							{
								if(note.mustMiss
								&& Conductor.songPosition >= note.songTime + Timings.getTimings("sick")[1])
								{
									continue;
								}
								
								possibleHitNotes.push(note);
								canHitNote = note;
							}
						}

						if(canHitNote != null)
						{
							for(note in possibleHitNotes)
							{
								if(note.songTime < canHitNote.songTime)
									canHitNote = note;
							}

							checkNoteHit(canHitNote, strumline);
						}
						else
						{
							if(!ghostTapping && startedCountdown)
							{
								vocals.volume = 0;

								var note = new Note();
								note.reloadNote(0, i, "none", assetModifier);
								onNoteMiss(note, strumline);
							}
						}
					}
				}
			}
		}

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

		for(char in characters)
		{
			if(char.holdTimer != Math.NEGATIVE_INFINITY)
			{
				if(char.holdTimer < char.holdLength)
					char.holdTimer += elapsed;
				else
				{
					char.holdTimer = Math.NEGATIVE_INFINITY;
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

			timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
		}

		if (health == 0)
			trace('KKKK MO RUIMZAO PORRA KKKK');

		function lerpCamZoom(daCam:FlxCamera, target:Float = 1.0, speed:Int = 6)
			daCam.zoom = FlxMath.lerp(daCam.zoom, target, elapsed * speed);
			
		lerpCamZoom(camGame, defaultCamZoom + extraCamZoom);
		lerpCamZoom(camHUD);
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
	}

	public function checkNoteHit(note:Note, strumline:Strumline)
	{
		if(!note.mustMiss)
			onNoteHit(note, strumline);
		else
			onNoteMiss(note, strumline);
	}

	var singAnims:Array<String> = [
		'singLEFT', 
		'singDOWN', 
		'singUP', 
		'singRIGHT'
	];
	
	function onNoteHit(note:Note, strumline:Strumline)
	{
		var thisStrum = strumline.strumGroup.members[note.noteData];
		var thisChar = strumline.character;

		note.gotHeld = true;
		note.gotHit = true;
		note.missed = false;
		if(!note.isHold)
			note.visible = false;
		else
			note.setAlpha();

		if(note.mustMiss) return;

		thisStrum.playAnim("confirm", true);

		//fucking
		vocals.volume = 1;
		if(strumline.isPlayer)
		{
			popUpRating(note, strumline, false);
		}

		if(!note.isHold)
		{
			var noteDiff:Float = Math.abs(note.songTime - Conductor.songPosition);
			if(noteDiff <= Timings.getTimings("sick")[1] || strumline.botplay)
			{
				strumline.playSplash(note);
			}
		}

		if(thisChar != null && !note.isHold)
		{
			if(note.noteType != "no animation")
			{
				thisChar.playAnim(singAnims[note.noteData], true);
				thisChar.holdTimer = 0;

				/*if(note.noteType != 'none')
					thisChar.playAnim('hey');*/
			}
		}
	}

	function onNoteMiss(note:Note, strumline:Strumline)
	{
		var thisStrum = strumline.strumGroup.members[note.noteData];
		var thisChar = strumline.character;

		note.gotHit = false;
		note.missed = true;
		note.setAlpha();
		var onlyOnce:Bool = false;
		if(!note.isHold)
			onlyOnce = true;
		else
		{
			if(note.isHoldEnd && note.holdHitLength > 0)
				onlyOnce = true;
		}
		if(onlyOnce)
		{
			vocals.volume = 0;
			
			FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), 0.55);
			
			if(thisChar != null && note.noteType != "no animation")
			{
				thisChar.playAnim(singAnims[note.noteData] + 'miss', true);
				thisChar.holdTimer = 0;
			}
		}

		if(strumline.isPlayer)
		{
			popUpRating(note, strumline, true);
		}
	}

	function onNoteHold(note:Note, strumline:Strumline)
	{
		if(note.holdHitLength > note.holdLength) return;
		
		var thisStrum = strumline.strumGroup.members[note.noteData];
		var thisChar = strumline.character;
		
		vocals.volume = 1;
		thisStrum.playAnim("confirm", true);
		if(note.mustMiss)
			health -= 0.005;
		
		if(note.gotHit || thisChar == null) return;
		
		if(note.noteType != "no animation")
		{
			if(thisChar.animation.curAnim.curFrame == thisChar.holdLoop)
				thisChar.playAnim(singAnims[note.noteData], true);
			
			thisChar.holdTimer = 0;
		}
	}


	public function setDefaultPositionStrumlines():Array<Float>
	{
		for(strumline in strumlines.members)
			if(!strumline.isPlayer)
				for(strum in strumline.strumGroup)
					strum.visible = !Saved.data.get('Middlescroll');

		var strumPos:Array<Float> = [FlxG.width / 2, FlxG.width / 4];

		if(Saved.data.get('Middlescroll'))
			return [-strumPos[0], strumPos[0]];
		else
			return [strumPos[0] - strumPos[1], strumPos[0] + strumPos[1]];
	}

	public var paused:Bool = false;
	var canPause:Bool = true;

	public function followCamSection(sect:SwagSection):Void
	{
		followCamera(dadStrumline.character);
		
		if(sect != null)
		{
			if(sect.mustHitSection)
				followCamera(bfStrumline.character);
				switchSong(sect);
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
				if(curBeat % 8 == 7)
				{
					//boyfriend.animation.play('hey');
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

			camFollow.x += char.cameraOffset.x * playerMult;
			camFollow.y += char.cameraOffset.y;
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
