package game.data;

import core.Types.Vec2;

typedef ShapeData = {
    var vel:Vec2;
    var time:Float;
}

// always squares for now
typedef Shape = Array<Array<Null<ShapeData>>>;

function noVel (time:Float):ShapeData {
    return { vel: new Vec2(0, 0), time: time };
}

// warning: mutable
final single:Shape = [[noVel(0.0)]];

final bigX:Shape = [
    [noVel(0.25), null, null, null, noVel(0.25)],
    [null, noVel(0.125), null, noVel(0.125), null],
    [null, null, noVel(0.0), null, null],
    [null, noVel(0.125), null, noVel(0.125), null],
    [noVel(0.25), null, null, null, noVel(0.25)],
];

final bigSquare:Shape = [
    [null, noVel(0.25), noVel(0.25), noVel(0.25), null],
    [noVel(0.25), noVel(0.125), noVel(0.125), noVel(0.125), noVel(0.25)],
    [noVel(0.25), noVel(0.125), noVel(0.0), noVel(0.125), noVel(0.25)],
    [noVel(0.25), noVel(0.125), noVel(0.125), noVel(0.125), noVel(0.25)],
    [null, noVel(0.25), noVel(0.25), noVel(0.25), null],
];

final waterFall:Shape = [
    [noVel(0.0), noVel(0.125), noVel(0.25), noVel(0.375), noVel(0.5)],
    [noVel(0.125), noVel(0.25), noVel(0.375), noVel(0.5), noVel(0.625)],
    [noVel(0.25), noVel(0.375), noVel(0.5), noVel(0.625), noVel(0.75)],
    [noVel(0.375), noVel(0.5), noVel(0.625), noVel(0.75), noVel(0.875)],
    [noVel(0.5), noVel(0.625), noVel(0.75), noVel(0.875), noVel(1.0)],
];

final movingBox:Shape = [
    [{ vel: new Vec2(-3, -3), time: 0.0 }, { vel: new Vec2(0, -5), time: 0.0 }, { vel: new Vec2(3, -3), time: 0.0 }],
    [{ vel: new Vec2(-5, 0), time: 0.0 }, { vel: new Vec2(0, 0), time: 0.0 }, { vel: new Vec2(5, 0), time: 0.0 }],
    [{ vel: new Vec2(-3, 3), time: 0.0 }, { vel: new Vec2(0, 5), time: 0.0 }, { vel: new Vec2(3, 3), time: 0.0 }]
];
