package game.data;

import core.Types.Vec2;

typedef ShapeData = {
    var vel:Vec2;
    var time:Float;
}

// always squares for now
typedef Shape = Array<Array<Null<ShapeData>>>;

function noVel (time:Float) {
    return { vel: new Vec2(0, 0), time: time };
}

final square:Shape = [
    [null, noVel(0.25), noVel(0.25), noVel(0.25), null],
    [noVel(0.25), noVel(0.125), noVel(0.125), noVel(0.125), noVel(0.25)],
    [noVel(0.25), noVel(0.125), noVel(0.0), noVel(0.125), noVel(0.25)],
    [noVel(0.25), noVel(0.125), noVel(0.125), noVel(0.125), noVel(0.25)],
    [null, noVel(0.25), noVel(0.25), noVel(0.25), null],
];
