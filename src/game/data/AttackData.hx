package game.data;

import core.Types;
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
    // var shape:Float;
}

enum AttackName {
    Bite;
    Fireball;
    Windthrow;
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
}
];
