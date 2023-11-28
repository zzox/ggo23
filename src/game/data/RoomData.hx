package game.data;

import core.Types;
import core.Util;
import game.data.FloorData;
import game.util.Pathfinding;
import game.util.ShuffleRandom;
import game.world.Grid;
import game.world.World;
import js.html.Console;
import kha.math.Random;

final mainRoom1Big = "
             X
 xxxxxxxxxxxxxxxxxx
 xxPxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxx
XxxxxxxxxxxxxxxxxxxX
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxx1xxx
 xxxxxxxxOxxxxxxxx
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxx1xxx
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxx1xxx
 xxxxxxxxxxxxxxxxxx
  X
";

final mainRoom1Med = "
        X
 xxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxx
 xxxxxxxPxxxxxxx
XxxxxxxxxxxxxxxxX
 xxxxxxxxxxx1xxx
 xxxxxxxxOxxxxxx
 xxxx1xxxxxxxxxx
 xxxxxxxxxxx1xxx
 xxxxxxxxxxxxxxx
         X
";

final mainRoom1Small = "
     X
 xxxxxxxxx
 xxPxxxxxx
 xxxxxxxxx
 xxxxxxxxx
XxxxxOxxxxX
 xxxxxxxxx
 xxxxxx1xx
 xxxxxxxxx
     X
";

final smallRoomNorthSouth = "
     X
 xxxxxxxxx
 xxPxxxxxx
 xxxxxxxxx
 xxxxxxxxx
 xxxxxxxOx
 xxxxxxxxx
 xxxxxx1xx
 xxxxxxxxx
     X
";

final smallRoomEastWest = "
 xxxxxxxxx
 xxPxxxxxx
 xxxxxxxxx
 xxxxxxxxx
XxxxxxxxxxX
 xxxxxxxxx
 xxxxOx1xx
 xxxxxxxxx
";

enum TileType {
    Ground;
    PlayerSpawn;
    EnemySpawn1;
    Exit;
    Hallway;
    Portal;
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
                case 'P': PlayerSpawn;
                case '1': EnemySpawn1;
                case 'X': Exit;
                case 'O': Portal;
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
    final items = [];
    for (x in 0...rows.length) {
        final column = [];
        for (y in 0...rows[x].length) {
            // TODO: switch for tiletype
            column.push(
                rows[x][y] == null || rows[x][y] == Exit ?
                    { x: x, y: y, tile: null, object: null, actor: null, element: null, seen: false } :
                    { x: x, y: y, tile: Tile, object: null, actor: null, element: null, seen: false }
            );
        }
        items.push(column);
    }
    return items;
}

function getClosestExit (room:IntRect, exits:Array<IntVec2>):Null<IntVec2> {
    final roomPos = new Vec2(room.x + room.width / 2, room.y + room.height / 2);

    var exit:Null<IntVec2> = null;
    var exitDist:Float = 0.0;
    for (e in exits) {
        final distance = distanceBetween(roomPos, e.toVec2());
        if (exit == null || distance < exitDist) {
            exit = e;
            exitDist = distance;
        }
    }

    return exit;
}

function getAdjacentItems <T>(grid:Array<Array<T>>, x:Int, y:Int):Array<T> {
    final items = [];

    items.push(grid[x + 1] != null ? grid[x + 1][y] : null);
    items.push(grid[x] != null ? grid[x][y + 1] : null);
    items.push(grid[x - 1] != null ? grid[x - 1][y] : null);
    items.push(grid[x] != null ? grid[x][y - 1] : null);
    items.push(grid[x + 1] != null ? grid[x + 1][y + 1] : null);
    items.push(grid[x - 1] != null ? grid[x - 1][y + 1] : null);
    items.push(grid[x + 1] != null ? grid[x + 1][y - 1] : null);
    items.push(grid[x - 1] != null ? grid[x - 1][y - 1] : null);

    return items.filter((item) -> item != null);
}

function get4AdjacentItems <T>(grid:Array<Array<T>>, x:Int, y:Int):Array<T>  {
    final items = [];

    items.push(grid[x + 1] != null ? grid[x + 1][y] : null);
    items.push(grid[x] != null ? grid[x][y + 1] : null);
    items.push(grid[x - 1] != null ? grid[x - 1][y] : null);
    items.push(grid[x] != null ? grid[x][y - 1] : null);

    return items.filter((item) -> item != null);
}

typedef PlacedRoom = {
    var id:Int;
    var rect:IntRect;
    var connected:Int;
    var exits:Array<IntVec2>;
    var startRoom:Bool;
    var spawners:Array<IntVec2>;
    var portal:IntVec2;
}

