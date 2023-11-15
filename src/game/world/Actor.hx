package game.world;

import core.Types;
import core.Util;
import game.data.ActorData;
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

// TODO: attack type, spell or strike
typedef Attack = {
    var dir:GridDir;
    var time:Float;
    var elapsed:Float;
}

enum QueuedMoveType {
    QAttack;
    QMove;
}

typedef QueuedMove = {
    var moveType:QueuedMoveType;
    var pos:IntVec2;
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
    public var hurtTimer:Float = 0.0;
    public var health:Int;
    public var meleeDamage:Int;
    var speed:Float;

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

        if (queuedMove != null && currentMove == null) {
            switch (queuedMove.moveType) {
                case QMove:
                    move(queuedMove.pos.x, queuedMove.pos.y);
                case QAttack:
                    tryAttack(South);
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
                    tryAttack(dir);
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

    function decide () {

    }

    public function queueMove (type:QueuedMoveType, pos:IntVec2) {
        queuedMove = {
            moveType: type,
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
                currentMove = {
                    to: nextPos.clone(),
                    from: curPos,
                    time: isDiagonal(nextPos, curPos) ? speed * Math.sqrt(2) : speed,
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

    public function tryAttack (dir:GridDir) {
        // TODO: bring in from config
        currentAttack = {
            dir: dir,
            time: actorData[actorType].attackTime,
            elapsed: 0
        }

        state = PreAttack;
        preAttackTime = actorData[actorType].preAttackTime;
    }

    function attack () {
        state = Attack;
        trace('attack');

        final diff = getDiffFromDir(currentAttack.dir);
        final pos = getPosition();

        world.meleeAttack(pos.x + diff.x, pos.y + diff.y, this);
    }

    function finishAttack () {
        state = Wait;
        currentAttack = null;
    }

    public function move (toX:Int, toY:Int) {
        currentPath = pathfind(makeIntGrid(world.grid), getPosition(), new IntVec2(toX, toY), Diagonal, true);

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
    }

    function stopHurt () {
        isHurt = false;
    }

    static function getId ():Int {
        return curId++;
    }
}
