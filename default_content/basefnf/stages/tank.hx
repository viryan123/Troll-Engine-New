var tankGround:BGSprite;
var tankmanRun;
var boppers = [];

function onLoad()
{
	var sky:BGSprite = new BGSprite('tank/tankSky', -400, -400, 0, 0);
	add(sky);

	if(!ClientPrefs.lowQuality)
	{
		var clouds:BGSprite = new BGSprite('tank/tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
		clouds.active = true;
		clouds.velocity.x = FlxG.random.float(5, 15);
		add(clouds);

		var mountains:BGSprite = new BGSprite('tank/tankMountains', -300, -20, 0.2, 0.2);
		mountains.setGraphicSize(Std.int(1.2 * mountains.width));
		mountains.updateHitbox();
		add(mountains);

		var buildings:BGSprite = new BGSprite('tank/tankBuildings', -200, 0, 0.3, 0.3);
		buildings.setGraphicSize(Std.int(1.1 * buildings.width));
		buildings.updateHitbox();
		add(buildings);
	}

	var ruins:BGSprite = new BGSprite('tank/tankRuins',-200,0,.35,.35);
	ruins.setGraphicSize(Std.int(1.1 * ruins.width));
	ruins.updateHitbox();
	add(ruins);

	if(!ClientPrefs.lowQuality)
	{
		var smokeLeft:BGSprite = new BGSprite('tank/smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
		add(smokeLeft);
		var smokeRight:BGSprite = new BGSprite('tank/smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
		add(smokeRight);

		var tankWatchtower = new BGSprite('tank/tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
		boppers.push(tankWatchtower);
		add(tankWatchtower);
	}

	tankGround = new BGSprite('tank/tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
	add(tankGround);

	var FlxTypedGroup = getClass("flixel.group.FlxTypedGroup");
	tankmanRun = new FlxTypedGroup();
	add(tankmanRun);
	this.spriteMap.set("tankmanRun", tankmanRun);

	var ground:BGSprite = new BGSprite('tank/tankGround', -420, -150);
	ground.setGraphicSize(Std.int(1.15 * ground.width));
	ground.updateHitbox();
	add(ground);
	update(0);
	
	boppers.push(foreground.add(new BGSprite('tank/tank0', -500, 650, 1.7, 1.5, ['fg'])));
	if(!ClientPrefs.lowQuality) boppers.push(foreground.add(new BGSprite('tank/tank1', -300, 750, 2, 0.2, ['fg'])));
	boppers.push(foreground.add(new BGSprite('tank/tank2', 450, 940, 1.5, 1.5, ['foreground'])));
	if(!ClientPrefs.lowQuality) boppers.push(foreground.add(new BGSprite('tank/tank4', 1300, 900, 1.5, 1.5, ['fg'])));
	boppers.push(foreground.add(new BGSprite('tank/tank5', 1620, 700, 1.5, 1.5, ['fg'])));
	if(!ClientPrefs.lowQuality) boppers.push(foreground.add(new BGSprite('tank/tank3', 1300, 1200, 3.5, 2.5, ['fg'])));	
}

var tankX:Float = 400;
var tankSpeed:Float = FlxG.random.float(5, 7);
var tankAngle:Float = FlxG.random.int(-90, 45);

function update(elapsed)
{
	if(!game.inCutscene)
	{
		tankAngle += elapsed * tankSpeed;
		tankGround.angle = tankAngle - 90 + 15;
		tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
		tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
	}
}

function dance(){
	for (guy in boppers){
		guy.dance();
	}
}

script.set("onSongStart", dance);
script.set("onBeatHit", dance);
script.set("onCountdownTick", dance);