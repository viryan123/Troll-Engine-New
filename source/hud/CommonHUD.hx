package hud;

import PlayState.FNFHealthBar;
import flixel.ui.FlxBar;
import flixel.tweens.FlxEase;
import flixel.util.FlxStringUtil;
import JudgmentManager.JudgmentData;
import flixel.util.FlxColor;
import playfields.*;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;


// includes basic HUD stuff

class CommonHUD extends BaseHUD
{
    // just some extra variables lol
	public var healthBar:FNFHealthBar;
	@:isVar
	public var healthBarBG(get, null):FlxSprite;
	function get_healthBarBG()return healthBar.healthBarBG;

	// just some extra variables lol
	public var healthBar2:FNFHealthBar;
	@:isVar
	public var healthBarBG2(get, null):FlxSprite;
	function get_healthBarBG2()return healthBar2.healthBarBG;

	override function set_displayedHealth(value:Float){
		healthBar.value = value;
		if (ClientPrefs.etternaHUD == 'ITG')
			healthBar2.value = value;
		displayedHealth = value;
		return value;
	}


	public var bar:FlxSprite;
	public var songPosBar:FlxBar = null;
	public var songNameTxt:FlxText;
	// ITG Bar
	public var timeBar:FlxBar;
	public var timeTxt:FlxText;
	private var timeBarBG:FlxSprite;
	public var scoreBG:FlxSprite;
	public function new(iP1:String, iP2:String, songName:String, stats:Stats)
	{
		super(iP1, iP2, songName, stats);
		
		if (ClientPrefs.etternaHUD == 'ITG')
		{
			scoreBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, 136, 0xFF000000);
			scoreBG.alpha = 0.6;
			add(scoreBG);
		}

		healthBar = new FNFHealthBar(iP1, iP2);
		if (ClientPrefs.etternaHUD == 'ITG')
			healthBar2 = new FNFHealthBar(iP1, iP2);
		iconP1 = healthBar.iconP1;
		iconP2 = healthBar.iconP2;

		loadSongPos();

