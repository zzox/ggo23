package game.world;

import core.Types;
import game.data.ActorData;
import game.data.RoomData;
import game.world.Element;
import game.world.Grid;

enum TileType {
    Tile;
}

class Object {}

typedef ElementAdd = (e:Element) -> Void;

class World {
    static inline final HIT_DISTANCE:Float = 0.75;

    public var grid:Grid;
    public var size:IntVec2;
    public var actors:Array<Actor> = [];
    public var objects:Array<Object> = [];
    public var elements:Array<Element> = [];

    public var playerActor:Actor;

    var onAddElement:ElementAdd;
    var onRemoveElement:ElementAdd;

    public function new (size:IntVec2, onAddElement:ElementAdd, onRemoveElement:ElementAdd) {
        // grid = makeGrid(size, (x, y) -> {
        //     return { x: x, y: y, tile: Tile, object: null, actor: null, element: null };
        // });
        // grid = makeMap(makeRoom(mainRoom1).preGrid);
        final enemyTypes:Array<ActorType> = [BigRat, Snake, BigRat];
        final generatedWorld = generate(size.x, size.y);
        grid = generatedWorld.grid;

        playerActor = new Actor(generatedWorld.playerPos.x, generatedWorld.playerPos.y, this, PlayerActor);
        addActor(playerActor);

        for (enemySpawner in generatedWorld.spawners) {
            // MD: enemy type from randomness in level config.
            final type = enemyTypes[Math.floor(Math.random() * enemyTypes.length)];
            final enemy = new Actor(enemySpawner.x, enemySpawner.y, this, type);
            addActor(enemy);
            enemy.target = playerActor;
        }

        this.size = size;

        this.onAddElement = onAddElement;
        this.onRemoveElement = onRemoveElement;
    }

    public function update (delta:Float) {
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
                // collides with walls
                element.velocity.set(0, 0);
            }
        }

        for (element in elements) {
            if (!element.active) {
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

    public function addElement (x:Float, y:Float, type:ElementType, vel:Vec2, time:Float, fromActor:Actor) {
        final element = new Element(x, y, type, vel, time, fromActor);
        elements.push(element);
        onAddElement(element);
    }

    public function removeElement (element:Element) {
        elements.remove(element);
        onRemoveElement(element);
    }
}
