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
}

enum AttackName {
    Bite;
    Fireball;
    Windthrow;
    Flamebigsquare;
    Castlight;
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
    element: Fire
},
Windthrow => {
    preTime: 0.5,
    time: 0.5,
    type: Range,
    vel: 2.5,
    power: 2.0,
    element: Air
},
Flamebigsquare => {
    preTime: 2.0,
    time: 2.0,
    type: Magic,
    power: 2.0,
    element: Fire,
    shape: bigSquare
},
Castlight => {
    preTime: 2.0,
    time: 2.0,
    type: Magic,
    power: 2.0,
    element: Lightning,
    shape: single
}
];


enum Scale {
    Power50;
    Vel50;
    Power100Vel;
    BeFlamebigsquare;
    BeWindStorm;
    LearnCastlight;
    LearnFireball;
    LearnWindthrow;
    AllTime50;
}

// TODO: add scales when cloning, or make a separate type
final playerScales:Map<AttackName, Array<Scale>> = [
    Windthrow => [Power50, Vel50],
    Fireball => [Power50, Vel50]
];

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
    }
}
