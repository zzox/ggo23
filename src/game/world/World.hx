package game.world;

import core.Types;

enum TileType {
    Tile;
}

class Actor {}

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

    public function new (size:IntVec2) {
        grid = makeGrid(size, (x, y) -> {
            return { x: x, y: y, tile: Tile, object: null, actor: null };
        });
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
