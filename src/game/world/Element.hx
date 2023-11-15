package game.world;

enum ElementType {
    Fire;
    // Water;
    // Blades;
    // Air;
}

class Element extends WorldItem {
    var type:ElementType;
    public var time:Float;
    // public var velocity:Vec2;

    public function new (x:Float, y:Float, type:ElementType, time:Float) {
        super(x, y);
        this.type = type;
        this.time = time;
    }

    public function update (delta:Float) {
        time -= delta;
    }
}
