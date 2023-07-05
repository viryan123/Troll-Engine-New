package hud;

import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxEase;
import flixel.util.FlxStringUtil;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import playfields.*;
import JudgmentManager.JudgmentData;

import flixel.tweens.FlxTween;
import flixel.text.FlxText;

class PsychHUD extends BaseHUD {
	public var judgeTexts:Map<String, FlxText> = [];
	public var judgeNames:Map<String, FlxText> = [];
	
	public var scoreTxt:FlxText;
	public var hitbar:Hitbar;

	public var bar:FlxSprite;
	public var songPosBar:FlxBar = null;
	public var songNameTxt:FlxText;

	var hitbarTween:FlxTween;
	var scoreTxtTween:FlxTween;

	var songHighscore:Int = 0;
	override public function new(iP1:String, iP2:String, songName:String, stats:Stats)
	{
		super(iP1, iP2, songName, stats);

		stats.changedEvent.add(statChanged);

		add(healthBarBG);
		add(healthBar);
		add(iconP1);
		add(iconP2);
		
		songHighscore = Highscore.getScore(songName,PlayState.difficulty);

		scoreTxt = new FlxText(0, healthBarBG.y + 48, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font(gameFont), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = scoreTxt.alpha > 0;

		if (ClientPrefs.judgeCounter != 'Off')
		{
			var textWidth = ClientPrefs.judgeCounter == 'Shortened' ? 150 : 200;
			var textPosX = ClientPrefs.hudPosition == 'Right' ? (FlxG.width - 5 - textWidth) : 5;
			var textPosY = (FlxG.height - displayedJudges.length*25) * 0.5;

			for (idx in 0...displayedJudges.length)
			{
				var judgment = displayedJudges[idx];

				var text = new FlxText(textPosX, textPosY + idx*25, textWidth, displayNames.get(judgment), 20);
				text.setFormat(Paths.font(gameFontBold), 24, judgeColours.get(judgment), LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				text.scrollFactor.set();
				text.borderSize = 1.25;
				add(text);

				var numb = new FlxText(textPosX, text.y, textWidth, "0", 20);
				numb.setFormat(Paths.font(gameFont), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				numb.scrollFactor.set();
				numb.borderSize = 1.25;
				add(numb);

				judgeTexts.set(judgment, numb);
				judgeNames.set(judgment, text);
			}
		}

		loadSongPos();

		//
		
		hitbar = new Hitbar();
		hitbar.alpha = alpha;
		hitbar.visible = ClientPrefs.hitbar;
		add(hitbar);
		if (ClientPrefs.hitbar)
		{
			hitbar.screenCenter(XY);
			if (ClientPrefs.downScroll)
				hitbar.y -= 230;
			else
				hitbar.y += 330;
		}

		add(scoreTxt);
	}

	var tweenProg:Float = 0;

	override public function songStarted()
	{
		FlxTween.num(0, 1, 0.5, {
			ease: FlxEase.circOut,
			onComplete: function(tw:FlxTween)
			{
				tweenProg = 1;
			}
		}, function(prog:Float)
		{
			tweenProg = prog;
			bar.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
			songPosBar.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
			songNameTxt.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
		});
	}

	override function changedOptions(changed:Array<String>)
	{
		super.changedOptions(changed);

		updateTime = (ClientPrefs.timeBarType != 'Disabled' && ClientPrefs.timeOpacity > 0);

		songNameTxt.visible = updateTime;
		songPosBar.visible = updateTime;
		bar.visible = updateTime;
		
		if (updateTime)
		{
			var songPosY = FlxG.height - 706;
			if (ClientPrefs.downScroll)
				songPosY = FlxG.height - 33;
			songPosBar.y = songPosY;
			bar.y = songPosBar.y;
			songNameTxt.y = bar.y + ((songPosBar.height - 15) / 2) - 5;
			songPosBar.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
			songNameTxt.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
		}

		hitbar.visible = ClientPrefs.hitbar;
		
		if (ClientPrefs.hitbar)
		{
			hitbar.screenCenter(XY);
			if (ClientPrefs.downScroll)
			{
				hitbar.y -= 220;
				hitbar.averageIndicator.flipY = false;
				hitbar.averageIndicator.y = hitbar.y - (hitbar.averageIndicator.width + 5);
			}
			else
				hitbar.y += 340;
		}
	}
	override public function songEnding(){
		bar.visible = false;
		songPosBar.visible = false;
		songNameTxt.visible = false;
	}
	override function update(elapsed:Float){
		scoreTxt.text = (songHighscore != 0 && score > songHighscore ? 'Hi-score: ' : 'Score: ')
			+ '$score | Combo Breaks: $comboBreaks | Rating: '
			+ (grade != '?' ? Highscore.floorDecimal(ratingPercent * 100, 2)
				+ '% / ${grade} [${(ratingFC == 'CFC' && ClientPrefs.wife3) ? "FC" : ratingFC}]' : grade);
		if (ClientPrefs.npsDisplay)
			scoreTxt.text += ' | NPS: ${nps} / ${npsPeak}';

		for (k in judgements.keys())
		{
			if (judgeTexts.exists(k))
				judgeTexts.get(k).text = Std.string(judgements.get(k));
		}
		
		super.update(elapsed);

		var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
		if (curTime < 0)
			curTime = 0;
		songPercent = (curTime / songLength);

		var songCalc:Float = (songLength - curTime);
		songCalc = curTime;

		var secondsTotal:Int = Math.floor(songCalc / 1000);
		if (secondsTotal < 0)
			secondsTotal = 0;
		else if (secondsTotal >= Math.floor(songLength / 1000))
			secondsTotal = Math.floor(songLength / 1000);

		songNameTxt.text = songName
			+ ' (${FlxStringUtil.formatTime(secondsTotal, false)} - ${FlxStringUtil.formatTime(Math.floor(songLength / 1000), false)})';
		songNameTxt.updateHitbox();
		songNameTxt.screenCenter(X);
	}

	override function noteJudged(judge:JudgmentData, ?note:Note, ?field:PlayField)
	{
		var hitTime = note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset;

		if (ClientPrefs.hitbar)
			hitbar.addHit(hitTime);
		if (ClientPrefs.scoreZoom)
		{
			if (scoreTxtTween != null)
				scoreTxtTween.cancel();

			var judgeName = judgeNames.get(judge.internalName);
			var judgeTxt = judgeTexts.get(judge.internalName);
			if (judgeName != null)
			{
				FlxTween.cancelTweensOf(judgeName.scale);
				judgeName.scale.set(1.075, 1.075);
				FlxTween.tween(judgeName.scale, {x: 1, y: 1}, 0.2);
			}
			if (judgeTxt != null)
			{
				FlxTween.cancelTweensOf(judgeTxt.scale);
				judgeTxt.scale.set(1.075, 1.075);
				FlxTween.tween(judgeTxt.scale, {x: 1, y: 1}, 0.2);
			}

			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween)
				{
					scoreTxtTween = null;
				}
			});
		}
	}

