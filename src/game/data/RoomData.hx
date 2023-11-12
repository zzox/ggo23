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

typedef PreGrid = Array<Array<Null<TileType>>>;

function makeRoom (roomString:String):Grid {
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

    return makeMap(rowsToColumns(width, height, rowItems));
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

function createRoomItems () {

}
