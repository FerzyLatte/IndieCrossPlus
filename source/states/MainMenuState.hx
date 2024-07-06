package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options',
		'credits'
	];

	var val:FlxSprite;
	var sideChars:FlxSprite;
	var logo:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(0, -90).loadGraphic(Paths.image('BG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter(X);
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		
		val = new FlxSprite(0,-90).makeGraphic(1, 1, 0xFF000000);
		val.scale.set(635, FlxG.height);
		val.alpha = 0.25;
		val.antialiasing = ClientPrefs.data.antialiasing;
		val.scrollFactor.set(0, yScroll);
		val.updateHitbox();
		val.screenCenter(X);
		add(val);

		logo = new FlxSprite(0,-10).loadGraphic(Paths.image('IndieImages/logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.scrollFactor.set(0, 0);
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 200 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 125) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.loadGraphic(Paths.image('IndieImages/' + optionShit[i]));
			menuItem.alpha = 0.5;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			menuItem.centerOffsets();
			menuItem.screenCenter(X);
		}
		sideChars = new FlxSprite(0);
		sideChars.frames = Paths.getSparrowAtlas('IndieImages/sideFellas');
		sideChars.animation.addByPrefix('idle', "SketchMove", 4, true);
		sideChars.animation.play('idle');
		sideChars.antialiasing = ClientPrefs.data.antialiasing;
		sideChars.scrollFactor.set(0, 0);
		sideChars.updateHitbox();
		sideChars.screenCenter();
		add(sideChars);

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Indie Cross Plus V1", 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem();

		super.create();

		FlxG.camera.follow(camFollow, null, 9);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					var obj = menuItems.members[curSelected];
					remove(obj);
					insert(5, obj);
					obj.setColorTransform(1,1,1,1, 200,200,200);
					FlxTween.tween(obj, {y:FlxG.height/2 - 50}, 0.75, {ease: FlxEase.quartOut});
					FlxTween.tween(val.scale, {x:obj.width}, 1, {ease: FlxEase.quartOut});
					FlxTween.tween(obj.colorTransform, {redOffset:0, greenOffset:0, blueOffset:0}, 1, {
						ease: FlxEase.sineIn,
						onComplete: function(uwu:FlxTween) {
							switch (optionShit[curSelected]) {
								case 'story_mode':
									MusicBeatState.switchState(new StoryMenuState());
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayState());
								case 'credits':
									MusicBeatState.switchState(new CreditsState());
								case 'options':
									MusicBeatState.switchState(new OptionsState());
									OptionsState.onPlayState = false;
									if (PlayState.SONG != null) {
										PlayState.SONG.arrowSkin = null;
										PlayState.SONG.splashSkin = null;
										PlayState.stageUI = 'normal';
									}
							}
						}
					});
			
					for (i in 0...menuItems.members.length)
					{
						if (i == curSelected)
							continue;
						FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								menuItems.members[i].kill();
							}
						});
					}
				}
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}
		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].alpha = 0.5;
		menuItems.members[curSelected].screenCenter(X);
		FlxTween.cancelTweensOf(menuItems.members[curSelected]);
		FlxTween.tween(menuItems.members[curSelected].scale, {x:1, y:1}, 0.1, {ease:FlxEase.quadOut});
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].alpha = 1;
		menuItems.members[curSelected].setColorTransform(1,1,1,1, 100,100,100);
		FlxTween.tween(menuItems.members[curSelected].colorTransform, {redOffset:0, greenOffset:0, blueOffset:0}, 0.2);
		FlxTween.tween(menuItems.members[curSelected].scale, {x:1.05, y:1.05}, 0.2, {ease:FlxEase.backOut});
		menuItems.members[curSelected].screenCenter(X);
	}

	override function beatHit()
	{
		FlxTween.cancelTweensOf(logo.scale);
		logo.scale.set(1.1,1.05);
		FlxTween.tween(logo.scale, {x:1, y:1}, 0.45, {ease:FlxEase.cubeOut});
		super.beatHit();
    }	
}
