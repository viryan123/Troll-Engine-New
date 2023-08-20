var bg;
var dark;
var light;
var bulb;
var stageCurtains;
var flickerTween;
var flickerTween2;

function onLoad(stage, foreground)
{
    var add = function(o){
        return stage.add(o);
    }

	bg = new FlxSprite(900, 525);
	bg.loadGraphic(Paths.image('lab/bg'));
	//bg.antialiasing = ClientPrefs.globalAntialiasing;
	bg.setGraphicSize(Std.int(bg.width * 1.3));
	bg.updateHitbox();
	bg.active = false;

	// add to the final array
	add(bg);

	dark = new FlxSprite(900, 405);
	dark.loadGraphic(Paths.image('lab/dark'));
	dark.setGraphicSize(Std.int(dark.width * 1.3));
	dark.updateHitbox();
	//dark.antialiasing = ClientPrefs.globalAntialiasing;
	dark.active = false;
	dark.origin.set(800, 0);

	// add to the final array
	foreground.add(dark);

	light = new FlxSprite(900, 405);
	light.loadGraphic(Paths.image('lab/light'));
	light.setGraphicSize(Std.int(light.width * 1.3));
	light.alpha = 0.8;
	light.updateHitbox();
	//light.antialiasing = ClientPrefs.globalAntialiasing;
	light.active = false;
	light.origin.set(800, 0);
	flickerTween = FlxTween.tween(light, {alpha: 0}, 0.25, {ease: FlxEase.bounceInOut, type: 4});
	flickerTween.active = true;

	// add to the final array
	foreground.add(light);

	bulb = new FlxSprite(0, 0);
	bulb.loadGraphic(Paths.image('lab/bulb'));
	bulb.setGraphicSize(Std.int(bulb.width * 1.3));
	bulb.updateHitbox();
	//bulb.antialiasing = ClientPrefs.globalAntialiasing;
	bulb.active = false;
	bulb.origin.set(800, 0);
	flickerTween2 = FlxTween.tween(light, {alpha: 0}, 0.25, {ease: FlxEase.bounceInOut, type: 4});
	flickerTween2.active = true;

	// add to the final array
	foreground.add(dark);
	foreground.add(bulb);
}

function onSongStart()
	{
		/*if (PlayState.curSong == 'Mindless')
			{
				bg.visible = false;
				dark.visible = false;
				light.visible = false;
				bulb.visible = false;
			}*/
	}

function onMoveCamera(focus:String)
    {
        if (focus == 'dad') {
			if (game.dad.curCharacter != 'jake')
                game.defaultCamZoom = 0.9;
			else
                game.defaultCamZoom = 1.2;

        }
        else
            game.defaultCamZoom = 1.1;
    }

function onUpdate (elapsed) {
	light.angle = Math.sin((Conductor.songPosition / 1000) * (Conductor.bpm / 60) * 1.0) * 5;
	dark.angle = light.angle;
	bulb.angle = light.angle;
}

function onStepHit()
{
	/*if (curStep == 296)
	{
		if (PlayState.curSong == 'Mindless')
			{
				bg.visible = true;
				dark.visible = true;
				light.visible = true;
				bulb.visible = true;
			}
	}*/
}

function onEvent(event:String, value1:String, value2:String)
    {
     if (event == 'Apple Filter')
        {
             if (value1 == 'on') 
            {
                bg.visible = false;
				dark.visible = false;
				light.visible = false;
				bulb.visible = false;
            }
             else if (value1 == 'off')
            {
                bg.visible = true;
				dark.visible = true;
				light.visible = true;
				bulb.visible = true;
            }
        }
    }

function onPause()
{
	flickerTween.active = false;
	flickerTween2.active = false;
}

function onResume()
{
	flickerTween.active = false;
	flickerTween2.active = false;
}