package game.objects;

import core.Types;
import game.util.Utils;
import game.world.Actor;
import kha.Assets;

class ActorSprite extends WorldItemSprite {
    var actorState:Actor;

    var prevX:Float;

    public function new (actor:Actor) {
        final pos = translateWorldPos(actor.x, actor.y);
        super(new Vec2(pos.x, pos.y), Assets.images.wizard_2, new IntVec2(16, 32), 0xff5b6ee1);
        this.actorState = actor;

        animation.add('still', [0]);
        animation.add('walk', [0, 1], 0.2);
    }

    override function update (delta:Float) {
        final pos = translateWorldPos(actorState.x, actorState.y);
        setPosition(Math.round(pos.x), Math.round(pos.y));

        if (actorState.state == Moving) {
            animation.play('walk');
        } else {
            animation.play('still');
        }

        if (flipX && prevX > x) {
            flipX = false;
        }

        if (!flipX && prevX < x) {
            flipX = true;
        }

        prevX = x;

        super.update(delta);
    }
}
