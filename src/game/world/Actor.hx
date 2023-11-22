package game.world;

import core.Types;
import core.Util;
import game.data.ActorData;
import game.data.AttackData;
import game.data.GameData;
import game.data.ShapeData;
import game.util.Pathfinding;
import game.util.Utils;
import game.world.Element;
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
    var ?elementType:ElementType;
    var ?dir:GridDir;
    var ?vel:Vec2;
    var ?power:Float;
    var ?startPos:Vec2;
    var ?shape:Shape;
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

enum UpdateType {
    Death;
    Damage;
    Experience;
}

typedef UpdateOptions = {
    var amount:Int;
    var pos:Vec2;
}

function calcMovePosition (move:Move, percentMoved:Float):Vec2 {
    return new Vec2(
        move.from.x + (move.to.x - move.from.x) * percentMoved,
        move.from.y + (move.to.y - move.from.y) * percentMoved
    );
}

class Actor extends WorldItem {
    static final MAGIC_DISTANCE:Int = 18;

    static var curId:Int = 0;

    public var id:Int;

    var isDead:Bool = false;
    public var isHurt:Bool = false;
    public var hurtTimer:Float = 0.0;
    var hurtSlowTimer:Float = 0.0;
    public var health:Int;
    public var meleeDamage:Int;
    var speed:Int;

    var preAttackTimer:Float = 0.0;
    public var currentMove:Null<Move>;
    public var currentPath:Null<Array<IntVec2>>;
    public var currentAttack:Null<Attack>;
    public var isManaged:Bool;
    var queuedMove:Null<QueuedMove> = null;
    public var target:Null<Actor>;

    var decisionTimer:Float = 0.0;
    var decideTime:Float = 0.0; // set by manageData, final
    var retreatDist:Float = 0.0;
    var approachDist:Float = 0.0;
    var attackDist:Float = 0.0;
    var chosenAttack:AttackName;

    var world:World;
    public var actorType:ActorType;
    public var state:ActorState = Wait;

    // to send updates to a listener.
    public var updateListeners:Array<(updateType:UpdateType, ?updateOptions:UpdateOptions) -> Void> = [];

