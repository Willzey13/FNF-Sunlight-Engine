# FNF-Sunlight-Engine
A Remake of a engine in which initially was going to be over FE (Forever Engine) but we've decided to code it from scratch, let's see how it goes!

<p align="center">
<img src="https://art.ngfiles.com/medium_views/5563000/5563765_619031_willzinhu_sunlightengine.7856f10b77a8e6aff49918f3dd8f0846.webp?f1711488491">
</p>

We appreciate you using our engine, we are happy!! :)

# Friday Night Funkin'

<p align="center">
<img src="https://art.ngfiles.com/images/5564000/5564684_620407_willzinhu_untitled-5564684.3549f64615d882d7d0e76e61446f29a4.webp?f1711513935">
</p>

nothing lol

### LIBRARIES
```
lime
flixel
flixel-addons
flixel-ui
discord_rpc 
```

## Credits:
* Willzey - Owner/Programmer
* Toffe - Programmer/Musician
* Guisende - Programmer
* Lofi - Pixel Art
* Miik -Artist
* CauaRemix - Artist
* Nait - Charter
* Niko - Artist
* Alysson - Loading Screens Art
* Marcello Richard - Story Menu UI Art

### Special Thanks
* Psych Engine - Week Loader and Story Menu
* Forever Engine - HXS loader
* Nick - Musician pause screen

_____________________________________

## Mod Support

* Probably one of the main points of this engine, you can code in .lua files outside of the source code, making your own weeks without even messing with the source!
* Comes with a Mod Organizing/Disabling Menu.


## Atleast one change to every week:

### Week 1:
  * New Dad Left sing sprite
  * Unused stage lights are now used
  * Dad Battle has a spotlight effect for the breakdown
### Week 2:
  * Both BF and Skid & Pump does "Hey!" animations
  * Thunders does a quick light flash and zooms the camera in slightly
  * Added a quick transition/cutscene to Monster
### Week 3:
  * BF does "Hey!" during Philly Nice
  * Blammed has a cool new colors flash during that sick part of the song
### Week 4:
  * Better hair physics for Mom/Boyfriend (Maybe even slightly better than Week 7's :eyes:)
  * Henchmen die during all songs. Yeah :(
### Week 5:
  * Bottom Boppers and GF does "Hey!" animations during Cocoa and Eggnog
  * On Winter Horrorland, GF bops her head slower in some parts of the song.
### Week 6:
  * On Thorns, the HUD is hidden during the cutscene
  * Also there's the Background girls being spooky during the "Hey!" parts of the Instrumental

## Cool new Chart Editor changes and countless bug fixes
![](https://github.com/ShadowMario/FNF-PsychEngine/blob/main/docs/img/chart.png?raw=true)
* You can now chart "Event" notes, which are bookmarks that trigger specific actions that usually were hardcoded on the vanilla version of the game.
* Your song's BPM can now have decimal values
* You can manually adjust a Note's strum time if you're really going for milisecond precision
* You can change a note's type on the Editor, it comes with five example types:
  * Alt Animation: Forces an alt animation to play, useful for songs like Ugh/Stress
  * Hey: Forces a "Hey" animation instead of the base Sing animation, if Boyfriend hits this note, Girlfriend will do a "Hey!" too.
  * Hurt Notes: If Boyfriend hits this note, he plays a miss animation and loses some health.
  * GF Sing: Rather than the character hitting the note and singing, Girlfriend sings instead.
  * No Animation: Character just hits the note, no animation plays.

## Multiple editors to assist you in making your own Mod
![Screenshot_3](https://user-images.githubusercontent.com/44785097/144629914-1fe55999-2f18-4cc1-bc70-afe616d74ae5.png)
* Working both for Source code modding and Downloaded builds!

## Story mode menu rework:
![](https://i.imgur.com/UB2EKpV.png)
* Added a different BG to every song (less Tutorial)
* All menu characters are now in individual spritesheets, makes modding it easier.

## Credits menu
![Screenshot_1](https://user-images.githubusercontent.com/44785097/144632635-f263fb22-b879-4d6b-96d6-865e9562b907.png)
* You can add a head icon, name, description and a Redirect link for when the player presses Enter while the item is currently selected.

## Awards/Achievements
* The engine comes with 16 example achievements that you can mess with and learn how it works (Check Achievements.hx and search for "checkForAchievement" on PlayState.hx)

## Options menu:
* You can change Note colors, Delay and Combo Offset, Controls and Preferences there.
 * On Preferences you can toggle Downscroll, Middlescroll, Anti-Aliasing, Framerate, Low Quality, Note Splashes, Flashing Lights, etc.


