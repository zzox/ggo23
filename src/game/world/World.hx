package game.world;

import core.Types;
import game.util.Pathfinding.IntGrid;

enum TileType {
    Tile;
}

class Object {}

typedef GridItem = {
    var x:Int;
    var y:Int;
    var tile:Null<TileType>;
    var actor:Null<Actor>;
    var object:Null<Object>;
}

typedef Grid = Array<Array<GridItem>>;

class World {
    public var grid:Grid;
    public var size:IntVec2;
    public var actors:Array<Actor> = [];
    public var objects:Array<Object> = [];

    public var playerActor:Actor;

    public function new (size:IntVec2) {
        grid = makeGrid(size, (x, y) -> {
            return { x: x, y: y, tile: Tile, object: null, actor: null };
        });

        playerActor = new Actor(2, 2, this);
        actors.push(playerActor);
        this.size = size;
    }

    public function update (delta) {
        for (actor in actors) actor.update(delta);
        // for (object in objects) object.update(delta);
    }
}

function makeGrid (size:IntVec2, callback:(Int, Int) -> GridItem):Grid {
    final grid = [];

    for (x in 0...size.x) { // width
        final column = [];

        for (y in 0...size.y) { // height
            column.push(callback(x, y));
        }

        grid.push(column);
    }

    return grid;
}

function twoDMap <T>(grid:Grid, callback:(GridItem, Int, Int) -> T):Array<Array<T>> {
    final items = [];
    for (x in 0...grid.length) {
        final column = [];
        for (y in 0...grid[x].length) {
            column.push(callback(grid[x][y], x, y));
        }
        items.push(column);
    }
    return items;
}

function makeIntGrid (grid:Grid):IntGrid {
    return twoDMap(grid, (item, x, y) -> item.tile != null && item.actor == null && item.object == null ? 1 : 0);
}

function getGridItem (grid:Grid, x:Int, y:Int):Null<GridItem> {
    if (x < 0 || y < 0 || x >= grid.length || y >= grid[0].length) {
        trace('cannot get grid item, out of bounds at ${x}, ${y}');
        return null;
    }

    return grid[x][y];
}