		if(FlxG.state == PlayState.instance){
            PlayState.instance.healthBar = healthBar;
			PlayState.instance.iconP1 = iconP1;
			PlayState.instance.iconP2 = iconP2;
        }
	}

	function loadSongPos()
	{
		if (ClientPrefs.etternaHUD == 'ITG')
		{
			timeTxt = new FlxText(FlxG.width * 0.5 - 200, 19 - 5, 400, songName, 32);
			timeTxt.setFormat(Paths.font("miso-bold.ttf"), 32, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
			timeTxt.scrollFactor.set();
			timeTxt.borderSize = 2;

			var bgGraphic = Paths.image('SimplyLoveHud/TimeBarBG');
			if (bgGraphic == null) bgGraphic = CoolUtil.makeOutlinedGraphic(400, 20, 0xFFFFFFFF, 5, 0xFF000000);

			timeBarBG = new FlxSprite(timeTxt.x - 120, 19 - 6, bgGraphic);
			timeBarBG.scale.set(0.7, 0.9);
			timeBarBG.updateHitbox();
			timeBarBG.color = FlxColor.BLACK;
			timeBarBG.scrollFactor.set();

			timeBar = new FlxBar(timeBarBG.x + 5,timeBarBG.y + 5, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 10), Std.int(timeBarBG.height - 10), this,
				'songPercent', 0, 1);
			timeBar.scrollFactor.set();
			timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
			timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
			timeBar.scrollFactor.set();
	
			add(timeBarBG);
			add(timeBar);
			add(timeTxt);

			updateTimeBarType();
		}
		else
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
		
			flixel.util.FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT, {thickness: 4, color: (FlxColor.BLACK)});
		
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
	
			updateTimeBarType();
		}
	}

	function updateTimeBarType(){	
		updateTime = (ClientPrefs.timeBarType != 'Disabled' && ClientPrefs.timeOpacity > 0);

		if (ClientPrefs.etternaHUD == 'ITG'){
			if (timeTxt != null || timeBarBG != null || timeBar != null) {
				timeTxt.exists = updateTime;
				timeBarBG.exists = updateTime;
				timeBar.exists = updateTime;
			}
		}else {
			if (songNameTxt != null || songPosBar != null || bar != null) {
				songNameTxt.exists = updateTime;
				songPosBar.exists = updateTime;
				bar.exists = updateTime;
			}
		}

		updateTimeBarAlpha();
	}

	function updateTimeBarAlpha(){
		if (ClientPrefs.etternaHUD == 'ITG') {
			if (timeTxt != null || timeBarBG != null || timeBar != null)
			{
				timeBarBG.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
				timeBar.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
				timeTxt.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
			}
		} else {

			var songPosY = FlxG.height - 706;
			if (ClientPrefs.downScroll)
				songPosY = FlxG.height - 33;
	
			if (songPosBar != null || bar != null || songNameTxt != null) {
				songPosBar.y = songPosY;
				bar.y = songPosBar.y;
				songNameTxt.y = bar.y;
	
				songPosBar.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
				bar.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
				songNameTxt.alpha = ClientPrefs.timeOpacity * alpha * tweenProg;
			}
		}
	}

    override function changedCharacter(id:Int, char:Character){

        switch(id){
            case 1:
				iconP1.changeIcon(char.healthIcon);
            case 2:
				iconP2.changeIcon(char.healthIcon);
            case 3:
                // gf icon
            default:
                // idk
        }

		super.changedCharacter(id, char);
    }

	override public function update(elapsed:Float)
	{
		if (updateTime)
		{
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
	
			if (ClientPrefs.etternaHUD != 'ITG')
			{
				if (songNameTxt != null) {
					songNameTxt.text = songName
					+ ' (${FlxStringUtil.formatTime(secondsTotal, false)} - ${FlxStringUtil.formatTime(Math.floor(songLength / 1000), false)})';
					songNameTxt.updateHitbox();
					songNameTxt.screenCenter(X);
				}
			}
		}

		super.update(elapsed);
	}

	override function beatHit(beat:Int)
	{
		healthBar.iconScale = 1.2;
	}

	override function changedOptions(changed:Array<String>)
	{
        if (ClientPrefs.etternaHUD != 'ITG') {
            healthBar.healthBarBG.y = FlxG.height * (ClientPrefs.downScroll ? 0.11 : 0.89);
            healthBar.y = healthBarBG.y + 5;
            healthBar.iconP1.y = healthBar.y - 75;
            healthBar.iconP2.y = healthBar.y - 75;
        }

		updateTimeBarType();
	}

	var tweenProg:Float = 0;

	override function songStarted()
	{
		FlxTween.num(0, 1, 0.5, 
			{
				ease: FlxEase.circOut,
				onComplete: function(tw:FlxTween){
					tweenProg = 1;
					updateTimeBarAlpha();
				}
			}, 
			function(prog:Float){
				tweenProg = prog;
				updateTimeBarAlpha();
			}
		);
	}

	override function songEnding()
	{
        if (ClientPrefs.etternaHUD == 'ITG') {
			if (timeTxt != null || timeBarBG != null || timeBar != null) {
				timeBarBG.exists = false;
				timeBar.exists = false;
				timeTxt.exists = false;
			}
		} else {
			if (songPosBar != null || bar != null || songNameTxt != null) {
				songPosBar.exists = false;
				bar.exists = false;
				songNameTxt.exists = false;
			}
		}
	}

    override function reloadHealthBarColors(dadColor:FlxColor, bfColor:FlxColor)
	{
        if (ClientPrefs.etternaHUD == 'ITG') {
			if (healthBar != null){
				healthBar.createFilledBar(
					FlxColor.BLACK,
					0xFFdce0e6
				);
				healthBar.updateBar();
			}

			if (healthBar2 != null){
				healthBar2.createFilledBar(
					FlxColor.BLACK,
					0xFFdce0e6
				);
				healthBar2.updateBar();
			}	
		} else {
			if (healthBar != null){
				healthBar.createFilledBar(dadColor, bfColor);
				healthBar.updateBar();
			}	
		}
    }

}