package game.world;

import core.Types;
import game.util.Pathfinding;
import game.world.World;

typedef GridItem = {
    var x:Int;
    var y:Int;
    var tile:Null<TileType>;
    var actor:Null<Actor>;
    var object:Null<Object>;
}

typedef Grid = Array<Array<GridItem>>;

enum GridDir {
    North;
    South;
    East;
    West;
    NorthEast;
    NorthWest;
    SouthEast;
    SouthWest;
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

// map a two dimensional array to a new array of the same or different type.
function twoDMap <T, TT>(grid:Array<Array<T>>, callback:(T, Int, Int) -> TT):Array<Array<TT>> {
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
        return null;
    }

    return grid[x][y];
}

// doesn't work for some reason
// function getSubgrid (grid:Grid, topLeft:IntVec2, size:IntVec2):Grid {
//     final grid = [];

//     for (x in topLeft.x...(topLeft.x + size.x)) { // width
//         final column = [];

//         for (y in topLeft.y...(topLeft.y + size.y)) { // height
//             trace(getGridItem(grid, x, y), x, y);
//             column.push(getGridItem(grid, x, y));
//         }

//         grid.push(column);
//     }

//     return grid;
// }
