package game.world;

import core.Types;

enum ElementType {
    Fire;
    // Water;
    // Blades;
    // Air;
    // WetBlades;
    // HotBlades;
    // BladeWind;
}

class Element extends WorldItem {
    public var active:Bool = true;
    var type:ElementType;
    public var time:Float;
    public var velocity:Vec2;

    public function new (x:Float, y:Float, type:ElementType, velocity:Vec2) {
        super(x, y);
        this.type = type;
        this.time = 1.0;
        this.velocity = velocity;
    }

    public function update (delta:Float) {
        time -= delta;
        if (time <= 0.0) {
            deactivate();
        }

        x = x + velocity.x * delta;
        y = y + velocity.y * delta;
    }

    public function deactivate () {
        active = false;
    }
}
