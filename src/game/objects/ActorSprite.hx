package game.objects;

import core.Types;
import game.data.ActorData;
import game.util.Utils;
import game.world.Actor;
import kha.Assets;

class ActorSprite extends WorldItemSprite {
    var actorState:Actor;

    var prevX:Float;

    public function new (actor:Actor) {
        final data = actorData[actor.actorType];
        final pos = translateWorldPos(actor.x, actor.y);
        super(new Vec2(pos.x, pos.y), Assets.images.actors, new IntVec2(16, 32), data.color);
        this.actorState = actor;

        animation.add('still', [data.moveAnims[0]]);
        animation.add('walk', data.moveAnims.copy(), 0.2);
        animation.add('preattack', [data.preAttackAnim]);
        animation.add('attack', [data.attackAnim]);
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
