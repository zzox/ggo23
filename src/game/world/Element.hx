package game.world;

import core.Types;

enum ElementType {
    Fire;
    Lightning;
    Air;
    Water;
}

class Element extends WorldItem {
    static var curId:Int = 0;

    public var id:Int;

    public var preActive:Bool = true;
    public var active:Bool = false;
    public var type:ElementType;
    public var time:Float; // also used as power
    public var preTime:Float = 0.0;
    public var velocity:Vec2;
    public var fromActor:Actor;

    public function new (x:Float, y:Float, type:ElementType, velocity:Vec2, time:Float, fromActor:Actor, preTime:Float = 0.0) {
        super(x, y);
        this.type = type;
        this.time = time;
        this.velocity = velocity;
        this.fromActor = fromActor;
        this.preTime = preTime;

        id = curId++;
    }

    public function update (delta:Float) {
        if (active) {
            time -= delta;
            // lightning diminishes faster
            if (type == Lightning) {
                time -= delta;
            }

            if (time <= 0.0) {
                deactivate();
            }
        }

        if (preActive) {
            preTime -= delta;
            if (preTime <= 0.0) {
                preActive = false;
                active = true;
            }
        }

        x = x + velocity.x * delta;
        y = y + velocity.y * delta;
    }

    public function deactivate () {
        active = false;
    }
}
