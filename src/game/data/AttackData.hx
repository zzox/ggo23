package game.data;

import game.data.ShapeData;
import game.world.Element;

enum AttackType {
    Melee;
    Range;
    Magic;
}

typedef AttackData = {
    var preTime:Float; // wind-up time
    var time:Float; // How long it takes to execute. (post-time)
    var type:AttackType;
    var ?vel:Float;
    var ?power:Float; // how long this stays around, correlates to its damage.
    var ?element:ElementType;
    var ?shape:Shape;
    var ?imageIndex:Int;
    var ?name:String;
}

enum AttackName {
    Bite;
    Fireball;
    Windthrow;
    Raincast;
    Castlight;
    Firestorm;
    Windstorm;
    Rainstorm;
    Lightstorm;
    // for enemies
    BFRainstorm;
    DragonFirestorm;
}

final attackData:Map<AttackName, AttackData> = [
Bite => {
    preTime: 0.5,
    time: 0.5,
    type: Melee
},
Fireball => {
    preTime: 0.5,
    time: 0.5,
    type: Range,
    vel: 5.0,
    power: 2.0,
    element: Fire,
    imageIndex: 0,
    name: 'Fireball'
},
Windthrow => {
    preTime: 0.5,
    time: 0.5,
    type: Range,
    vel: 2.5,
    power: 2.0,
    element: Air,
    imageIndex: 1,
    name: 'Windthrow'
},
Castlight => {
    preTime: 2.0,
    time: 2.0,
    type: Magic,
    power: 2.0,
    element: Lightning,
    shape: single,
    imageIndex: 2,
    name: 'Castlight'
},
Raincast => {
    preTime: 0.5,
    time: 0.5,
    type: Range,
    vel: 5.0,
    power: 2.0,
    element: Water,
    imageIndex: 3,
    name: 'Raincast'
},
Firestorm => {
    preTime: 3.0,
    time: 3.0,
    type: Magic,
    vel: 0.0,
    power: 3.0,
    element: Fire,
    shape: bigSquare,
    imageIndex: 4
},
Windstorm => {
    preTime: 2.0,
    time: 2.0,
    type: Magic,
    vel: 0.0,
    power: 2.0,
    element: Air,
    shape: movingBox,
    imageIndex: 5
},
Lightstorm => {
    preTime: 3.0,
    time: 3.0,
    type: Magic,
    power: 3.0,
    element: Lightning,
    shape: bigX,
    imageIndex: 6
},
Rainstorm => {
    preTime: 2.0,
    time: 2.0,
    type: Magic,
    vel: 0.0,
    power: 2.0,
    element: Water,
    shape: waterFall,
    imageIndex: 7
}, BFRainstorm => { // just for butterfly
    preTime: 1.5,
    time: 1.5,
    type: Magic,
    vel: 0.0,
    power: 2.0,
    element: Water,
    shape: waterFall
}, DragonFirestorm => {
    preTime: 1.5,
    time: 1.5,
    type: Magic,
    vel: 0.0,
    power: 3.0,
    element: Fire,
    shape: bigSquare
}];

function cloneSpell (name:AttackName):AttackData {
    final data = attackData[name];
    return {
        preTime: data.preTime,
        time: data.time,
        type: data.type,
        vel: data.vel,
        power: data.power,
        element: data.element,
        shape: data.shape,
        name: data.name,
        imageIndex: data.imageIndex
    }
}