	function statChanged(stat:String, val:Dynamic)
		{
			switch (stat)
			{
				case 'misses':
					misses = val;
					var judgeName = judgeNames.get('miss');
					var judgeTxt = judgeTexts.get('miss');
					if (judgeName != null)
					{
						FlxTween.cancelTweensOf(judgeName.scale);
						judgeName.scale.set(1.075, 1.075);
						FlxTween.tween(judgeName.scale, {x: 1, y: 1}, 0.2);
					}
					if (judgeTxt != null)
					{
						FlxTween.cancelTweensOf(judgeTxt.scale);
						judgeTxt.scale.set(1.075, 1.075);
						FlxTween.tween(judgeTxt.scale, {x: 1, y: 1}, 0.2);
	
						judgeTxt.text = Std.string(val);
					}
			}
		}

	override public function beatHit(beat:Int){
		if (hitbar != null)
			hitbar.beatHit();

		super.beatHit(beat);
	}

	function loadSongPos()
		{
			var songPosY = FlxG.height - 706;
			if (ClientPrefs.downScroll)
				songPosY = FlxG.height - 33;
	
			var bfColor = FlxColor.fromRGB(PlayState.instance.boyfriend.healthColorArray[0], PlayState.instance.boyfriend.healthColorArray[1], PlayState.instance.boyfriend.healthColorArray[2]);
			var dadColor = FlxColor.fromRGB(PlayState.instance.dad.healthColorArray[0], PlayState.instance.dad.healthColorArray[1], PlayState.instance.dad.healthColorArray[2]);
			songPosBar = new FlxBar(390, songPosY, LEFT_TO_RIGHT, 500, 25, this, 'songPercent', 0, 1);
			songPosBar.alpha = 0;
			songPosBar.scrollFactor.set();
			songPosBar.createGradientBar([FlxColor.BLACK], [bfColor, dadColor]);
			songPosBar.numDivisions = 800;
			add(songPosBar);
	
			bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);
			bar.alpha = 0;
			add(bar);
	
			FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: (FlxColor.BLACK)});
	
			songNameTxt = new FlxText(0, bar.y + ((songPosBar.height - 15) / 2) - 5, 0, '', 16);
			songNameTxt.setFormat(Paths.font(gameFont), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songNameTxt.autoSize = true;
			songNameTxt.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
			songNameTxt.borderSize = 2;
			songNameTxt.scrollFactor.set();
			songNameTxt.text = songName +
				' (${FlxStringUtil.formatTime(songLength, false)} - ${FlxStringUtil.formatTime(Math.floor(songLength / 1000), false)})';
			songNameTxt.alpha = 0;
			add(songNameTxt);
		}
}