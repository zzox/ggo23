package game.data;

import core.Types;
import core.Util;
import game.util.Pathfinding;
import game.util.ShuffleRandom;
import game.world.Grid;
import game.world.World;
import js.html.Console;
import kha.math.Random;

final mainRoom1 = "
             X
 xxxxxxxxxxxxxxxxxx
 xxPxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxx
XxxxxxxxxxxxxxxxxxxX
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxx1xxx
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxx1xxx
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxxxxxx
 xxxxxxxxxxxxxx1xxx
 xxxxxxxxxxxxxxxxxx
  X
";

final mainRoom1Old = "
        X
 xxxxxxxxx
 xxPxxxxxx
 xxxxxxxxx
 xxxxxxxxx
XxxxxxxxxxX
 xxxxxxxxx
 xxxxxx1xx
 xxxxxxxxx
  X
";

enum TileType {
    Ground;
    PlayerSpawn;
    EnemySpawn1;
    Exit;
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
                case 'P': PlayerSpawn;
                case '1': EnemySpawn1;
                case 'X': Exit;
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
                    { x: x, y: y, tile: null, object: null, actor: null, element: null } :
                    { x: x, y: y, tile: Tile, object: null, actor: null, element: null }
            );
        }
        items.push(column);
    }
    return items;
}

function getClosestExit (room:Rect, exits:Array<IntVec2>):Null<IntVec2> {
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

function getAdjacentItems <T>(grid:Array<Array<T>>, x:Int, y:Int) {
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

typedef PlacedRoom = {
    var id:Int;
    var rect:Rect;
    var connected:Bool;
    var exits:Array<IntVec2>;
}

typedef GeneratedWorld = {
    var grid:Grid;
    var playerPos:IntVec2;
    var spawners:Array<IntVec2>;
}

function generate (width:Int, height:Int, rooms:Array<String>, random:Random):GeneratedWorld {
    Console.time('generation');

    final PLACE_ATTEMPTS:Int = 100;
    final maxPlacedRooms:Int = 10;
    final roomPadding:Int = 2;
    var numPaths:Int = 0;

    var roomId:Int = 0;
    final roomsPlaced:Array<PlacedRoom> = [];
    var initialConnected:Bool = true;
    var playerPos:Null<IntVec2> = null;
    final enemySpawners:Array<IntVec2> = [];

    final randomRoom = new ShuffleRandom(rooms, random);

    final pregrid = makeEmptyPregrid(width, height);
    for (_ in 0...PLACE_ATTEMPTS) {
        // MD: room types
        final room = makeRoom(randomRoom.getNext());

        // random x and y position minus the width and height to not go off the edge
        final randomX = Math.floor(random.GetFloat() * (width - room.width));
        final randomY = Math.floor(random.GetFloat() * (height - room.height));

        var roomCollided = false;
        for (r in roomsPlaced) {
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
            final exits = [];
            twoDMap(room.preGrid, (item:Null<TileType>, x:Int, y:Int) -> {
                if (item == Exit) {
                    exits.push(new IntVec2(randomX + x, randomY + y));
                } else if (item == PlayerSpawn) {
                    pSpawn = new IntVec2(x + randomX, y + randomY);
                } else if (item == EnemySpawn1 && !initialConnected) {
                    enemySpawners.push(new IntVec2(x + randomX, y + randomY));
                }
            });

            roomsPlaced.push({
                id: roomId++,
                exits: exits,
                rect: {
                    x: randomX - roomPadding,
                    y: randomY - roomPadding,
                    height: room.height + roomPadding * 2,
                    width: room.width + roomPadding * 2
                },
                connected: initialConnected,
            });

            // make this the starting point if this is the first room to be placed.
            if (initialConnected) {
                playerPos = pSpawn;
            }

            initialConnected = false;

            if (roomsPlaced.length == maxPlacedRooms) {
                break;
            }
        }
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

    // 2. connect rooms
        // a. pathfind between each exit
            // i. manhattan, only opposites
            // ii. don't try this if the distance is too far (customizable?)

    // start with the closest rooms
    final otherRooms = roomsPlaced.copy();
    otherRooms.sort((room1:PlacedRoom, room2:PlacedRoom) -> {
        final roomZeroPos = new Vec2(roomsPlaced[0].rect.x + roomsPlaced[0].rect.width / 2, roomsPlaced[0].rect.y + roomsPlaced[0].rect.height / 2);
        return Std.int(Math.abs(distanceBetween(
            roomZeroPos, new Vec2(room1.rect.x + room1.rect.width / 2, room1.rect.y + room1.rect.height / 2),
        )) - Math.abs(distanceBetween(
            roomZeroPos, new Vec2(room2.rect.x + room2.rect.width / 2, room2.rect.y + room2.rect.height / 2),
        )));
    });

    var connectedMap:Map<Int, Array<Int>> = [];

    final hallways = [];
    for (room in roomsPlaced) {
        connectedMap[room.id] = [];

        for (otherRoom in otherRooms) {
            if (otherRoom != room) {
                final distance = distanceBetween(
                    new Vec2(room.rect.x + room.rect.width / 2, room.rect.y + room.rect.height / 2),
                    new Vec2(otherRoom.rect.x + otherRoom.rect.width / 2, otherRoom.rect.y + otherRoom.rect.height / 2)
                );

                // final it = Math.pow(((width + height) / 2), 2) / 2;
                // trace(it, distance);

                final isConnected = connectedMap[room.id].contains(otherRoom.id) || (connectedMap[otherRoom.id] != null && connectedMap[otherRoom.id].contains(room.id));

                // TODO: figure out better method to determine pathing
                if (!isConnected && distance < width * .5 && ((otherRoom.connected && random.GetFloat() < 0.1) || !otherRoom.connected)) {
                    final roomExit = getClosestExit(otherRoom.rect, room.exits);
                    final otherRoomExit = getClosestExit(room.rect, otherRoom.exits);

                    if (roomExit != null && otherRoomExit != null) {
                        final path = pathfind(intGrid, roomExit, otherRoomExit, Manhattan, false, 50);
                        numPaths++;

                        if (path != null && path.length > 0) {
                            // add the first tile to the start of the path
                            path.unshift(roomExit);
                            hallways.push(path);
                            room.exits.remove(roomExit);
                            otherRoom.exits.remove(otherRoomExit);

                            connectedMap[room.id].push(otherRoom.id);

                            // only mark as connected if one of the two are connected.
                            // TODO: do the same to hallways.
                            if (room.connected || otherRoom.connected) {
                                room.connected = true;
                                otherRoom.connected = true;
                            }
                            continue;
                        }
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

    // TODO: if a room hasn't been touched, remove it

    trace('num paths tried', numPaths, enemySpawners.length);
    Console.timeEnd('generation');
    return {
        grid: makeMap(pregrid),
        playerPos: playerPos,
        spawners: enemySpawners
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
