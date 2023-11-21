package game.objects;

import core.Camera;
import core.Sprite;
import core.Types;
import game.util.Utils;
import game.world.Actor;
import kha.Assets;
import kha.graphics2.Graphics;

class TileSprite extends Sprite {
    public var stepped:Bool = false;
    public var focused:Bool = false;
    public var isPortal:Bool = false;
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

        if (isPortal) {
            tileIndex = 5;
            super.render(g2, camera);
        }

        if (stepped) {
            tileIndex = 4;
            alpha = 0.33;
            super.render(g2, camera);
            alpha = 1.0;
        }

        if (focused) {
            tileIndex = 3;
            super.render(g2, camera);
        }

        tileIndex = index;
    }

    public function clean () {
        focused = false;
        stepped = false;
    }
}
