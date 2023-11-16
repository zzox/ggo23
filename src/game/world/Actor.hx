package game.world;

import core.Types;
import core.Util;
import game.data.ActorData;
import game.data.AttackData;
import game.util.Pathfinding;
import game.util.Utils;
import game.world.Grid;
import game.world.World;

enum ActorState {
    Wait;
    Moving;
    PreAttack;
    Attack;
}

typedef Move = {
    var from:IntVec2;
    var to:IntVec2;
    var elapsed:Float;
    var time:Float;
}

typedef Attack = {
    var time:Float;
    var elapsed:Float;
    var type:AttackType;
    var ?dir:GridDir;
    var ?vel:Vec2;
    var ?startPos:Vec2;
}

enum QueuedMoveType {
    QMove;
    QAttack;
}

typedef QueuedMove = {
    var moveType:QueuedMoveType;
    var ?pos:IntVec2;
    var ?attack:AttackData;
    var ?dir:GridDir;
}

function calcMovePosition (move:Move, percentMoved:Float):Vec2 {
    return new Vec2(
        move.from.x + (move.to.x - move.from.x) * percentMoved,
        move.from.y + (move.to.y - move.from.y) * percentMoved
    );
}

class Actor extends WorldItem {
    static var curId:Int = 0;

    public var id:Int;

    public var isHurt:Bool = false;
    var hurtTimer:Float = 0.0;
    var hurtSlowTimer:Float = 0.0;
    public var health:Int;
    public var meleeDamage:Int;
    var speed:Int;

    var preAttackTime:Float = 0.0;
    var attackTime:Float = 0.0;
    var currentMove:Null<Move>;
    var currentPath:Null<Array<IntVec2>>;
    public var currentAttack:Null<Attack>;
    public var isManaged:Bool;
    var queuedMove:Null<QueuedMove> = null;

    var world:World;
    public var actorType:ActorType;
    public var state:ActorState = Wait;

    // to send updates to a listener.
    // public var onUpdate:(str:String) -> Void;

    public function new (x:Int, y:Int, world:World, type:ActorType) {
        super(x, y);

        id = getId();

        final data = actorData[type];

        health = data.health;
        meleeDamage = data.meleeDamage;
        speed = data.speed;

        this.world = world;
        this.actorType = type;
        isManaged = type != PlayerActor;
    }

    public function update (delta:Float) {
        if (isHurt) {
            hurtTimer -= delta;
            if (hurtTimer < 0.0) {
                stopHurt();
            }
        }

        if (state == Moving) {
            handleCurrentMove(delta);

            // do the next move if a step is available and not waiting for a queued move
            if (currentMove == null && queuedMove == null) {
                startNextMove();
            }
        } else if (state == PreAttack) {
            preAttackTime -= delta;
            if (preAttackTime < 0.0) {
                attack();
            }
        } else if (state == Attack) {
            currentAttack.elapsed += delta;
            if (currentAttack.elapsed > currentAttack.time) {
                finishAttack();
            }
        }

        // do the queued move if actor is waiting or just finishing a step in a path.
        if (queuedMove != null && (state == Wait || (state == Moving && currentMove == null))) {
            switch (queuedMove.moveType) {
                case QMove:
                    move(queuedMove.pos.x, queuedMove.pos.y);
                case QAttack:
                    tryAttack(queuedMove.attack, queuedMove.dir, queuedMove.pos);
            }
            queuedMove = null;
        }
    }

    public function manage () {
        if (state == Wait) {
            final myPosition = getPosition();
            // TODO: eventual `targetPosition`
            final playerPosition = world.playerActor.getNearestPosition();
            final distance = distanceBetween(myPosition.toVec2(), playerPosition.toVec2());

            // attack distance
            if (distance <= Math.sqrt(2)) {
                // attack
                final diffX = playerPosition.x - myPosition.x;
                final diffY = playerPosition.y - myPosition.y;
                final dir = getDirFromDiff(diffX, diffY);
                if (dir != null) {
                    queueAttack({ preTime: 0.5, time: 0.5, type: Melee }, dir);
                } else {
                    trace('missed', distance, diffX, diffY);
                }
            // approach distance
            } else if (distance < 10.0) {
                final nearestPos = world.playerActor.getNearestPosition();
                move(nearestPos.x, nearestPos.y);
            }
        }
    }

    function decide () {}

    public function queueMove (pos:IntVec2) {
        queuedMove = {
            moveType: QMove,
            pos: pos
        }
    }

