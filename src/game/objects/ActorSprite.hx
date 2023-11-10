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
        var diffX = 0.0;
        var diffY = 0.0;
        if (actorState.state == Attack) {
            // TODO: consider using a shorter time to show diffs.
            // linear there-and-back tween to show attack.
            final strikeDiff = getVisDiffFromDir(actorState.currentAttack.dir);
            if (actorState.currentAttack.elapsed / actorState.currentAttack.time < .16) {
                diffX = actorState.currentAttack.elapsed / actorState.currentAttack.time / (.16) * strikeDiff.x / 2;
                diffY = actorState.currentAttack.elapsed / actorState.currentAttack.time / (.16) * strikeDiff.y / 2;
            } else if (actorState.currentAttack.elapsed / actorState.currentAttack.time < .5) {
                diffX = (1 - ((actorState.currentAttack.elapsed / actorState.currentAttack.time) - .16) / .34) * strikeDiff.x / 2;
                diffY = (1 - ((actorState.currentAttack.elapsed / actorState.currentAttack.time) - .16) / .34) * strikeDiff.y / 2;
            }
        }
        setPosition(Math.round(pos.x + diffX), Math.round(pos.y + diffY));

        if (actorState.state == PreAttack) {
            animation.play('preattack');
        } else if (actorState.state == Attack) {
            animation.play('attack');

            if (
                actorState.currentAttack.dir == East ||
                actorState.currentAttack.dir == SouthEast ||
                actorState.currentAttack.dir == South
            ) {
                flipX = true;
            }

            if (
                actorState.currentAttack.dir == North ||
                actorState.currentAttack.dir == NorthWest ||
                actorState.currentAttack.dir == West
            ) {
                flipX = false;
            }
        } else if (actorState.state == Moving) {
            animation.play('walk');
            if (flipX && prevX > x) {
                flipX = false;
            }

            if (!flipX && prevX < x) {
                flipX = true;
            }
        } else {
            animation.play('still');
        }

        prevX = x;

        super.update(delta);
    }
}
