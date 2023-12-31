var halloweeBG:FlxSprite;

function onLoad(stage, foreground)
{
	var add = function(o){
		return stage.add(o);
	}

	var hallowTex = Paths.getSparrowAtlas('spooky/halloween_bg');
	if(!ClientPrefs.lowQuality) {
		halloweenBG = new FlxSprite(-200, -100);
		halloweenBG.frames = hallowTex;
		halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
		halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
		halloweenBG.animation.play('idle');
		halloweenBG.antialiasing = true;
	}
	else 
		halloweenBG = new BGSprite('spooky/halloween_bg_low', -200, -100);
	
	halloweenBG.scrollFactor.set(1, 1);
	add(halloweenBG);

}

var lightningStrikeBeat = 0;
var lightningOffset = 0;

function lightningStrikeShit(sound:Bool):Void
{
	if(sound)
	FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
	if(!ClientPrefs.lowQuality) halloweenBG.animation.play('lightning');

	lightningStrikeBeat = curBeat;
	lightningOffset = FlxG.random.int(8, 24);

	game.boyfriend.playAnim('scared', true);
	game.gf.playAnim('scared', true);
}

function onEvent(name, val1, val2)
{
	if (name == "Lightning")
	{
		var sound = false;
		if(val1!=null && val1.toLowerCase()=='true')sound=true;
		lightningStrikeShit(sound);
	}
}

function onBeatHit(){
	if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
	{
		lightningStrikeShit(true);
	}
}