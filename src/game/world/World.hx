package game.world;

import core.Types;
import game.data.ActorData;
import game.data.FloorData;
import game.data.GameData;
import game.data.RoomData;
import game.util.ShuffleRandom;
import game.util.Utils;
import game.world.Element;
import game.world.Grid;

enum TileType {
    Tile;
}

enum SignalType {
    PlayerPortal;
    PlayerStep;
    PlayerDead;
    BossDead;
    SteamParticle;
    WindDeflect;
}

typedef SignalOptions = {
    var ?tiles:Array<GridItem>;
    var ?pos:Vec2;
}

class Object {}

typedef ElementAdd = (e:Element) -> Void;
typedef Signal = (signal:SignalType, ?o:SignalOptions) -> Void;

class World {
    public static inline final HIT_DISTANCE:Float = 0.75;
    static inline final ELEMENT_WALL_VANQUISH:Float = 0.9;
    static inline final ELEMENT_SLOWDOWN:Float = 0.75;

    public var grid:Grid;
    public var size:IntVec2;
    public var actors:Array<Actor> = [];
    public var objects:Array<Object> = [];
    public var elements:Array<Element> = [];
    public var portalPos:IntVec2;
    var step:Int = 0; // used for debugging
    public var isBossLevel:Bool;
    public var isBossDead:Bool = false;

    public var playerActor:Actor;
    var prevActorLevel:Int;

    var onSignal:Signal;
    var onAddElement:ElementAdd;
    var onRemoveElement:ElementAdd;

    public var isPaused:Bool = false;

    public function new (onSignal:Signal, onAddElement:ElementAdd, onRemoveElement:ElementAdd) {
        // TODO: bring in from singleton.
        final floorNum = GameData.floorNum;
        final data = floorData[floorNum];
        final generatedWorld = generate(floorNum, GameData.random);
        isBossLevel = data.isBoss;
        grid = generatedWorld.grid;

        portalPos = generatedWorld.portal;
        // final item = getGridItem(grid, generatedWorld.portal.x, generatedWorld.portal.y);

        playerActor = new Actor(generatedWorld.playerPos.x, generatedWorld.playerPos.y, this, PlayerActor);
        addActor(playerActor);
        playerActor.seen = true;

        final randomEnemy = new ShuffleRandom(data.enemies, GameData.random);
        for (enemySpawner in generatedWorld.spawners) {
            final enemy = new Actor(enemySpawner.x, enemySpawner.y, this, randomEnemy.getNext());
            addActor(enemy);
            if (enemy.attitude != Nonchalant) {
                enemy.target = playerActor;
            }
            enemy.seen = isBossLevel;
        }

        this.size = data.size;

        this.onAddElement = onAddElement;
        this.onRemoveElement = onRemoveElement;
        this.onSignal = onSignal;

        // force the first set of tiles to be seen.
        seeTiles(Std.int(playerActor.x), Std.int(playerActor.y), true);

        prevActorLevel = GameData.playerData.level;
    }

    public function update (delta:Float) {
        if (isPaused) return;

        step++;

        var elementMap:Map<Int, Int> = [];
        for (element in elements) {
            element.update(delta);

            for (actor in actors) {
                if (
                    !actor.isHurt &&
                    element.active &&
                    Math.abs(element.x - actor.x) < HIT_DISTANCE &&
                    Math.abs(element.y - actor.y) < HIT_DISTANCE
                ) {
                    final didDamage = actor.doElementDamage(element);
                    if (didDamage) {
                        element.velocity.x *= ELEMENT_SLOWDOWN;
                        element.velocity.y *= ELEMENT_SLOWDOWN;
                    }
                }
            }

            final nearPos = element.getNearestPosition();
            final gi = getGridItem(grid, nearPos.x, nearPos.y);
            if (gi == null || gi.tile == null) {
                // collides with walls (kinda janky)
                // TODO: reenable when canSeeTarget is implemented,
                // can also test to see adjacent tiles to get wall direction
                // if (element.type == Air) {
                //     if (xCollides(element.x, element.y, gi.x, gi.y)) {
                //         element.velocity.set(-element.velocity.x, element.velocity.x);
                //         separateElementGridItem(element, gi, true);
                //     } else {
                //         element.velocity.set(element.velocity.x, -element.velocity.y);
                //         separateElementGridItem(element, gi, false);
                //     }
                // } else {
                // freeze velocity and diminish time remaining.
                element.time *= ELEMENT_WALL_VANQUISH;
                element.velocity.set(0, 0);
                // }
            }

            for (otherElement in elements) {
                if (
                    otherElement != element &&
                    element.active &&
                    otherElement.active &&
                    Math.abs(otherElement.x - element.x) < HIT_DISTANCE &&
                    Math.abs(otherElement.y - element.y) < HIT_DISTANCE &&
                    elementMap.get(element.id) != otherElement.id
                ) {
                    if (element.type == Air && otherElement.type == Air) continue;

                    handleElementInteraction(otherElement, element);
                    elementMap.set(otherElement.id, element.id);
                }
            }
        }

        for (element in elements) {
            if (!element.active && !element.preActive) {
                removeElement(element);
            }
        }

        for (actor in actors) {
            if (actor.isManaged) {
                actor.manage(delta);
            }
            actor.update(delta);
        }

        if (prevActorLevel != GameData.playerData.level) {
            final pos = playerActor.getLinkedPosition();
            seeTiles(pos.x, pos.y, false);
        }

        prevActorLevel = GameData.playerData.level;
    }

