package game.objects;

import core.Camera;
import core.Sprite;
import core.Types;
import kha.Image;
import kha.graphics2.Graphics;

class WorldItemSprite extends Sprite {
    // the offset of y position of where this will actually be drawn
    // NOTE: offset.y deals with the `body` offset from the sprite origin,
    // this is different
    public var yOffset:Int;

    public function new (pos:Vec2, image:Image, size:IntVec2, color:Int, yOffset:Int = 20) {
        super(pos, image, size);

        this.color = color;
        this.yOffset = yOffset;
    }

    override function render (g2:Graphics, cam:Camera) {
        for (c in _children) {
            c.setPosition(x, y - yOffset);
        }

        final oldY = y;
        y -= yOffset;
        super.render(g2, cam);
        y = oldY;
    }
}
