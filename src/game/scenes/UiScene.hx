package game.scenes;

import core.Scene;
import core.Sprite;
import game.ui.UiText;

class UiScene extends Scene {
    public var exText:Sprite;

    public var buttonClicked:Bool = false;

    override function create () {
        addSprite(exText = getText(4, 4, 'ExAmPlE text'));
    }

    override function update (delta:Float) {}

    public function forceUpdate (delta:Float) {
        buttonClicked = false;
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