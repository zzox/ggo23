package game.scenes;

import core.Scene;
import core.Sprite;
import core.Types;
import game.ui.Bar;
import kha.Assets;

class UiScene extends Scene {
    public var exText:Sprite;

    public var healthBar:Bar;
    public var healthNum:Int;
    public var healthMax:Int;
    public var recoveryBar:Bar;
    public var recoveryNum:Int;
    public var experienceBar:Sprite;
    public var experienceNum:Int;

    public var buttonClicked:Bool = false;

    override function create () {
        camera.scale.set(2, 2);
        addSprite(new Sprite(new Vec2(2, 2), Assets.images.portraits));

        addSprite(healthBar = new Bar(40, 2, 100, 8, [{ min: 0.0, color: 0xffd95763 }, { min: 0.2, color: 0xff37946e }], 100, 100));
        addSprite(recoveryBar = new Bar(40, 16, 50, 2, [{ min: 0.0, color: 0xff5b6ee1 }, { min: 1.0, color: 0xff639bff }], 100, 100));
    }

    override function update (delta:Float) {}

    public function forceUpdate (delta:Float) {
        buttonClicked = false;
        healthBar.value = healthNum;
        recoveryBar.value = recoveryNum;

        super.update(delta);
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
