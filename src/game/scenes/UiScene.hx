package game.scenes;

import core.Scene;
import core.Sound;
import core.Sprite;
import core.Timers;
import core.Tweens;
import core.Types;
import core.Util;
import game.data.FloorData;
import game.data.GameData;
import game.data.MusicData;
import game.data.ScaleData;
import game.objects.ParticleSprite;
import game.ui.Bar;
import game.ui.Button;
import game.ui.SpellBg;
import game.ui.UiText;
import kha.Assets;
import kha.input.KeyCode;
import kha.input.Mouse;

enum UiState {
    InGame;
    PostGame;
}

typedef ScaleChoice = {
    var spellNum:Int;
    var scale:Scale;
}

class UiScene extends Scene {
    public var exText:Sprite;
    public var portrait:Sprite;

    public var healthBar:Bar;
    public var healthNum:Int;
    public var recoveryBar:Bar;
    public var recoveryNum:Int;
    public var experienceBar:Bar;
    public var experienceNum:Int;
    public var experienceMaxNum:Int;
    var particleSprite:ParticleSprite;

    var attNum:Sprite;
    var defNum:Sprite;
    var dexNum:Sprite;
    var spdNum:Sprite;

    var attButton:Button;
    var defButton:Button;
    var dexButton:Button;
    var spdButton:Button;
    var healthButton:Button;

    var spells:Array<SpellBg> = [];
    public var selectedSpell:Int;

    var scaleChoices:Array<ScaleChoice> = [];
    var scaleButtons:Array<Button> = [];
    var selectedScale:Int = 0;

    public var buttonClicked:Bool = false;
    var hovered:Bool = false;
    var state:UiState = InGame;
    var submitButton:Button;

    var updateReadyText:Sprite;
    var tooFarText:Sprite;
    var tooFarTime:Float = 0.0;

    var leftCurtain:Sprite;
    var rightCurtain:Sprite;
    var inTween:Tween;
    var outTween:Tween;

    var prevLevel:Int;

    override function create () {
        camera.scale.set(2, 2);
        addSprite(portrait = new Sprite(new Vec2(2, 2), Assets.images.portraits));

        // bars
        addSprite(healthBar = new Bar(40, 2, 100, 8, [{ min: 0.0, color: 0xffd95763 }, { min: 0.2, color: 0xff37946e }], 100, 100));
        addSprite(experienceBar = new Bar(40, 16, 50, 2, [{ min: 0.0, color: 0xfffbf236 }], GameData.playerData.experience, GameData.playerData.maxExperience));
        addSprite(recoveryBar = new Bar(40, 24, 50, 2, [{ min: 0.0, color: 0xff5b6ee1 }, { min: 1.0, color: 0xff639bff }], 100, 100));

        addSprite(particleSprite = new ParticleSprite(new Vec2(0, 0), LevelUp));
        particleSprite.setPosition(86, 14);
        particleSprite.visible = false;

        for (i in 0...GameData.playerData.spells.length) {
            final spellBg = new SpellBg(i, GameData.playerData.spells[i].imageIndex, () -> {
                changeSpell(i);
                buttonClicked = true;
            }, () -> {
                hovered = true;
            });

            addSprite(spellBg);
            spells.push(spellBg);
        }

        // stats
        addSprite(new Sprite(new Vec2(2, 40), Assets.images.stats_bg));

        addSprite(getText(4, 43, 'ATT:', 0xff9badb7));
        addSprite(getText(4, 57, 'DEF:', 0xff9badb7));
        addSprite(getText(4, 71, 'SPD:', 0xff9badb7));
        addSprite(getText(4, 85, 'DEX:', 0xff9badb7));

        addSprite(attNum = getText(26, 43));
        addSprite(defNum = getText(26, 57));
        addSprite(spdNum = getText(26, 71));
        addSprite(dexNum = getText(26, 85));

        addSprite(attButton = makePlusButton(42, 42, 'ATT'));
        addSprite(defButton = makePlusButton(42, 56, 'DEF'));
        addSprite(spdButton = makePlusButton(42, 70, 'SPD'));
        addSprite(dexButton = makePlusButton(42, 84, 'DEX'));
        addSprite(healthButton = new Button(
            new Vec2(4, 98),
            Assets.images.button_slice,
            new IntVec2(8, 8),
            new IntVec2(50, 14),
            0xffffffff,
            'max hp+',
            () -> {
                addExperience('HEALTH');
            },
            () -> {
                hovered = true;
            }
        ));

        addSprite(updateReadyText = getText(3, 117, 'Update Ready'));
        updateReadyText.visible = false;

        addSprite(tooFarText = getText(124, 100, 'Too Far'));
        tooFarText.visible = false;

        addSprite(getText(276, 2, 'Floor ${GameData.floorNum + 1}', 0xff9badb7));

        leftCurtain = new Sprite(new Vec2(0, 0));
        rightCurtain = new Sprite(new Vec2(180, 0));

        leftCurtain.makeRect(0xff222034, new IntVec2(160, 180));
        rightCurtain.makeRect(0xff222034, new IntVec2(160, 180));

        addSprite(leftCurtain);
        addSprite(rightCurtain);

        tweenIn();

        prevLevel = GameData.playerData.level;
        selectedSpell = GameData.selectedSpell;
    }

