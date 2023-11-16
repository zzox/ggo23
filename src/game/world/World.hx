package game.world;

import core.Types;
import game.data.RoomData;
import game.world.Element;
import game.world.Grid;

enum TileType {
    Tile;
}

class Object {}

typedef ElementAdd = (e:Element) -> Void;

class World {
    static inline final MELEE_DISTANCE:Float = 0.75;

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
        final generatedWorld = generate(size.x, size.y);
        grid = generatedWorld.grid;

        playerActor = new Actor(generatedWorld.playerPos.x, generatedWorld.playerPos.y, this, PlayerActor);
        addActor(playerActor);

        for (enemySpawner in generatedWorld.spawners) {
            // MD: enemy type from randomness in level config.
            final rat = new Actor(enemySpawner.x, enemySpawner.y, this, Rat);
            addActor(rat);
        }

        this.size = size;

        this.onAddElement = onAddElement;
        this.onRemoveElement = onRemoveElement;
    }

    public function update (delta:Float) {
        for (actor in actors) {
            if (actor.isManaged) {
                actor.manage();
            }
            actor.update(delta);
        }
        for (element in elements) {
            element.update(delta);
            final pos = element.getNearestPosition();
            final gi = getGridItem(grid, pos.x, pos.y);
            if (gi == null || gi.tile == null) {
                // collides with walls
                element.velocity.set(0, 0);
            }

            if (!element.active) {
                // ATTN: will this stop the next element's update from happening?
                removeElement(element);
            }
        }
    }

    public function meleeAttack (x:Int, y:Int, fromActor:Actor) {
        for (actor in actors) {
            if (
                actor != fromActor &&
                Math.abs(actor.x - x) < MELEE_DISTANCE &&
                Math.abs(actor.y - y) < MELEE_DISTANCE
            ) {
                actor.doMeleeDamage(fromActor);
                trace(fromActor.x, fromActor.y, actor.x, actor.y);
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

    // TODO: velocity?
    public function addElement (x:Float, y:Float, type:ElementType, vel:Vec2) {
        final element = new Element(x, y, type, vel);
        elements.push(element);
        onAddElement(element);
    }

    public function removeElement (element:Element) {
        elements.remove(element);
        onRemoveElement(element);
    }
}
