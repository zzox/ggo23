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

enum UiState {
    InGame;
    PostGame;
}

class UiScene extends Scene {
    public var exText:Sprite;

    public var healthBar:Bar;
    public var healthNum:Int;
    public var recoveryBar:Bar;
    public var recoveryNum:Int;
    public var experienceBar:Bar;
    public var experienceNum:Int;
    public var experienceMaxNum:Int;

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
    public var selectedSpell:Int = 0;

    public var buttonClicked:Bool = false;

    public var state:UiState = InGame;

    override function create () {
        camera.scale.set(2, 2);
        addSprite(new Sprite(new Vec2(2, 2), Assets.images.portraits));

        // bars
        addSprite(healthBar = new Bar(40, 2, 100, 8, [{ min: 0.0, color: 0xffd95763 }, { min: 0.2, color: 0xff37946e }], 100, 100));
        addSprite(experienceBar = new Bar(40, 16, 50, 2, [{ min: 0.0, color: 0xfffbf236 }], GameData.playerData.experience, GameData.playerData.maxExperience));
        addSprite(recoveryBar = new Bar(40, 24, 50, 2, [{ min: 0.0, color: 0xff5b6ee1 }, { min: 1.0, color: 0xff639bff }], 100, 100));

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

        addSprite(getText(4, 43, 'ATT:', 0xff9badb7));
        addSprite(getText(4, 57, 'DEF:', 0xff9badb7));
        addSprite(getText(4, 71, 'SPD:', 0xff9badb7));
        addSprite(getText(4, 85, 'DEX:', 0xff9badb7));

        addSprite(attNum = getText(26, 43));
        addSprite(defNum = getText(26, 57));
        addSprite(spdNum = getText(26, 71));
        addSprite(dexNum = getText(26, 85));

        addSprite(attButton = makeButton(42, 42, 'ATT'));
        addSprite(defButton = makeButton(42, 56, 'DEF'));
        addSprite(spdButton = makeButton(42, 70, 'SPD'));
        addSprite(dexButton = makeButton(42, 84, 'DEX'));
        addSprite(healthButton = new Button(
            new Vec2(4, 98),
            Assets.images.button_slice,
            new IntVec2(8, 8),
            new IntVec2(50, 14),
            0xffffffff,
            'health++',
            () -> {
                addExperience('HEALTH');
            }
        ));
    }

    override function update (delta:Float) {}

    public function forceUpdate (delta:Float) {
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
        } else {}

        if (GameData.playerData.pointsAvailable.length > 0) {
            attButton.state = Idle;
            defButton.state = Idle;
            spdButton.state = Idle;
            dexButton.state = Idle;
            healthButton.state = Idle;
        } else {
            attButton.state = Disabled;
            defButton.state = Disabled;
            spdButton.state = Disabled;
            dexButton.state = Disabled;
            healthButton.state = Disabled;
        }

        attNum.text = GameData.playerData.attack + '';
        defNum.text = GameData.playerData.defense + '';
        spdNum.text = GameData.playerData.speed + '';
        dexNum.text = GameData.playerData.dexterity + '';

        super.update(delta);
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
                // TODO: increase player health by ???
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

    function makeButton (x:Int, y:Int, stat:String):Button {
        return new Button(
            new Vec2(x, y),
            Assets.images.button_slice,
            new IntVec2(8, 8),
            new IntVec2(12, 12),
            0xffffffff,
            '+',
            () -> {
                addExperience(stat);
            }
        );
    }

    public function setupScales () {
        for (s in spells) s.stop();

        // pick 2-3 scales
        // the further level we're on, the more likely it's what we want
        // tie each button to a spell num _and_ a scale
            // or scales is separate from spells?
    }

    // public function addTestButton (onClick:() -> Void) {
    //     function clickMe () {
    //         buttonClicked = true;
    //         onClick();
    //     }
    // }

    public function activateDebugGroup () {}
    public function deactivateDebugGroup () {}
}
