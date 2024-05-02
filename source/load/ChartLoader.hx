package load;

import states.PlayState;
import data.SunlightModule;
import data.ScriptData;
import data.Song;
import data.Section.SwagSection;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import load.hud.*;

class ChartLoader {
    public static function generateChartType(songData:SwagSong):Dynamic {
        var chartData:Array<Dynamic> = [];

        return generateNoteChart(songData.notes);
    }

    private static function generateNoteChart(noteData:Array<SwagSection>):Array<Note> {
        var unspawnNotes:Array<Note> = [];

        for (section in noteData) {
            for (songNotes in section.sectionNotes) {

                var note:Note = createNoteFromData(songNotes, section);
                var noteCrochet:Float = Conductor.stepCrochet;
                var daStrumTime:Float = songNotes[0];
                var daNoteData:Int = Std.int(songNotes[1] % 4);
                var daNoteType:String = 'none';
                var gottaHitNote:Bool = section.mustHitSection;

                unspawnNotes.push(note);

                if (songNotes[1] > 3)
                {
                    gottaHitNote = !section.mustHitSection;
                }

                var isPlayer = (songNotes[1] >= 4);
                if(section.mustHitSection)
                    isPlayer = (songNotes[1] <  4);


                note.gfNote = (section.gfSection && (songNotes[1]<4));
                note.mustPress = gottaHitNote;
                note.noteID = gottaHitNote ? 1 : 0;

                var susLength:Float = songNotes[2];
                if(susLength > 0)
                {
                    var daParent:Note = note;
                    
                    note.holdLength = susLength;
                    note.noteCrochet = noteCrochet;
                    
                    var holdLoop:Int = Math.floor(susLength / noteCrochet);
                    if (holdLoop <= 0)
                        holdLoop = 1;
                    
                    var holdID:Int = 0;
                    for(i in 0...(holdLoop + 1))
                    {
                        var isSustainEnd = (i == holdLoop);
                        
                        var isSustainNote:Note = new Note(daStrumTime, daNoteData, daNoteType, 0, true);
                        isSustainNote.isSustain = true;
                        isSustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
                        isSustainNote.isSustainEnd = isSustainEnd;
                        //isSustainNote.reloadNote(daStrumTime, daNoteData, daNoteType, 0, true);
                        
                        isSustainNote.parentNote = daParent;
                        isSustainNote.noteID = note.noteID;
                        isSustainNote.ID = holdID;
                        isSustainNote.holdLength = susLength;
                        isSustainNote.noteCrochet = noteCrochet;
                        
                        unspawnNotes.push(isSustainNote);
                        
                        daParent = isSustainNote;
                        note.children.push(isSustainNote);
                        holdID++;
                    }
                }
            }
        }

        return unspawnNotes;
    }

    private static function createNoteFromData(songNotes:Array<Dynamic>, section:SwagSection) {
        var daStrumTime:Float = calculateStrumTime(songNotes[0]);
        var daNoteData:Int = Std.int(songNotes[1] % 4);
        var daNoteType:String = getNoteType(songNotes);
        var unspawnNotes:Array<Note> = [];

        var gottaHitNote:Bool = section.mustHitSection;
        if (songNotes[1] > 3) {
            gottaHitNote = !section.mustHitSection;
        }

        var oldNote:Note = (unspawnNotes.length > 0) ? unspawnNotes[Std.int(unspawnNotes.length - 1)] : null;

        return new Note(daStrumTime, daNoteData, daNoteType, gottaHitNote ? 1 : 0, false, oldNote);
    }

    private static function calculateStrumTime(rawTime:Float) {
        return #if !neko rawTime #else rawTime #end;
    }

    private static function getNoteType(songNotes:Array<Dynamic>) {
        var daNoteType:String = "default";
        if (songNotes.length > 2) {
            if (Std.isOfType(songNotes[3], String)) {
                switch (songNotes[3]) {
                    case "Hurt Note":
                        daNoteType = "mine";
                    default:
                        daNoteType = "default";
                }
            }
        }
        return daNoteType;
    }
}