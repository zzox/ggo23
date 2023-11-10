package game.world;

enum ElementType {
    Fire;
}

class Element {
    public var x:Int;
    public var y:Int;

    var type:ElementType;
    public var time:Float;

    public function new (x:Int, y:Int, type:ElementType, time:Float) {
        this.type = type;
        this.time = time;
        this.x = x;
        this.y = y;
    }

    public function update (delta:Float) {
        time -= delta;
    }
}
