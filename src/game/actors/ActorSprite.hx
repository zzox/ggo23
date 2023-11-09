package game.actors;

import core.Camera;
import core.Sprite;
import core.Types;
import game.util.Utils;
import game.world.Actor;
import kha.Assets;
import kha.graphics2.Graphics;

class ActorSprite extends Sprite {
    var actorState:Actor;

    var yOffset:Int = 16;

    public function new (actor:Actor) {
        final pos = translateWorldPos(actor.x, actor.y);
        super(new Vec2(pos.x, pos.y), Assets.images.wizard_2, new IntVec2(16, 32));
        this.actorState = actor;

        animation.add('still', [0]);
        animation.add('walk', [0, 1], 0.2);

        color = 0xff5b6ee1;
    }

    override function update (delta:Float) {
        final pos = translateWorldPos(actorState.x, actorState.y);
        setPosition(Math.round(pos.x), Math.round(pos.y));

        if (actorState.moving) {
            animation.play('walk');
        } else {
            animation.play('still');
        }

        super.update(delta);
    }

    override function render (g2:Graphics, cam:Camera) {
        // is this needed?
        // final px = x;
        // final py = y;

        // setPosition(Math.round(x), Math.round(y));
        // super.render(g2, cam);
        // setPosition(px, py);

        // for (c in _children) {
        //     c.setPosition(x, y - yOffset);
        // }

        final oldY = y;
        y -= yOffset;
        super.render(g2, cam);
        y = oldY;
    }
}
