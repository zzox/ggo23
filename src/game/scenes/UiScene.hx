package game.scenes;

import core.Scene;
import core.Sprite;
import core.Types;
import game.data.GameData;
import game.ui.Bar;
import game.ui.Button;
import game.ui.SpellBg;
import game.ui.UiText;
import kha.Assets;
import kha.input.KeyCode;

class UiScene extends Scene {
    public var exText:Sprite;

    public var healthBar:Bar;
    public var healthNum:Int;
    public var healthMax:Int;
    public var recoveryBar:Bar;
    public var recoveryNum:Int;
    // public var experienceBar:Sprite;
    // public var experienceNum:Int;

    var attNum:Sprite;
    var defNum:Sprite;
    var dexNum:Sprite;
    var spdNum:Sprite;

    var spells:Array<SpellBg> = [];
    public var selectedSpell:Int = 0;

    public var buttonClicked:Bool = false;

    override function create () {
        camera.scale.set(2, 2);
        addSprite(new Sprite(new Vec2(2, 2), Assets.images.portraits));

        // bars
        addSprite(healthBar = new Bar(40, 2, 100, 8, [{ min: 0.0, color: 0xffd95763 }, { min: 0.2, color: 0xff37946e }], 100, 100));
        addSprite(recoveryBar = new Bar(40, 16, 50, 2, [{ min: 0.0, color: 0xff5b6ee1 }, { min: 1.0, color: 0xff639bff }], 100, 100));
        // TODO: experienceBar

        for (i in 0...GameData.playerData.spells.length) {
            final spellBg = new SpellBg(i, () -> {
                changeSpell(i);
                buttonClicked = true;
            });

            addSprite(spellBg);
            spells.push(spellBg);
        }

        // stats
        addSprite(new Sprite(new Vec2(2, 40), Assets.images.stats_bg));

        addSprite(getText(4, 42, 'ATT:'));
        addSprite(getText(4, 56, 'DEF:'));
        addSprite(getText(4, 70, 'SPD:'));
        addSprite(getText(4, 84, 'DEX:'));

        addSprite(attNum = getText(24, 42));
        addSprite(defNum = getText(24, 56));
        addSprite(spdNum = getText(24, 70));
        addSprite(dexNum = getText(24, 84));

        makeButton(48, 42, 'ATT');
        makeButton(48, 56, 'DEF');
        makeButton(48, 70, 'SPD');
        makeButton(48, 84, 'DEX');

        // addSprite(testButton = new Button(200, 100, Assets.images.button_bg));
    }

    override function update (delta:Float) {}

    public function forceUpdate (delta:Float) {
        buttonClicked = false;
        healthBar.value = healthNum;
        recoveryBar.value = recoveryNum;

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

        attNum.text = GameData.playerData.attack + '';
        defNum.text = GameData.playerData.defense + '';
        spdNum.text = GameData.playerData.speed + '';
        dexNum.text = GameData.playerData.dexterity + '';

        super.update(delta);
    }

    function addExperience (stat:String) {
        buttonClicked = true;
        trace('stat', stat);
        // get next num
        switch (stat) {
            case 'ATT': GameData.playerData.attack += 3;
            case 'DEF': GameData.playerData.defense += 3;
            case 'SPD': GameData.playerData.speed += 3;
            case 'DEX': GameData.playerData.dexterity += 3;
        }

        if (GameData.playerData.attack >= 100) GameData.playerData.attack = 99;
        if (GameData.playerData.defense >= 100) GameData.playerData.defense = 99;
        if (GameData.playerData.speed >= 100) GameData.playerData.speed= 99;
        if (GameData.playerData.dexterity >= 100) GameData.playerData.dexterity = 99;
    }

    function changeSpell (num:Int) {
        if (num < GameData.playerData.spells.length) {
            selectedSpell = num;
            for (spell in spells) {
                spell.selected = false;
            }
            spells[num].selected = true;
        }
    }

    function makeButton (x:Int, y:Int, stat:String) {
        addSprite(new Button(
            new Vec2(x, y),
            Assets.images.button_slice,
            new IntVec2(8, 8),
            new IntVec2(12, 12),
            0xffffffff,
            '+',
            () -> {
                addExperience(stat);
            }
        ));
    }

    // public function addTestButton (onClick:() -> Void) {
    //     function clickMe () {
    //         buttonClicked = true;
    //         onClick();
    //     }

    //     addSprite(testButton = new Button(new Vec2(4, 60), Assets.images.blue_button_slice, new IntVec2(18, 18), 0xffffe9c5, 'Customer', clickMe));
    // }

    public function activateDebugGroup () {}
    public function deactivateDebugGroup () {}
}