typedef GeneratedWorld = {
    var grid:Grid;
    var playerPos:IntVec2;
    var spawners:Array<IntVec2>;
    var portal:IntVec2;
}

function generate (floorNum:Int, random:Random):GeneratedWorld {
    Console.time('generation');

    final data = floorData[floorNum];
    final width = data.size.x;
    final height = data.size.y;

    // increase this
    final GEN_ATTEMPTS:Int = 100;
    final PLACE_ATTEMPTS:Int = 100;
    final roomPadding:Int = 2;

    final randomRoom = new ShuffleRandom(data.rooms, random);

    var roomId:Int = 0;
    var numPaths:Int = 0;
    var initialConnected:Bool = true;
    var playerPos:Null<IntVec2> = null;
    var enemySpawners:Array<IntVec2> = [];
    var placedRooms:Array<PlacedRoom> = [];
    var pregrid:PreGrid = makeEmptyPregrid(0, 0);

    for (_ in 0...GEN_ATTEMPTS) {
        pregrid = makeEmptyPregrid(width, height);
        for (__ in 0...PLACE_ATTEMPTS) {
            // MD: room types
            final room = makeRoom(randomRoom.getNext());

            // random x and y position minus the width and height to not go off the edge
            final randomX = Math.floor(random.GetFloat() * (width - room.width));
            final randomY = Math.floor(random.GetFloat() * (height - room.height));

            var roomCollided = false;
            for (r in placedRooms) {
                if (rectOverlap(randomX, randomY, room.width, room.height, r.rect.x, r.rect.y, r.rect.width, r.rect.height)) {
                    roomCollided = true;
                    trace('collided');
                    break;
                }
            }

            if (!roomCollided) {
                // TODO: don't place grid here, wait until the end.
                copyPregrid(pregrid, room.preGrid, randomX, randomY);
                // pad the rooms after placement

                var pSpawn:Null<IntVec2> = null;
                var portal:Null<IntVec2> = null;
                final exits = [];
                var spawners:Array<IntVec2> = [];
                twoDMap(room.preGrid, (item:Null<TileType>, x:Int, y:Int) -> {
                    if (item == Exit) {
                        exits.push(new IntVec2(randomX + x, randomY + y));
                    } else if (item == PlayerSpawn) {
                        pSpawn = new IntVec2(x + randomX, y + randomY);
                    } else if (item == EnemySpawn1 && !initialConnected) {
                        spawners.push(new IntVec2(x + randomX, y + randomY));
                    } else if (item == Portal) {
                        portal = new IntVec2(x + randomX, y + randomY);
                    }
                });

                placedRooms.push({
                    id: roomId++,
                    exits: exits,
                    rect: {
                        x: randomX - roomPadding,
                        y: randomY - roomPadding,
                        height: room.height + roomPadding * 2,
                        width: room.width + roomPadding * 2
                    },
                    connected: initialConnected ? 1 : 0,
                    startRoom: initialConnected,
                    spawners: spawners,
                    portal: portal
                });

                // make this the starting point if this is the first room to be placed.
                if (initialConnected) {
                    playerPos = pSpawn;
                }

                initialConnected = false;

                if (placedRooms.length == Math.floor(data.minRooms * 1.5)) {
                    break;
                }
            }
        }

        if (placedRooms.length >= data.minRooms) {
            break;
        }
        trace('gen failed');

        roomId = 0;
        numPaths = 0;
        initialConnected = true;
        playerPos = null;
        enemySpawners = [];
        placedRooms = [];
    }

    final intGrid = twoDMap(pregrid, (type:Null<TileType>, x:Int, y:Int) -> {
        if (type != null) {
            return 0;
        }

        final adjacentItems = getAdjacentItems(pregrid, x, y);
        final isRoomAdjacent = Lambda.fold(adjacentItems, (item:Null<TileType>, res:Bool) -> {
            if (item == Ground) {
                return true;
            }
            return res;
        }, false);

        return isRoomAdjacent ? 0 : 1;
    });

    // start with the closest rooms
    final roomZeroPos = new Vec2(placedRooms[0].rect.x + placedRooms[0].rect.width / 2, placedRooms[0].rect.y + placedRooms[0].rect.height / 2);
    final otherRooms = placedRooms.copy();
    otherRooms.sort((room1:PlacedRoom, room2:PlacedRoom) -> {
        return Std.int(Math.abs(distanceBetween(
            roomZeroPos, new Vec2(room1.rect.x + room1.rect.width / 2, room1.rect.y + room1.rect.height / 2),
        )) - Math.abs(distanceBetween(
            roomZeroPos, new Vec2(room2.rect.x + room2.rect.width / 2, room2.rect.y + room2.rect.height / 2),
        )));
    });

    var connectedMap:Map<Int, Array<Int>> = [];

    final hallways = [];
    for (room in placedRooms) {
        connectedMap[room.id] = [];

        for (otherRoom in otherRooms) {
            if (otherRoom != room && (room.connected > 0 || otherRoom.connected > 0)) {
                final distance = distanceBetween(
                    new Vec2(room.rect.x + room.rect.width / 2, room.rect.y + room.rect.height / 2),
                    new Vec2(otherRoom.rect.x + otherRoom.rect.width / 2, otherRoom.rect.y + otherRoom.rect.height / 2)
                );

                // are these two rooms connected already?
                final isConnected = connectedMap[room.id].contains(otherRoom.id) || (connectedMap[otherRoom.id] != null && connectedMap[otherRoom.id].contains(room.id));

                // TODO: figure out better method to determine pathing
                // connect if they:
                // -arent already connected
                // -closer than half the width of the map
                // -arent already well-connected rooms
                // --later we check to see if their paths are short enough
                if (
                    !isConnected &&
                    distance < width * .5 &&
                    (
                        (otherRoom.connected > 0 &&
                            random.GetFloat() < (0.1 - otherRoom.connected * 0.03)) ||
                        (otherRoom.connected == 0 && random.GetFloat() < 1.1 - room.connected * .1)
                    )
                ) {
                    final roomExit = getClosestExit(otherRoom.rect, room.exits);
                    final otherRoomExit = getClosestExit(room.rect, otherRoom.exits);

                    if (roomExit != null && otherRoomExit != null) {
                        final path = pathfind(intGrid, roomExit, otherRoomExit, Manhattan, false, Math.floor(height + width / 4));
                        numPaths++;

                        if (path != null && path.length > 0) {
                            // add the first tile to the start of the path
                            path.unshift(roomExit);
                            hallways.push(path);
                            // TODO: add these back if we need to. makes the pathways a bit zanier
                            // room.exits.remove(roomExit);
                            // otherRoom.exits.remove(otherRoomExit);

                            connectedMap[room.id].push(otherRoom.id);

                            // only mark as connected if one of the two are connected.
                            trace(room.connected, otherRoom.connected);
                            if (room.connected > 0 || otherRoom.connected > 0) {
                                room.connected++;
                                otherRoom.connected++;
                            }
                            continue;
                        }
                    }
                }
            }
        }
    }

    for (room in placedRooms) {
        if (room.connected > 0) {
            for (s in room.spawners) {
                enemySpawners.push(s);
            }
        } else {
            // TODO: use getSubGrid method?
            for (x in room.rect.x...(room.rect.x + room.rect.width)) {
                for (y in room.rect.y...(room.rect.y + room.rect.height)) {
                    // occasionally room dimensions will be out of bounds because of padding
                    if (pregrid[x] != null && pregrid[x][y] != null) {
                        pregrid[x][y] = null;
                    }
                }
            }
        }
    }

    for (hallway in hallways) {
        for (pos in hallway) {
            pregrid[pos.x][pos.y] = Hallway;
        }
    }

    final rooms = placedRooms.copy().filter((r) -> r.connected > 0);
    rooms.sort((room1:PlacedRoom, room2:PlacedRoom) -> {
        return Std.int(Math.abs(distanceBetween(
            roomZeroPos, new Vec2(room1.rect.x + room1.rect.width / 2, room1.rect.y + room1.rect.height / 2),
        )) - Math.abs(distanceBetween(
            roomZeroPos, new Vec2(room2.rect.x + room2.rect.width / 2, room2.rect.y + room2.rect.height / 2),
        )));
    });

    final portalPos = rooms[rooms.length - 1].portal;

    trace('num paths tried', numPaths, enemySpawners.length);
    Console.timeEnd('generation');
    return {
        grid: makeMap(pregrid),
        playerPos: playerPos,
        spawners: enemySpawners,
        portal: portalPos 
    };
}

function copyPregrid (toGrid:PreGrid, fromGrid:PreGrid, fromX:Int, fromY:Int) {
    for (x in 0...fromGrid.length) {
        final column = fromGrid[x];
        for (y in 0...column.length) {
            toGrid[fromX + x][fromY + y] = fromGrid[x][y];
        }
    }
}
