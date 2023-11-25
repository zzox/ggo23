package game.data;

import core.Types;
import game.data.ActorData;
import game.data.RoomData;

typedef FloorData = {
    var size:IntVec2;
    var rooms:Array<String>;
    var enemies:Array<ActorType>;
    var minRooms:Int;
}

final floorData:Array<FloorData> = [{
    minRooms: 5,
    size: new IntVec2(60, 60),
    rooms: [mainRoom1Old, smallRoomNorthSouth, smallRoomEastWest, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [Spitter, Butterfly]
}, {
    minRooms: 5,
    size: new IntVec2(60, 60),
    rooms: [mainRoom1Old, smallRoomNorthSouth, smallRoomEastWest, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [Rat, Unicorn, LightningMan]
}, {
    minRooms: 7,
    size: new IntVec2(70, 70),
    rooms: [mainRoom1Old, mainRoom1, mainRoom1, mainRoom1, mainRoom1, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [BigRat, BigRat, Snake, Snake, Snake, Plant]
}];
