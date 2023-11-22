package game.objects;

import core.Types;
import game.data.ActorData;
import game.util.Utils;
import game.world.Actor;
import kha.Assets;

class ActorSprite extends WorldItemSprite {
    public var actorState:Null<Actor>;

    var prevX:Float;
    var prevHurt:Bool;

    public function new (actor:Actor) {
        final data = actorData[actor.actorType];
        final pos = translateWorldPos(actor.x, actor.y);
        super(new Vec2(pos.x, pos.y), Assets.images.actors, new IntVec2(16, 32), data.color);
        this.actorState = actor;

        actor.updateListeners.push(onActorStateUpdate);

        animation.add('still', [data.animIndex]);
        animation.add('walk', [data.animIndex, data.animIndex + 1], 0.2);
        animation.add('preattack', [data.animIndex + 2]);
        animation.add('attack', [data.animIndex + 3]);
        animation.add('die', [data.animIndex + 4, data.animIndex + 5], actor.actorType == PlayerActor ? 2.0 : 0.5, false);
        animation.onComplete = (anim:String) -> {
            if (anim == 'die' && actor.actorType != PlayerActor) {
                visible = false;
            }
        }
    }

    override function update (delta:Float) {
        if (actorState != null) {
            final pos = translateWorldPos(actorState.x, actorState.y);
            var diffX = 0.0;
            var diffY = 0.0;
            if (actorState.state == Attack && actorState.currentAttack.type == Melee) {
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
            // setPosition(pos.x + diffX, pos.y + diffY);
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

            if (prevHurt && !isHurt) {
                // TODO: use from signals
                hurt(actorState.hurtTimer);
            }

            if (!prevHurt && isHurt) {
                stopHurt();
            }

            prevX = x;
            prevHurt = actorState.isHurt;
        }

        super.update(delta);
    }

    function onActorStateUpdate (updateType:UpdateType, ?options:UpdateOptions) {
        if (updateType == Death) {
            if (actorState.actorType != PlayerActor) {
                alpha = 0.5;
            }
            actorState = null;
            animation.play('die');
        }
    }
}
