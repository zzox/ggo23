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
        actors.push(playerActor);

        for (enemySpawner in generatedWorld.spawners) {
            // MD: enemy type from randomness in level config.
            final rat = new Actor(enemySpawner.x, enemySpawner.y, this, Rat);
            actors.push(rat);
        }

        this.size = size;

        this.onAddElement = onAddElement;
        this.onRemoveElement = onRemoveElement;
    }

    public function update (delta) {
        for (actor in actors) {
            actor.update(delta);
        }
        for (element in elements) {
            element.update(delta);
            if (element.time < 0.0) {
                removeElement(element);
            }
        }
    }

    // TODO: velocity?
    public function addElement (x:Int, y:Int, type:ElementType) {
        final element = new Element(x, y, type, 1.0);
        final gridItem = getGridItem(grid, x, y);
        gridItem.element = element;
        elements.push(element);
        onAddElement(element);
    }

    public function removeElement (element:Element) {
        final gridItem = getGridItem(grid, Std.int(element.x), Std.int(element.y));
        gridItem.element = null;
        elements.remove(element);
        onRemoveElement(element);
    }
}
