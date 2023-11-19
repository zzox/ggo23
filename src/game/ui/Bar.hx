package game.ui;

import core.Sprite;
import core.Types;
import core.Util;
import kha.Assets;

typedef BarColor = {
    var min:Float; // 0-1
    var color:Int;
}

// TODO: color changing based on min values. (array of int -> hex tuples?)
class Bar extends Sprite {
    public var value:Float;
    var max:Float;
    var width:Int;
    var height:Int;

    var barColors:Array<BarColor>;
    var barSprite:Sprite;

    public function new (x:Int, y:Int, width:Int, height:Int, barColors:Array<BarColor>, max:Float, ?value:Float) {
        super(new Vec2(x, y), Assets.images.bar_bg);

        if (value == null) {
            value = max;
        }

        makeNineSliceImage(new IntVec2(width + 4, height + 4), new IntVec2(2, 2), new IntVec2(6, 6));

        color = barColors[0].color;
        this.max = max;
        this.width = width;
        this.height = height;
        this.value = value;
        this.barColors = barColors;

        barSprite = new Sprite(new Vec2(x + 2, y + 2));
        addChild(barSprite);
        barSprite.makeRect(color, new IntVec2(calcBarWidth(value, max), height));
    }

    override function update (delta:Float) {
        for (bc in barColors) {
            if (value / max >= bc.min) {
                color = bc.color;
                barSprite.color = color;
            }
        }

        // check if anything has been updated in order to change sizes

        barSprite.makeRect(color, new IntVec2(calcBarWidth(value, max), height));
        super.update(delta);
    }

    inline function calcBarWidth (value:Float, max:Float):Int
        return Math.floor(clamp(value, 0, max) / max * width);
}
