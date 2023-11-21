package game.world;

import core.Types;

enum ElementType {
    Fire;
    Lightning;
    Air;
    Water;
}

class Element extends WorldItem {
    public var active:Bool = true;
    public var type:ElementType;
    public var time:Float; // also used as power
    public var velocity:Vec2;
    public var fromActor:Actor;

    public function new (x:Float, y:Float, type:ElementType, velocity:Vec2, time:Float, fromActor:Actor) {
        super(x, y);
        this.type = type;
        this.time = time;
        this.velocity = velocity;
        this.fromActor = fromActor;
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
