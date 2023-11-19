package game.data;

import core.Types;
import game.data.ActorData;
import game.data.RoomData;

typedef FloorData = {
    var size:IntVec2;
    var rooms:Array<String>;
    var enemies:Array<ActorType>;
}

final floorData:Array<FloorData> = [
{
    size: new IntVec2(70, 70),
    rooms: [mainRoom1, mainRoom1, mainRoom1Old],
    enemies: [BigRat, BigRat, Snake, Snake, Snake, Plant]
}
];
