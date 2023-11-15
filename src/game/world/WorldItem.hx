package game.world;

import core.Types;

class WorldItem {
    public var x:Float;
    public var y:Float;

    public function new (x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }

    public function getPosition ():IntVec2 {
        if (x % 1.0 != 0.0 || y % 1.0 != 0.0) {
            throw 'Not integer, position off.';
        }

        return new IntVec2(Std.int(x), Std.int(y));
    }

    public function getNearestPosition ():IntVec2 {
        return new IntVec2(Math.round(x), Math.round(y));
    }
}
