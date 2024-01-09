package game.data;

import core.Types;
import game.data.ActorData;
import game.data.RoomData;

final NUM_FLOORS = 10;

typedef FloorData = {
    var size:IntVec2;
    var rooms:Array<String>;
    var enemies:Array<ActorType>;
    var minRooms:Int;
    var isBoss:Bool;
}

final floorData:Array<FloorData> = [{
    minRooms: 3,
    size: new IntVec2(60, 60),
    rooms: [mainRoom1Med, mainRoom1Med, smallRoomNorthSouth, smallRoomEastWest, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [Rat, Rat, Snake, BigRat],
    isBoss: false
}, {
    minRooms: 5,
    size: new IntVec2(60, 60),
    rooms: [mainRoom1Med, mainRoom1Med, mainRoom1Med, mainRoom1Med, smallRoomNorthSouth, smallRoomEastWest, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [Rat, Snake, Snake, BigRat, BigRat],
    isBoss: false
}, {
    minRooms: 6,
    size: new IntVec2(70, 70),
    rooms: [mainRoom1Big, mainRoom1Big, mainRoom1Big, mainRoom1Med, mainRoom1Med, mainRoom1Small, smallRoomNorthSouth, smallRoomEastWest, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [BigRat, BigRat, Snake, Snake, Snake, Plant],
    isBoss: false
}, {
    minRooms: 1,
    size: new IntVec2(70, 70),
    rooms: [bossRoom1],
    enemies: [LightningMan],
    isBoss: true
}, {
    minRooms: 7,
    size: new IntVec2(70, 70),
    rooms: [mainRoom1Med, mainRoom1Big, mainRoom1Big, mainRoom1Big, mainRoom1Big, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [Snake, Snake, Plant, Plant, Unicorn, BigRat, BigRat, BigRat],
    isBoss: false
}, {
    minRooms: 8,
    size: new IntVec2(80, 80),
    rooms: [mainRoom1Med, mainRoom1Med, mainRoom2Med, mainRoom2Med, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [Snake, Snake, Plant, Plant, Unicorn, BigRat, BigRat, Moth],
    isBoss: false
}, {
    minRooms: 8,
    size: new IntVec2(80, 80),
    rooms: [mainRoom1Med, mainRoom1Big, mainRoom1Big, mainRoom1Big, mainRoom1Big, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [LightningMan, Snake, Plant, Unicorn, Moth],
    isBoss: false
}, {
    minRooms: 1,
    size: new IntVec2(70, 70),
    rooms: [bossRoom2],
    enemies: [Dragon],
    isBoss: true
}, {
    minRooms: 8,
    size: new IntVec2(80, 80),
    rooms: [mainRoom1Med, mainRoom1Big, mainRoom1Big, mainRoom1Big, mainRoom1Big, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [Cobra, LightningMan, Unicorn, Moth, Butterfly],
    isBoss: false
}, {
    minRooms: 9,
    size: new IntVec2(100, 100),
    rooms: [mainRoom1Med, mainRoom1Big, mainRoom1Big, mainRoom1Big, mainRoom1Big, smallRoomNorthSouth, smallRoomEastWest],
    enemies: [Cobra, LightningMan, Unicorn, Moth, Butterfly, Dragon],
    isBoss: false
}, {
    minRooms: 1,
    size: new IntVec2(80, 80),
    rooms: [bossRoom3],
    enemies: [Wizard, Tentacle, Tentacle],
    isBoss: true
}];