    override function update (delta:Float) {}

    public function forceUpdate (delta:Float) {
        if (inTween != null) {
            leftCurtain.setPosition(-inTween.value * 160, 0);
            rightCurtain.setPosition(160 + inTween.value * 160, 0);
        }

        if (outTween != null) {
            leftCurtain.setPosition(outTween.value * 160 - 160, 0);
            rightCurtain.setPosition(320 + -outTween.value * 160, 0);
        }

        if (state == InGame) {
            buttonClicked = false;
            healthBar.value = healthNum;
            recoveryBar.value = recoveryNum;
            experienceBar.value = experienceNum;
            experienceBar.max = experienceMaxNum;

            if (game.keys.justPressed(KeyCode.One)) {
                changeSpell(0);
            }

            if (game.keys.justPressed(KeyCode.Two)) {
                changeSpell(1);
            }

            if (game.keys.justPressed(KeyCode.Three)) {
                changeSpell(2);
            }

            if (game.keys.justPressed(KeyCode.Four)) {
                changeSpell(3);
            }

            if (prevLevel != GameData.playerData.level) {
                levelUp();
            }

            prevLevel = GameData.playerData.level;

            if (GameData.playerData.pointsAvailable.length > 0) {
                attButton.state = Idle;
                defButton.state = Idle;
                spdButton.state = Idle;
                dexButton.state = Idle;
                healthButton.state = Idle;
                updateReadyText.visible = true;
            } else {
                attButton.state = Disabled;
                defButton.state = Disabled;
                spdButton.state = Disabled;
                dexButton.state = Disabled;
                healthButton.state = Disabled;
                updateReadyText.visible = false;
            }

            attNum.text = GameData.playerData.attack + '';
            defNum.text = GameData.playerData.defense + '';
            spdNum.text = GameData.playerData.speed + '';
            dexNum.text = GameData.playerData.dexterity + '';

            tooFarTime -= delta;
            tooFarText.visible = tooFarTime > 0.0;
        }

        hovered = false;
        super.update(delta);

        if (particleSprite.done) {
            particleSprite.visible = false;
        }

        if (hovered) {
            Mouse.get().setSystemCursor(Pointer);
        } else {
            Mouse.get().setSystemCursor(MouseCursor.Default);
        }

        if (state == PostGame) {
            for (i in 0...scaleButtons.length) {
                final sb = scaleButtons[i];
                if (selectedScale == i) {
                    sb.setFromState(Pressed);
                }
            }
        }
    }

    function addExperience (stat:String) {
        buttonClicked = true;

        final amount = GameData.playerData.pointsAvailable.shift();

        switch (stat) {
            case 'ATT': GameData.playerData.attack += amount;
            case 'DEF': GameData.playerData.defense += amount;
            case 'SPD': GameData.playerData.speed += amount;
            case 'DEX': GameData.playerData.dexterity += amount;
            case 'HEALTH': {
                GameData.playerData.maxHealth += amount * 2;
                healthBar.destroy();
                healthBar = new Bar(
                    40,
                    2,
                    GameData.playerData.maxHealth,
                    8,
                    [{ min: 0.0, color: 0xffd95763 }, { min: 0.2, color: 0xff37946e }],
                    GameData.playerData.maxHealth,
                    healthNum
                );
                addSprite(healthBar);
            }
        }

        if (GameData.playerData.attack >= 100) GameData.playerData.attack = 99;
        if (GameData.playerData.defense >= 100) GameData.playerData.defense = 99;
        if (GameData.playerData.speed >= 100) GameData.playerData.speed = 99;
        if (GameData.playerData.dexterity >= 100) GameData.playerData.dexterity = 99;
    }

