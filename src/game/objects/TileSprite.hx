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

    public function new (x:Int, y:Int, index:Int) {
        final pos = translateWorldPos(x, y);
        super(pos.clone(), Assets.images.grid_tiles, new IntVec2(16, 16));

        tileIndex = index;
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
