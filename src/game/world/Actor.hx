package game.world;

import core.Types;
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

function calcMovePosition (move:Move, percentMoved:Float):Vec2 {
    return new Vec2(
        move.from.x + (move.to.x - move.from.x) * percentMoved,
        move.from.y + (move.to.y - move.from.y) * percentMoved
    );
}

class Actor {
    static var curId:Int = 0;

    public var id:Int;
    public var x:Float;
    public var y:Float;

    var world:World;

    var preAttackTime:Float = 0.0;
    var attackTime:Float = 0.0;
    var currentMove:Null<Move>;
    var currentPath:Null<Array<IntVec2>>;
    public var currentAttack:Null<Attack>;

    public var actorType:ActorType;
    public var state:ActorState = Wait;

    // TEMP: this needs to be a diff value that we take the inverse of.
    var speed:Float = 0.166;

    public function new (x:Int, y:Int, world:World, type:ActorType) {
        this.x = x;
        this.y = y;

        id = getId();

        this.world = world;
        this.actorType = type;
    }

    public function update (delta:Float) {
        if (state == Moving) {
            handleCurrentMove(delta);

            if (currentMove == null) {
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

        // TODO: only hit people within ~.75 units distance away
        final gridItem = getGridItem(world.grid, pos.x + diff.x, pos.y + diff.y);
        if (gridItem != null && gridItem.actor != null) {
            gridItem.actor.damage(10);
        }
    }

    function damage (amount:Int) {
        // TODO: set target depending on intelligence?
        trace('took damage!', amount);
    }

    function finishAttack () {
        state = Wait;
        currentAttack = null;
    }

    public function move (toX:Int, toY:Int) {
        state = Moving;

        currentPath = pathfind(makeIntGrid(world.grid), getPosition(), new IntVec2(toX, toY), Diagonal, true);

        if (currentPath == null) {
            throw 'Could not find path.';
        } else {
            startNextMove();
        }
    }

    function endMove () {
        currentPath = null;
        state = Wait;
    }

    public function getPosition ():IntVec2 {
        if (x % 1.0 != 0.0 || y % 1.0 != 0.0) {
            throw 'Not integer, position off.';
        }

        return new IntVec2(Std.int(x), Std.int(y));
    }

    static function getId ():Int {
        return curId++;
    }
}
