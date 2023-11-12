package game.data;

import game.world.Grid;
import game.world.World;

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
}

typedef RawRoom = {
    var width:Int;
    var height:Int;
    var rows:Array<Array<Null<TileType>>>;
}

function makeRoom (roomString:String):RawRoom {
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
        width: width,
        height: height,
        rows: rowItems
    }
}

function createRoomItems () {

}

function createMap (rows:Array<Array<Null<TileType>>>):Array<Array<GridItem>> {
    trace(rows);

    final items = [];
    for (x in 0...12) {
        final column = [];
        for (y in 0...12) {
            if (rows[y] != null) {
                column.push(
                    rows[y][x] == null ?
                        { x: x, y: y, tile: null, object: null, actor: null, element: null } :
                        { x: x, y: y, tile: Tile, object: null, actor: null, element: null }
                );
            }
        }
        items.push(column);
    }
    return items;
}
