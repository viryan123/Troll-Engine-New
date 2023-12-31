var colorArray:Array<String> = ['purple', 'blue', 'green', 'red'];

function ReloadNoteSkin(note:Note)
{
    note.frames = Paths.getSparrowAtlas('noteSkin/tenzus_notes');
	note.animation.addByPrefix(colorArray[note.noteData] + 'Scroll', colorArray[note.noteData] + '0');

	if (note.isSustainNote)
	{
		note.animation.addByPrefix('purpleholdend', 'pruple end hold'); // ?????
		note.animation.addByPrefix(colorArray[note.noteData] + 'holdend', colorArray[note.noteData] + ' hold end');
		note.animation.addByPrefix(colorArray[note.noteData] + 'hold', colorArray[note.noteData] + ' hold piece');
	}
		
	note.setGraphicSize(Std.int(note.width * 0.7));
	note.updateHitbox();

	note.pixelNote = false;
	note.usesDefaultColours = false;
	note.antialiasing = ClientPrefs.globalAntialiasing;
}

function ReloadStrumsSkin(strum:StrumNote)
{
	strum.frames = Paths.getSparrowAtlas('noteSkin/tenzus_notes');
	strum._loadStrumAnims();

	strum.useRGBColors = false;
}