    function changeSpell (num:Int) {
        if (num < GameData.playerData.spells.length) {
            selectedSpell = num;
            for (spell in spells) {
                spell.selected = false;
            }
            spells[num].selected = true;
            GameData.selectedSpell = selectedSpell;
        }
    }

    function makePlusButton (x:Int, y:Int, stat:String):Button {
        return new Button(
            new Vec2(x, y),
            Assets.images.button_slice,
            new IntVec2(8, 8),
            new IntVec2(12, 12),
            0xffffffff,
            '+',
            () -> {
                addExperience(stat);
            },
            () -> {
                hovered = true;
            }
        );
    }

    public function destroyUi () {
        for (s in sprites) {
            if (s != portrait) {
                s.destroy();
            }
        }
    }

    // ugly
    public function setupScales () {
        if (GameData.floorNum == NUM_FLOORS) {
            gameOver(true);
            return;
        }
        state = PostGame;
        destroyUi();

        // scalesSelected = [];
        final scaleList = [];
        var i = 0;
        var scalesFound = true;
        while (scalesFound) {
            scalesFound = false;
            // this assumes scales and spells are stored in the same spot
            // in their respective arrays
            for (scaleNum in 0...GameData.playerData.scales.length) {
                if (GameData.playerData.scales[scaleNum][i] != null) {
                    scaleList.push({ spellNum: scaleNum, scale: GameData.playerData.scales[scaleNum][i] });
                    scalesFound = true;
                }
            }

            i++;
        }

        for (o in GameData.playerData.otherScales) {
            scaleList.push({ spellNum: -1, scale: o });
        }

        scaleList.sort((s1, s2) -> scaleData[s1.scale].level - scaleData[s2.scale].level);

        scaleChoices = scaleList.slice(0, 2);
        if (scaleList.length > 2) {
            final index = intClamp(2 + Math.floor(GameData.random.GetFloat() * GameData.floorNum), 2, scaleList.length);
            scaleChoices.push(scaleList[index]);
        }

        for (i in 0...scaleChoices.length) {
            // TODO: description title and image
            final scaleButton = new Button(
                new Vec2(80, 40 + i * 32),
                Assets.images.button_slice,
                new IntVec2(8, 8),
                new IntVec2(160, 24),
                0xffffffff,
                '',
                () -> {
                    selectScale(i);
                },
                () -> {
                    hovered = true;
                }
            );
            scaleButtons.push(scaleButton);
            addSprite(scaleButton);

            final spell = GameData.playerData.spells[scaleChoices[i].spellNum];

            // spell image
            final image = new Sprite(new Vec2(80, 44 + i * 32), Assets.images.spell_image, new IntVec2(32, 32));
            image.tileIndex = spell != null && spell.imageIndex != null ? spell.imageIndex : scaleData[scaleChoices[i].scale].index;
            addSprite(image);

            // spell name + description
            if (scaleChoices[i].spellNum == -1) {
                addSprite(getText(108, 46 + i * 32, scaleData[scaleChoices[i].scale].text));
            } else {
                addSprite(getText(108, 42 + i * 32, spell.name));
                addSprite(getText(108, 52 + i * 32, scaleData[scaleChoices[i].scale].text));
            }
        }

        addSprite(submitButton = new Button(
            new Vec2(120, 140),
            Assets.images.button_slice,
            new IntVec2(8, 8),
            new IntVec2(80, 24),
            0xffffffff,
            'Next Level',
            () -> {
                submitScale();
            },
            () -> {
                hovered = true;
            }
        ));

        // pick 2-3 scales
        // the further level we're on, the more likely it's what we want?
        // tie each button to a spell num _and_ a scale
            // or scales is separate from spells?
    }

    function selectScale (num:Int) {
        selectedScale = num;
        // TODO: highlight certain scale bg
    }

