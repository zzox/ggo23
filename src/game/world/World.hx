package game.world;

import core.Types;
import game.data.FloorData;
import game.data.GameData;
import game.data.RoomData;
import game.util.ShuffleRandom;
import game.util.Utils;
import game.world.Element;
import game.world.Grid;
import kha.math.Random;

enum TileType {
    Tile;
}

class Object {}

typedef ElementAdd = (e:Element) -> Void;

class World {
    public static inline final HIT_DISTANCE:Float = 0.75;

    public var grid:Grid;
    public var size:IntVec2;
    public var actors:Array<Actor> = [];
    public var objects:Array<Object> = [];
    public var elements:Array<Element> = [];
    public var portalPos:IntVec2;
    var step:Int = 0; // used for debugging

    public var playerActor:Actor;

    var onAddElement:ElementAdd;
    var onRemoveElement:ElementAdd;

    public var isPaused:Bool = false;

    public function new (onAddElement:ElementAdd, onRemoveElement:ElementAdd) {
        // ATTN: initializing static vars this way
        new GameData();

        // TODO: bring in from singleton.
        final floorNum = 0;
        final random = new Random(Math.floor(Math.random() * 65536));
        trace(random.GetFloat());
        final data = floorData[floorNum];
        final generatedWorld = generate(floorNum, random);
        grid = generatedWorld.grid;

        portalPos = generatedWorld.portal;
        // final item = getGridItem(grid, generatedWorld.portal.x, generatedWorld.portal.y);

        playerActor = new Actor(generatedWorld.playerPos.x, generatedWorld.playerPos.y, this, PlayerActor);
        addActor(playerActor);

        final randomEnemy = new ShuffleRandom(data.enemies, random);
        for (enemySpawner in generatedWorld.spawners) {
            final enemy = new Actor(enemySpawner.x, enemySpawner.y, this, randomEnemy.getNext());
            addActor(enemy);
            enemy.target = playerActor;
        }

        this.size = data.size;

        this.onAddElement = onAddElement;
        this.onRemoveElement = onRemoveElement;
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
                    Math.abs(element.x - actor.x) < HIT_DISTANCE &&
                    Math.abs(element.y - actor.y) < HIT_DISTANCE
                ) {
                    actor.doElementDamage(element);
                    element.velocity.x *= 0.5;
                    element.velocity.y *= 0.5;
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
    }

    function handleElementInteraction (elem1:Element, elem2:Element) {
        if (elem1.type == Lightning || elem2.type == Lightning) {
            // ATTN: delete this
            if (elem1.type == Lightning && elem2.type == Lightning) {
                throw 'Shoudlnt be here!';
            }

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

            final xColl = xCollides(isNonAir.x, isNonAir.y, isAir.x, isAir.y);
            if (xColl) {
                isNonAir.velocity.set(-isNonAir.velocity.x + isAir.velocity.x, isNonAir.velocity.y + isAir.velocity.y);
            } else {
                isNonAir.velocity.set(isNonAir.velocity.x + isAir.velocity.x, -isNonAir.velocity.y + isAir.velocity.y);
            }

            separateElements(isNonAir, isAir, xColl);
            return;
        }

        if (elem1.type == elem2.type) {
            trace('combine!', elem1.time + elem2.time);
            elem1.deactivate();
            elem2.deactivate();

            addElement(
                elem1.x,
                elem2.y,
                elem1.type,
                // TODO: normalize
                new Vec2(elem1.velocity.x + elem2.velocity.x, elem1.velocity.y + elem2.velocity.y),
                elem1.time + elem2.time,
                null
            );
            return;
        }

        throw 'unhandled interaction ${elem1.type} and ${elem2.type}';
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