    public function new (x:Int, y:Int, world:World, type:ActorType) {
        super(x, y);

        id = getId();

        if (type == PlayerActor) {
            final data = GameData.playerData;
            health = data.maxHealth;
            speed = data.speed;
        } else {
            final data = actorData[type];
            health = data.health;
            meleeDamage = data.meleeDamage;
            speed = data.speed;
            retreatDist = data.manageData.retreatDist;
            attackDist = data.manageData.attackDist;
            approachDist = data.manageData.approachDist;
            decideTime = data.manageData.decideTime;
            chosenAttack = data.manageData.attack;
        }

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

            if (currentMove == null) {
                world.onFinishedStep(this);
                // do the next move if a step is available and not waiting for a queued move
                if (queuedMove == null) {
                    startNextMove();
                }
            }
        } else if (state == PreAttack) {
            preAttackTimer -= delta;
            if (preAttackTimer < 0.0) {
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

    public function manage (delta:Float) {
        if (target != null && target.isDead) {
            target = null;
        }

        if (target != null) {
            decisionTimer -= delta;

            final myPosition = getNearestPosition();
            final targetPosition = target.getNearestPosition();
            final distance = distanceBetween(myPosition.toVec2(), targetPosition.toVec2());

            // if it's time to decide or we're very close
            if (decisionTimer < 0.0 || (decisionTimer < decideTime * .5 && distance < Math.sqrt(2))) {
                decide(myPosition, targetPosition, distance);
            }
        }
    }

    function decide (myPos:IntVec2, targetPos:IntVec2, distance:Float) {
        // try to retreat. If cant, attack.
        var retreatDone = false;
        if (distance <= retreatDist) {
            trace('retreat!');
            // get a group of tiles away from the target.
            var diffX = targetPos.x - myPos.x;
            var diffY = targetPos.y - myPos.y;

            if (diffX > 0) diffX = -1;
            if (diffX < 0) diffX = 1;
            if (diffY > 0) diffY = -1;
            if (diffY < 0) diffY = 1;

            final posX = myPos.x - 4 + (diffX * 5);
            final posY = myPos.y - 4 + (diffY * 5);

            final items = [];
            for (x in posX...(posX + 9)) { // width
                for (y in posY...(posY + 9)) { // height
                    final gridItem = getGridItem(world.grid, x, y);
                    if (gridItem != null && gridItem.tile != null) {
                        items.push(new Vec2(x, y));
                    }
                }
            }

            // find the furthest item.
            final t = targetPos.toVec2();
            items.sort((pos1:Vec2, pos2:Vec2) -> {
                return Std.int(Math.abs(distanceBetween(t, pos2)) - Math.abs(distanceBetween(t, pos1)));
            });

            if (items.length > 0) {
                queueMove(new IntVec2(Std.int(items[0].x), Std.int(items[0].y)));
                retreatDone = true;
            }
        }

        if (distance <= attackDist && !retreatDone) {
            final att = attackData[chosenAttack];
            if (att.type == Melee) {
                final diffX = targetPos.x - myPos.x;
                final diffY = targetPos.y - myPos.y;
                final dir = getDirFromDiff(diffX, diffY);
                if (dir != null) {
                    queueAttack(attackData[chosenAttack], dir, targetPos);
                } else {
                    trace('missed', distance, diffX, diffY);
                }
            } else {
                queueAttack(att, null, targetPos.clone());
            }
        } else if (distance < approachDist && !retreatDone) {
            queueMove(targetPos.clone());
        }

        decisionTimer = Math.random() * decideTime + decideTime;
    }

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
                // TODO: do something about this, maybe retrying the move
                trace('actor in the way!!');
                currentPath.unshift(nextPos);
                endMove();
            } else {
                var s = speed;
                if (actorType == PlayerActor) {
                    s = GameData.playerData.speed;
                }

                final curPos = getPosition();
                var speedVal = 10 / s;

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
        target = fromActor;
        if (!isHurt) {
            hurt(fromActor.meleeDamage, fromActor);
        }
    }

    public function doElementDamage (fromElement:Element) {
        // TODO: set target to nearest depending on intelligence.
        if (fromElement.fromActor != null && fromElement.fromActor != this) {
            target = fromElement.fromActor;
        }

        var damage = fromElement.time * damageLookup(fromElement.type);
        for (r in actorData[actorType].resistances) {
            if (r.type == fromElement.type) {
                damage *= r.amount;
            }
        }

        if (!isHurt) {
            hurt(Math.ceil(damage), fromElement.fromActor);
        }
    }

    function tryAttack (attack:AttackData, ?dir:GridDir, pos:IntVec2) {
        var vel:Vec2 = new Vec2(0, 0);
        var startPos:Vec2 = new Vec2(x, y);
        if (attack.type == Range) {
            final angle = angleFromPoints(pos.toVec2(), getPosition().toVec2());
            vel = velocityFromAngle(angle, attack.vel);
            // start the element x tiles away so it doesn't touch actor.
            final startDiff = velocityFromAngle(angle, 1.25);
            startPos = new Vec2(x + startDiff.x, y + startDiff.y);
        } else if (attack.type == Magic) {
            final path = pathfind(makeIntGrid(world.grid), getPosition(), pos.clone(), Diagonal, true, MAGIC_DISTANCE);
            if (path == null) {
                // TODO: use raycast to handle this.
                trace('too far');
                state = Wait;
                return;
            }
            startPos = pos.clone().toVec2();
        }

        var attackTime = attack.time;
        if (actorType == PlayerActor) {
            attackTime = getDiminishedValue(GameData.playerData.dexterity, attack.time);
        }

        var preAttackTime = attack.preTime;
        if (actorType == PlayerActor) {
            preAttackTime = getDiminishedValue(GameData.playerData.dexterity, attack.preTime);
        }

        var attackPower = attack.power;
        if (actorType == PlayerActor) {
            attackPower = attackPower != null ? getIncreasedValue(GameData.playerData.attack, attackPower) : null;
        }

        // TODO: increase melee attack power

        currentAttack = {
            time: attackTime,
            elapsed: 0,
            type: attack.type,
            dir: attack.type == Melee ? dir : null,
            vel: attack.type == Range ? vel : null,
            elementType: attack.type == Range || attack.type == Magic ? attack.element : null,
            power: attackPower,
            shape: attack.type == Magic ? attack.shape : null,
            startPos: attack.type == Range || attack.type == Magic ? startPos : null
        }

        state = PreAttack;
        preAttackTimer = preAttackTime;
    }

    function attack () {
        state = Attack;
        // trace('attack', currentAttack);

        if (currentAttack.type == Melee) {
            // TODO: consider storing position on currentAttack
            final diff = getDiffFromDir(currentAttack.dir);
            final pos = getPosition();
            world.meleeAttack(pos.x + diff.x, pos.y + diff.y, this);
        } else if (currentAttack.type == Range) {
            world.addElement(currentAttack.startPos.x, currentAttack.startPos.y, currentAttack.elementType, currentAttack.vel, currentAttack.power, this);
        } else if (currentAttack.type == Magic) {
            final shapeSize = Math.floor(currentAttack.shape.length / 2);
            twoDMap(currentAttack.shape, (item:Null<ShapeData>, x:Int, y:Int) -> {
                final xPos = Std.int(currentAttack.startPos.x - shapeSize + x);
                final yPos = Std.int(currentAttack.startPos.y - shapeSize + y);

                final gridItem = getGridItem(world.grid, xPos, yPos);

                if (item != null && gridItem != null && gridItem.tile != null) {
                    world.addElement(
                        xPos,
                        yPos,
                        currentAttack.elementType,
                        item.vel,
                        currentAttack.power,
                        this,
                        item.time
                    );
                }
            });
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

    function hurt (d:Int, fromActor:Null<Actor>) {
        var damage = d;
        if (actorType == PlayerActor) {
            final pre = damage;
            damage = Math.ceil(getDiminishedValue(GameData.playerData.defense, damage));
            // damage = Math.ceil((2 - (GameData.playerData.defense / 50)) * damage);
            trace(damage, pre);
        }

        if (damage >= 1) {
            health -= damage;
            if (health <= 0) {
                health = 0;

                if (fromActor != null) {
                    fromActor.gainExperience(this);
                }

                die();
            }

            for (onUpdate in updateListeners) onUpdate(Damage, { amount: damage, pos: new Vec2(x, y) });

            isHurt = true;
            hurtTimer = 1.0;
            hurtSlowTimer = hurtTimer / 2;
        } else {
            trace('no damage');
        }
    }

    function stopHurt () {
        isHurt = false;
    }

    function die () {
        isDead = true;
        world.removeActor(this);
        for (onUpdate in updateListeners) onUpdate(Death);
    }


    function gainExperience (actor:Actor) {
        final amount = actorData[actor.actorType].experience;

        for (onUpdate in updateListeners) {
            onUpdate(Experience, { amount: amount, pos: new Vec2(x, y) });
        }

        if (actorType == PlayerActor) {
            GameData.addExperience(amount);
        }
    }

    public function getLinkedPosition ():IntVec2 {
        if (currentMove != null) {
            return currentMove.to;
        }

        return getPosition();
    }

    function getDiminishedValue (alterStat:Int, value:Float) {
        trace('dim', alterStat, value);
        if (alterStat <= 50) {
            trace((2 - (alterStat / 50)) * value);
            return (2 - (alterStat / 50)) * value;
        }

        trace(value * 0.5 + value * ((100 - alterStat) / 100));
        return value * 0.5 + value * ((100 - alterStat) / 100);
    }

    function getIncreasedValue (alterStat:Int, value:Float) {
        trace('inc', alterStat, value);
        if (alterStat <= 50) {
            trace(value * (alterStat / 50));
            return value * (alterStat / 50);
        }

        trace(value + value * 0.5 * ((alterStat - 50) / 50));
        return value + value * 0.5 * ((alterStat - 50) / 50);
    }

    static function getId ():Int {
        return curId++;
    }
}