    function submitScale () {
        final scale = scaleChoices[selectedScale];
        final spell = GameData.playerData.spells[scale.spellNum];

        switch (scale.scale) {
            case Power50:
                spell.power = Math.round(spell.power * 1.5);
            case Vel50:
                spell.vel = Math.round(spell.vel * 1.5);
            case LearnCastlight:
                GameData.addSpell(Castlight);
            case LearnFireball:
                GameData.addSpell(Fireball);
            case UpgradeWindstorm:
                GameData.replaceSpell(scale.spellNum, Windstorm);
            case UpgradeRainstorm:
                GameData.replaceSpell(scale.spellNum, Rainstorm);
            case UpgradeFirestorm:
                GameData.replaceSpell(scale.spellNum, Firestorm);
            case UpgradeLightstorm:
                GameData.replaceSpell(scale.spellNum, Lightstorm);
            case AllTimesLess25:
                for (s in GameData.playerData.spells) {
                    s.preTime *= .75;
                    s.time *= .75;
                }
            case Dex15:
                GameData.playerData.dexterity += 15;
                if (GameData.playerData.dexterity > 100) {
                    GameData.playerData.dexterity = 99;
                }
            case Def15:
                GameData.playerData.defense += 15;
                if (GameData.playerData.defense > 100) {
                    GameData.playerData.defense = 99;
                }
            case Spd10:
                GameData.playerData.speed += 10;
                if (GameData.playerData.speed > 100) {
                    GameData.playerData.speed = 99;
                }
            case Att10:
                GameData.playerData.attack += 10;
                if (GameData.playerData.attack > 100) {
                    GameData.playerData.attack = 99;
                }
            default:
                // throw 'Not Implemented!';
        }

        if (scale.spellNum == -1) {
            GameData.playerData.otherScales.remove(scale.scale);
        } else {
            GameData.playerData.scales[scale.spellNum].remove(scale.scale);
        }

        GameData.nextRound();

        timers.addTimer(new Timer(1.0, () -> {
            game.switchScene(new WorldScene());
        }));
        submitButton.destroy();
        tweenOut();
    }

    function tweenIn () {
        tweens.addTween(inTween = new Tween(0.0, 1.0, 1.0, () -> {
            inTween = null;
            leftCurtain.setPosition(-160, 0);
            rightCurtain.setPosition(320, 0);
        }));
    }

    function tweenOut () {
        leftCurtain = new Sprite(new Vec2(-160, 0));
        rightCurtain = new Sprite(new Vec2(320, 0));

        leftCurtain.makeRect(0xff222034, new IntVec2(160, 180));
        rightCurtain.makeRect(0xff222034, new IntVec2(160, 180));

        addSprite(leftCurtain);
        addSprite(rightCurtain);

        tweens.addTween(outTween = new Tween(0.0, 1.0, 0.5, () -> {
            outTween = null;
            leftCurtain.setPosition(0, 0);
            rightCurtain.setPosition(160, 0);
        }));
    }

    public function levelUp () {
        Sound.play(Assets.sounds.depths_sfx_levelup, 0.5);
        particleSprite.animation.play('explode-up', true);
        particleSprite.done = false;
        particleSprite.visible = true;
    }

    public function gameOver (isVictory:Bool) {
        destroyUi();

        Sound.play(Assets.sounds.depths_sfx_die1, 0.75);
        portrait.color = 0xff847e87;
        timers.addTimer(new Timer(1.0, () -> {
            MusicData.playMusic();

            var quitButton:Button;
            quitButton = new Button(
                new Vec2(isVictory ? 136 : 64, 132),
                Assets.images.button_slice,
                new IntVec2(8, 8),
                new IntVec2(48, 16),
                0xffffffff,
                'Quit',
                () -> {
                    quitButton.destroy();
                    tweenOut();
                    game.switchScene(new TitleScene());
                },
                () -> {
                    hovered = true;
                }
            );

            if (isVictory) {
                addSprite(getText(142, 50, 'Victory!'));

                timers.addTimer(new Timer(2.5, () -> {
                    addSprite(getText(88, 72, 'Thank you so much for playing.'));
                }));

                timers.addTimer(new Timer(5.0, () -> {
                    addSprite(quitButton);
                }));
            } else {
                addSprite(getText(64, 50, 'Game Over'));
                timers.addTimer(new Timer(1.0, () -> {
                    addSprite(quitButton);
                }));
            }
        }));
    }

    public function tooFar () {
        Sound.play(Assets.sounds.depths_sfx_toofar, 0.5);
        tooFarTime = 1.0;
    }
}
