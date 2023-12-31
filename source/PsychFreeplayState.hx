package;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxTimer;
import openfl.Lib;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

import editors.ChartingState;

#if MODS_ALLOWED
import sys.FileSystem;
#end

#if discord_rpc
import Discord.DiscordClient;
#end

class PsychFreeplayState extends MusicBeatState
{
	var songs:Array<PsychSongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	public static var freeplayType = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<AlphabetNew>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public var showIcon:Bool = false;

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var hintText:FlxText;

	override function create()
	{
		Paths.clearStoredMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;

		//TODO: unhardcode this lmao
		switch (freeplayType)
		{
			case 2:
				addSong('Suffering Siblings', 0, 'finn',FlxColor.fromRGB(168,160,179), 'Normal', 'ModPack');
				addSong('Fatality', 0, 'fatal-sonic',FlxColor.fromRGB(255,60,110), 'Hard', 'ModPack');
				addSong('Despair', 0, 'face',FlxColor.fromRGB(242,185,0), 'Hard', 'ModPack');
				addSong('Top Loader', 0, 'top_sonic_icons',FlxColor.fromRGB(0,42,136), 'Normal', 'ModPack');
			case 1:
				addSong('False Paradise', 0, 'dad',FlxColor.fromRGB(146, 113, 253), 'Normal', 'ViranModchart');
				addSong('Prey', 0, 'dad',FlxColor.fromRGB(146, 113, 253), 'Normal', 'ViranModchart');
				addSong('Endless', 0, 'dad',FlxColor.fromRGB(146, 113, 253), '', 'ViranModchart');
				addSong('The Phoenix', 0, 'dad',FlxColor.fromRGB(146, 113, 253), 'Normal', 'ViranModchart');
				addSong('BIG SHOT', 0, 'dad',FlxColor.fromRGB(146, 113, 253), 'Normal', 'ViranModchart');
			case 0:
				var dadColor = FlxColor.fromRGB(146, 113, 253);
				var spook = FlxColor.fromRGB(34, 51, 68);
				var pico = FlxColor.fromRGB(148, 22, 83);
				var mom = FlxColor.fromRGB(252, 150, 215);
				var chrismas = FlxColor.fromRGB(160, 209, 255);
				var senpai = FlxColor.fromRGB(255, 120, 191);
				var tankman = FlxColor.fromRGB(246, 182, 4);
				addSong('Test', 0, 'bf',FlxColor.fromRGB(49,176,209), 'Normal');
				addWeek(['Bopeebo', 'Fresh', 'Dad Battle'], 1, [dadColor, dadColor, dadColor], ['dad', 'dad', 'dad'], ['Normal', 'Normal', 'Normal']);
				addWeek(['Spookeez', 'South', 'Monster'], 2, [spook, spook, spook], ['spooky', 'spooky', 'monster'], ['Normal', 'Normal', 'Normal']);
				addWeek(['Pico', 'Philly Nice', 'Blammed'], 3, [pico, pico, pico], ['pico', 'pico', 'pico'], ['Normal', 'Normal', 'Normal']);
				addWeek(['Satin Panties', 'High', 'Milf'], 4, [mom, mom, mom], ['mom', 'mom', 'mom'], ['Normal', 'Normal', 'Normal']);
				addWeek(['Cocoa', 'Eggnog', 'Winter Horrorland'], 5, [chrismas, chrismas, chrismas], ['parents', 'parents', 'monster'], ['Normal', 'Normal', 'Normal']);
				addWeek(['Senpai', 'Roses', 'Thorns'], 6, [senpai, senpai, senpai], ['senpai-pixel', 'senpai-pixel', 'spirit-pixel'], ['Normal', 'Normal', 'Normal']);
				addWeek(['Ugh', 'Guns', 'Stress'], 7, [tankman, tankman, tankman], ['tankman', 'tankman', 'tankman'], ['Normal', 'Normal', 'Normal']);
		}

		bg = new FlxSprite().loadGraphic(Paths.image('menuBGDesat'));
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<AlphabetNew>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:AlphabetNew = new AlphabetNew(FlxG.width / 2, 320, songs[i].songName, true);
			songText.targetY = i;
			songText.alignment = CENTERED;
			songText.distancePerItem.x = 0;
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;


			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("Normal Text.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		changeSelection();

		if (!showIcon) {
			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0;
			}
		}

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		hintText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, Paths.getString("freeplayhint"), 18);
		hintText.setFormat(Paths.font("Normal Text.ttf"), 18, FlxColor.WHITE, RIGHT);
		hintText.scrollFactor.set();
		add(hintText);
		
		updateTexts();
		super.create();

		Paths.clearUnusedMemory();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;

