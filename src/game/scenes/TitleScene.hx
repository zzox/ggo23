package game.scenes;

import core.Scene;
import core.Types;
import game.data.GameData;
import game.data.MusicData;
import game.ui.Button;
import game.ui.UiText;
import kha.Assets;

class TitleScene extends Scene {
    override function create () {
        camera.scale.set(2, 2);
        camera.bgColor = 0xff222034;
        addSprite(getText(142, 32, 'depths'));

        addSprite(new Button(
            new Vec2(124, 100),
            Assets.images.button_slice,
            new IntVec2(8, 8),
            new IntVec2(72, 16),
            0xffffffff,
            'Start Game',
            startGame
        ));
    }

    function startGame () {
        new GameData();
        new MusicData();
        game.switchScene(new WorldScene());
    }
}
