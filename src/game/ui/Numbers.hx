package game.ui;

import core.Camera;
import core.Sprite;
import core.Types;
import game.ui.UiText;
import kha.Assets;
import kha.graphics2.Graphics;

class Numbers extends Sprite {
    static inline final NUMBER_TIME:Float = 2.0;
    var numTimer:Float;

    public function new () {
        super(new Vec2(-16, -16), Assets.images.cards_text_outline);
        physicsEnabled = true;
        makeBitmapText('', getSmallFont());
        stop();
    }

    override function update (delta:Float) {
        super.update(delta);
        numTimer -= delta;
        if (numTimer <= 0) {
            stop();
        }
    }

    override function start () {
        // round position
        body.velocity.set(0, -15);
        alpha = 1.0;
        numTimer = NUMBER_TIME;
        super.start();
    }

    override function render (g2:Graphics, cam:Camera) {
        alpha = Math.ceil(numTimer / NUMBER_TIME * 4) / 4;
        super.render(g2, cam);
    }
}
