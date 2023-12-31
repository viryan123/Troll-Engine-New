var instance = getInstance();
var defaultZoom:Float = instance.defaultCamZoom;
var twnN = 0;

var lastTween = null;

function doZoomTween(zoom:Float, duration:Float)
{
	zoom = Math.isNaN(zoom) ? defaultZoom : zoom;
	duration = Math.isNaN(duration) ? 1 : Math.abs(duration);
	
	if (lastTween != null)
	{
		lastTween.cancel();
		lastTween.destroy();
		lastTween = null;
	}
	
	if (duration == 0){
		instance.defaultCamZoom = zoom;
	}else{
		lastTween = FlxTween.num(
			instance.defaultCamZoom, 
			zoom, 
			duration, 
			{
				ease: FlxEase.quadInOut, 
				onUpdate: function(twn){
					//instance.camGame.zoom = twn.value;
					instance.defaultCamZoom = twn.value;
				},
				onComplete: function(wtf){
					//instance.camGame.zoom = zoom;
                    instance.defaultCamZoom = zoom;
					if (lastTween == wtf) lastTween = null;
				}
			}
		);
	
		instance.modchartTweens.set(scriptName + twnN, lastTween);
	}
}

function shouldPush(eventNote):Bool{
	return true;
}

function onPush(eventNote){}

function onLoad(){}

function getOffset(eventNote):Float
{
	var dur = Std.parseFloat(eventNote.value2);

	return (dur < 0) ? (dur * 1000) : 0; 
}

function ease(e:EaseFunction, t:Float, b:Float, c:Float, d:Float)
{ // elapsed, begin, change (ending-beginning), duration
    var time = t / d;
    return c * e(time) + b;
}

function onTrigger(value1:Dynamic, value2:Dynamic, time:Float){
	var zoom:Float = Std.parseFloat(value1);
    var duration:Float = Std.parseFloat(value2);

    zoom = Math.isNaN(zoom) ? defaultZoom : zoom;
	duration = Math.isNaN(duration) ? 1 : Math.abs(duration);

    var endTime = time + (duration * 1000);
    if(lastTween!=null){
        lastTween.cancel();
        lastTween = null;
    }
    if(Conductor.songPosition >= endTime){
        instance.defaultCamZoom = zoom;
    }else{
        var length = (endTime - Conductor.songPosition)/1000;
        var easeFunc = FlxEase.quadInOut;

        var passed = Conductor.songPosition - time;
        var startVal = instance.defaultCamZoom;
        var change = zoom - startVal;
        instance.defaultCamZoom = ease(easeFunc, passed, instance.defaultCamZoom, change, endTime - Conductor.songPosition);
        lastTween = FlxTween.num(instance.defaultCamZoom, zoom, length, {
            ease: easeFunc,
            onComplete: function(tw:FlxTween){
                lastTween = null;
                instance.defaultCamZoom = zoom;
            },
            onUpdate: function(tw:FlxTween){
                instance.defaultCamZoom = tw.value;
            }
        });
    }

/* 	doZoomTween(Std.parseFloat(value1), Std.parseFloat(value2)); */
}