		if((subState is GameplayChangersSubstate))
			Highscore.loadData();
		
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, diff:String = "", ?folder:String)
	{
		var mData = new PsychSongMetadata(songName, weekNum, songCharacter, color);
		mData.availableDiff = diff;
		mData.folder = folder;
		songs.push(mData);
		return mData;
	}

	public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Array<Int>, ?songCharacters:Array<String>, diff:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], weekColor[num], diff[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		hintText.x -= 64 * elapsed * 3;
		if (hintText.x < (FlxG.camera.scroll.x - hintText.width))
			hintText.x = FlxG.camera.scroll.x + FlxG.width;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if(FlxG.keys.justPressed.HOME)
			{
				curSelected = 0;
				changeSelection();
				holdTime = 0;	
			}
			else if(FlxG.keys.justPressed.END)
			{
				curSelected = songs.length - 1;
				changeSelection();
				holdTime = 0;	
			}
			if (controls.UI_UP_P)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
			}
		}

		if (controls.UI_LEFT_P)
		{
			changeDiff(-1);
			_updateSongLastDifficulty();
		}
		else if (controls.UI_RIGHT_P)
		{
			changeDiff(1);
			_updateSongLastDifficulty();
		}

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new FreeplaySelectState());
		}

		if(FlxG.keys.justPressed.CONTROL)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(FlxG.keys.justPressed.SPACE)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (controls.ACCEPT || FlxG.mouse.pressed)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.difficulty = curDifficulty;

				if(colorTween != null) {
					colorTween.cancel();
				}
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
			
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET || FlxG.keys.justPressed.DELETE)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter, false));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateTexts(elapsed);
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		else
			diffText.text = lastDifficultyName.toUpperCase();

		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		if (showIcon) {
			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0.6;
			}
			iconArray[curSelected].alpha = 1;
		}

		for (item in grpSongs.members)
		{
			bullShit++;
			item.alpha = 0.6;
			if (item.targetY == curSelected)
				item.alpha = 1;
		}
		
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadAvailableDiff(songs[curSelected].availableDiff);
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(lerpSelected, curSelected, FlxMath.bound(elapsed * 9.6, 0, 1));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:AlphabetNew = grpSongs.members[i];
			item.visible = item.active = true;
			item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
			item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

			var icon:HealthIcon = iconArray[i];
			icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}
}

class PsychSongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var lastDifficulty:String = null;
	public var availableDiff:String = "";
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}

class FreeplaySelectState extends MusicBeatState
{
	var freeplayCats:Array<String> = ['Friday Night Funkin', 'Modchart', "Mods"];
	var grpCats:FlxTypedGroup<AlphabetNew>;
	var curSelected:Int = 0;
	var BG:FlxSprite;

	override function create()
	{
		BG = new FlxSprite().loadGraphic(Paths.image('menuBGDesat'));
		BG.updateHitbox();
		BG.screenCenter();
		add(BG);
		grpCats = new FlxTypedGroup<AlphabetNew>();
		add(grpCats);
		for (i in 0...freeplayCats.length)
		{
			var catsText:AlphabetNew = new AlphabetNew(FlxG.width / 2, 320, freeplayCats[i], true);
			catsText.targetY = i - curSelected;
			catsText.alignment = CENTERED;
			catsText.distancePerItem.x = 0;
			grpCats.add(catsText);
		}
		changeSelection();
		updateTexts();
		super.create();
	}

	var holdTime:Float = 0;
	override public function update(elapsed:Float)
	{
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
		}

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

		if(freeplayCats.length > 1)
		{
			if(FlxG.keys.justPressed.HOME)
			{
				curSelected = 0;
				changeSelection();
				holdTime = 0;	
			}
			else if(FlxG.keys.justPressed.END)
			{
				curSelected = freeplayCats.length - 1;
				changeSelection();
				holdTime = 0;	
			}

			if (upP) {
				changeSelection(-1);
				holdTime = 0;
			}
			if (downP) {
				changeSelection(1);
				holdTime = 0;
			}
			if (FlxG.mouse.wheel != 0)
			{
				changeSelection(-shiftMult * FlxG.mouse.wheel);
				holdTime = 0;	
			}
			if (controls.BACK)
			{
				backOut();
			}
			if (controls.ACCEPT || FlxG.mouse.pressed)
			{
				PsychFreeplayState.freeplayType = curSelected;
				FlxG.switchState(new PsychFreeplayState());
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
			}

		}
		updateTexts(elapsed);
		super.update(elapsed);
	}

	function backOut()
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));
		MusicBeatState.switchState(new MainMenuState());
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = freeplayCats.length - 1;
		if (curSelected >= freeplayCats.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpCats.members)
		{
			bullShit++;
			item.alpha = 0.6;
			if (item.targetY == curSelected)
				item.alpha = 1;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	var lerpSelected:Float = 0;
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(lerpSelected, curSelected, FlxMath.bound(elapsed * 9.6, 0, 1));
		for (i in _lastVisibles)
		{
			grpCats.members[i].visible = grpCats.members[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(freeplayCats.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(freeplayCats.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:AlphabetNew = grpCats.members[i];
			item.visible = item.active = true;
			item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
			item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

			_lastVisibles.push(i);
		}
	}
}