    // annoying to try queueing an attack before trying to do it, but we are stopped
    // by the grid since we can be in between a step.
    // TODO: add a queue buffer time?
    public function queueAttack (attack:AttackData, ?dir:GridDir, ?pos:IntVec2) {
        queuedMove = {
            moveType: QAttack,
            attack: attack,
            dir: dir,
            pos: pos
        }
    }

    function handleCurrentMove (delta:Float) {
        currentMove.elapsed += delta;

        // percent is 0 to 1
        final percentMoved = currentMove.elapsed / currentMove.time;
        if (percentMoved > 1.0) {
            x = currentMove.to.x;
            y = currentMove.to.y;
            currentMove = null;
        } else {
            final position = calcMovePosition(currentMove, percentMoved);
            x = position.x;
            y = position.y;
        }
    }

    function startNextMove () {
        final nextPos = currentPath.shift();
        if (nextPos == null) {
            endMove();
        } else {
            final nextItem = getGridItem(world.grid, nextPos.x, nextPos.y);
            if (nextItem.actor != null) {
                // TODO: do something about this.
                trace('actor in the way!!');
                currentPath.unshift(nextPos);
                endMove();
            } else {
                final curPos = getPosition();
                var speedVal = 10 / speed;

                // slow down at the beginning of being hurt
                if (isHurt && hurtTimer > hurtSlowTimer) {
                    speedVal * 2;
                }

                currentMove = {
                    to: nextPos.clone(),
                    from: curPos,
                    time: isDiagonal(nextPos, curPos) ? speedVal * Math.sqrt(2) : speedVal,
                    elapsed: 0.0
                }

                // ATTN: dicey switching here. Should this be handled by the parent `World` class?
                final curItem = getGridItem(world.grid, curPos.x, curPos.y);
                curItem.actor = null;
                nextItem.actor = this;
            }
        }
    }

    public function doMeleeDamage (fromActor:Actor) {
        // TODO: set target depending on intelligence?
        trace('took damage!', fromActor.actorType);
        if (!isHurt) {
            hurt(fromActor.meleeDamage);
        }
    }

    public function doElementDamage (fromElement:Element) {
        trace('took element damage!', fromElement);
        if (!isHurt) {
            hurt(10);
        }
    }

    function tryAttack (attack:AttackData, ?dir:GridDir, pos:IntVec2) {
        // TODO: bring data in from config
        var vel:Vec2 = new Vec2(0, 0);
        var startPos:Vec2 = new Vec2(x, y);
        if (attack.type == Range) {
            final angle = angleFromPoints(pos.toVec2(), getPosition().toVec2());
            vel = velocityFromAngle(angle, attack.vel);
            // start the element x tiles away so it doesn't touch actor.
            final startDiff = velocityFromAngle(angle, 1.0);
            startPos = new Vec2(x + startDiff.x, y + startDiff.y);
        }

        currentAttack = {
            time: attack.time,
            elapsed: 0,
            type: attack.type,
            dir: attack.type == Melee ? dir : null,
            vel: attack.type == Range ? vel : null,
            startPos: attack.type == Range ? startPos : null
        }

        state = PreAttack;
        preAttackTime = attack.preTime;
    }

    function attack () {
        state = Attack;
        trace('attack', currentAttack);

        if (currentAttack.type == Melee) {
            // TODO: consider storing position on currentAttack
            final diff = getDiffFromDir(currentAttack.dir);
            final pos = getPosition();
            world.meleeAttack(pos.x + diff.x, pos.y + diff.y, this);
        } else if (currentAttack.type == Range) {
            world.addElement(currentAttack.startPos.x, currentAttack.startPos.y, Fire, currentAttack.vel);
        }
    }

    function finishAttack () {
        state = Wait;
        currentAttack = null;
    }

    public function move (toX:Int, toY:Int) {
        currentPath = pathfind(makeIntGrid(world.grid), getPosition(), new IntVec2(toX, toY), Diagonal, true, 24);

        if (currentPath == null) {
            // throw 'Could not find path.';
            trace('Could not find path.');
            state = Wait;
        } else {
            state = Moving;
            startNextMove();
        }
    }

    function endMove () {
        currentPath = null;
        state = Wait;
    }

    function hurt (damage:Int) {
        health -= damage;
        if (damage <= 0) {
            // die();
        }
        isHurt = true;
        hurtTimer = 1.0;
        hurtSlowTimer = hurtTimer / 2;
    }

    function stopHurt () {
        isHurt = false;
    }

    static function getId ():Int {
        return curId++;
    }
}