    public function onFinishedStep (actor:Actor) {
        if (actor == playerActor) {
            if (actor.x == portalPos.x && actor.y == portalPos.y && (!isBossLevel || isBossDead)) {
                isPaused = true;
                onSignal(PlayerPortal);
            }

            seeTiles(Std.int(actor.x), Std.int(actor.y), false);
        }
    }

    function seeTiles (x:Int, y:Int, force:Bool) {
        var tiles = [];

        var index = GameData.playerData.level - 1;
        if (index >= seeDiffs.length) {
            index = seeDiffs.length - 1;
        }

        final diffArray = seeDiffs[index];

        for (diff in diffArray) {
            final gi = getGridItem(grid, x + diff.x, y + diff.y);
            if (gi != null && gi.tile != null && !gi.seen) {
                // if any of the 4 adjacted tiles are seen, we can see them.
                final adjacentItems = get4AdjacentItems(grid, x + diff.x, y + diff.y);
                final res = Lambda.fold(adjacentItems, (item:GridItem, res:Bool) -> {
                    if (res || item.seen) {
                        return true;
                    }
                    return false;
                }, false);

                if (force || res) {
                    gi.seen = true;
                    if (gi.actor != null) {
                        gi.actor.seen = true;
                    }
                    tiles.push(gi);
                }
            }
        }
        onSignal(PlayerStep, { tiles: tiles });
    }

    function handleElementInteraction (elem1:Element, elem2:Element) {
        if (elem1.type == Lightning || elem2.type == Lightning) {
            // lightning never moves, but can be here if two ppl cast to the same spot
            if (elem1.type == Lightning && elem2.type == Lightning) {}

            return;
        }

        if (elem1.type == Air && elem2.type == Air) {
            return;
        } else if (elem1.type == Air || elem2.type == Air) {
            var isAir:Element;
            var isNonAir:Element;

            if (elem1.type == Air) {
                isAir = elem1;
                isNonAir = elem2;
            } else {
                isAir = elem2;
                isNonAir = elem1;
            }

            // final isAirWeight = isAir.time / isNonAir.time + isAir.time;
            // final isNonAirWeight = isNonAir.time / isNonAir.time + isAir.time;
            final weight = isNonAir.time / (isNonAir.time + isAir.time);

            final xColl = xCollides(isNonAir.x, isNonAir.y, isAir.x, isAir.y);
            if (xColl) {
                isNonAir.velocity.set(
                    -isNonAir.velocity.x + isAir.velocity.x * weight,
                    isNonAir.velocity.y + isAir.velocity.y * weight
                );
            } else {
                isNonAir.velocity.set(
                    isNonAir.velocity.x + isAir.velocity.x * weight,
                    -isNonAir.velocity.y + isAir.velocity.y * weight
                );
            }

            separateElements(isNonAir, isAir, xColl);
            onSignal(WindDeflect);
            return;
        }

        if (elem1.type == elem2.type) {
            elem1.deactivate();
            elem2.deactivate();

            var fromActor = elem2.fromActor;
            if (elem1.time < elem2.time) {
                fromActor = elem1.fromActor;
            }

            final elem1Weight = elem1.time / (elem2.time + elem1.time);
            final elem2Weight = elem2.time / (elem2.time + elem1.time);

            addElement(
                elem1.x,
                elem2.y,
                elem1.type,
                new Vec2(
                    (elem1.velocity.x * elem1Weight + elem2.velocity.x * elem2Weight) / 2,
                    (elem1.velocity.y * elem1Weight + elem2.velocity.y * elem2Weight) / 2
                ),
                (elem1.time + elem2.time) * .66,
                fromActor
            );
            return;
        }

        if (elem1.type == Water && elem2.type == Fire || elem2.type == Water && elem1.type == Fire) {
            var isFire:Element;
            var isWater:Element;

            if (elem1.type == Fire) {
                isFire = elem1;
                isWater = elem2;
            } else {
                isFire = elem2;
                isWater = elem1;
            }

            final fireTime = isFire.time;
            isFire.time -= isWater.time * 2;
            isWater.time -= fireTime;

            onSignal(SteamParticle, { pos: new Vec2((isFire.x + isWater.x) / 2, (isFire.y + isWater.y) / 2) });
            return;
        }

        trace('unhandled interaction ${elem1.type} and ${elem2.type}');
    }

    public function meleeAttack (x:Int, y:Int, fromActor:Actor) {
        for (actor in actors) {
            if (
                actor != fromActor &&
                Math.abs(actor.x - x) < HIT_DISTANCE &&
                Math.abs(actor.y - y) < HIT_DISTANCE
            ) {
                actor.doMeleeDamage(fromActor);
            }
        }
    }

    function addActor (actor:Actor) {
        final pos = actor.getPosition();
        final gridItem = getGridItem(grid, pos.x, pos.y);
        if (gridItem != null) {
            gridItem.actor = actor;
            actors.push(actor);
        }
    }

    public function removeActor (actor:Actor) {
        final pos = actor.getLinkedPosition();
        final gridItem = getGridItem(grid, pos.x, pos.y);
        gridItem.actor = null;
        actors.remove(actor);

        if (actor == playerActor) {
            onSignal(PlayerDead);
        } else if (actors.length == 1 && isBossLevel && actor != playerActor) {
            onSignal(BossDead);
            isBossDead = true;
        }
    }

    public function addElement (x:Float, y:Float, type:ElementType, vel:Vec2, time:Float, fromActor:Actor, preTime:Float = 0.0) {
        final element = new Element(x, y, type, vel, time, fromActor, preTime);
        elements.push(element);
        onAddElement(element);
    }

    public function removeElement (element:Element) {
        elements.remove(element);
        onRemoveElement(element);
    }
}
