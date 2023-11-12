package game.data;

import core.Types.Rect;
import core.Util;
import game.world.Grid;
import game.world.World;
import js.html.Console;

final mainRoom1 = "
     0
 xxxxxxxxx
 xxSxxxxxx
 xxxxxxxxx
 xxxxxxxxx
3xxxxxxxxx1
 xxxxxxxxx
 xxxxxxxxx
 xxxxxxxxx
  2
";

enum TileType {
    Ground;
    PlayerSpawn;
    EnemySpawn;
    NorthExit;
    EastExit;
    SouthExit;
    WestExit;
    Hallway;
}

typedef PreGrid = Array<Array<Null<TileType>>>;

typedef PreRoom = {
    var width:Int;
    var height:Int;
    var preGrid:PreGrid;
}

function makeRoom (roomString:String):PreRoom {
    var width = 0;
    var height = 0;

    final rows = roomString.split('\n');
    final newRows = [];
    for (row in rows) {
        if (row.length <= 2) {
            continue;
        }

        height++;

        if (row.length > width) {
            width = row.length;
        }
        newRows.push(row);
    }

    final rowItems = [];
    for (row in newRows) {
        final rowItem = [];
        for (i in 0...width) {
            final item = switch (row.charAt(i)) {
                case ' ': null;
                case 'x': Ground;
                case 'S': PlayerSpawn;
                case 'E': EnemySpawn;
                case '0': NorthExit;
                case '1': EastExit;
                case '2': SouthExit;
                case '3': WestExit;
                default: null;
            }
            rowItem.push(item);
        }
        rowItems.push(rowItem);
    }

    return {
        height: height,
        width: width,
        preGrid: rowsToColumns(width, height, rowItems)
    }
}

function rowsToColumns (width:Int, height:Int, rows:PreGrid):PreGrid {
    final items = [];
    for (x in 0...width) {
        final column = [];
        for (y in 0...height) {
            if (rows[y] != null) {
                column.push(rows[y][x]);
            }
        }
        items.push(column);
    }
    return items;
}

function makeEmptyPregrid<T>(width:Int, height:Int):Array<Array<T>> {
    final map = [];
    for (x in 0...width) {
        map.push([for (y in 0...height) null]);
    }
    return map;
}

function makeMap (rows:PreGrid):Grid {
    trace(rows);

    final items = [];
    for (x in 0...rows.length) {
        final column = [];
        for (y in 0...rows[x].length) {
            // TODO: switch for tiletype
            column.push(
                rows[x][y] == null ?
                    { x: x, y: y, tile: null, object: null, actor: null, element: null } :
                    { x: x, y: y, tile: Tile, object: null, actor: null, element: null }
            );
        }
        items.push(column);
    }
    return items;
}

typedef PlacedRooms = {
    var pos:Rect;
    var connected:Bool;
}

// TODO: time this
function generate (width:Int, height:Int):Grid {
    Console.time('generation');

    final roomsPlaced:Array<Rect> = [];

    final pregrid = makeEmptyPregrid(width, height);

    for (_ in 0...20) {
        // MD: room types
        final room = makeRoom(mainRoom1);

        // random x and y position minus the width and height to not go off the edge
        final randomX = Math.floor(Math.random() * (width - room.width));
        final randomY = Math.floor(Math.random() * (height - room.height));

        var roomCollided = false;
        for (r in roomsPlaced) {
            if (rectOverlap(randomX, randomY, room.width, room.height, r.x, r.y, r.width, r.height)) {
                roomCollided = true;
                trace('collided');
                break;
            }
        }

        if (!roomCollided) {
            copyPreGrid(pregrid, room.preGrid, randomX, randomY);
            // pad the rooms after placement
            final padding = 1;
            roomsPlaced.push({ x: randomX - padding, y: randomY - padding, height: room.height + padding, width: room.width + padding });
        }
    }

    // 2. connect rooms
        // a. pathfind between each exit
            // (manhattan, only opposites)
        // b. if pathfind hits anything besides hallways, we don't

    // 3. clean up
        // a. if an exit has no hallway neighbors, remove it.
        // b. if a room hasn't been touched, remove it
    Console.timeEnd('it');
    return makeMap(pregrid);
}

function copyPreGrid (toGrid:PreGrid, fromGrid:PreGrid, fromX:Int, fromY:Int) {
    for (x in 0...fromGrid.length) {
        final column = fromGrid[x];
        for (y in 0...column.length) {
            toGrid[fromX + x][fromY + y] = fromGrid[x][y];
        }
    }
}

function createRoomItems () {

}
