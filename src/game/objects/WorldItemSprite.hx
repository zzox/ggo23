package game.objects;

import core.Camera;
import core.Sprite;
import core.Types;
import kha.Image;
import kha.graphics2.Graphics;

final dirDiffs = [new IntVec2(1, 0), new IntVec2(-1, 0)];
// final dirDiffs = [new IntVec2(1, 0), new IntVec2(-1, 0), new IntVec2(0, 1), new IntVec2(0, -1)];

class WorldItemSprite extends Sprite {
    static inline final Y_OFFSET:Int = 26;

    public function new (pos:Vec2, image:Image, size:IntVec2, color:Int) {
        super(pos, image, size);

        this.color = color;
    }

    override function render (g2:Graphics, cam:Camera) {
        // for (c in _children) {
        //     c.setPosition(x, y - yOffset);
        // }

        final oldY = y;
        final oldX = x;
        final oldColor = color;
        final newY = y - Y_OFFSET;

        for (diff in dirDiffs) {
            setPosition(oldX + diff.x, newY + diff.y);
            color = 0xff000000;
            super.render(g2, cam);
        }

        x = oldX;
        y = newY;
        color = oldColor;
        super.render(g2, cam);
        y = oldY;
    }
}
