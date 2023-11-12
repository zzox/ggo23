package game.objects;

import core.Camera;
import core.Sprite;
import core.Types;
import game.util.Utils;
import game.world.Actor;
import kha.Assets;
import kha.graphics2.Graphics;

class TileSprite extends Sprite {
    public var focused:Bool = false;
    public var pos:IntVec2;

    public function new (x:Int, y:Int, index:Int) {
        final worldPos = translateWorldPos(x, y);
        super(worldPos.clone(), Assets.images.grid_tiles, new IntVec2(16, 16));

        tileIndex = index;
        pos = new IntVec2(x, y);
    }

    override function render (g2, camera) {
        final index = tileIndex;
        super.render(g2, camera);

        if (focused) {
            tileIndex = 3;
            super.render(g2, camera);
        }

        tileIndex = index;
    }

    public function clean () {
        focused = false;
    }
}
