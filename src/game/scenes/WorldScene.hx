package game.scenes;

import core.Group;
import core.Scene;
import core.Sprite;
import core.Types;
import game.util.Utils;
import game.world.World;
import kha.Assets;
import kha.input.KeyCode;

class WorldScene extends Scene {
    var world:World;
    var gridTiles:Group;

    override function create () {
        world = new World(new IntVec2(100, 100));

        final tileSprites:Array<TileSprite> = [];
        for (outer in world.grid) {
            for (item in outer) {
                final gridTile = new TileSprite(item.x, item.y, Math.random() < 0.1 ? 1 : 0);
                tileSprites.push(gridTile);
            }
        }
        gridTiles = new Group(cast tileSprites.copy());

        // addSprite(new TileSprite(16, 16, 0));
        addSprite(gridTiles);

        sortGroupByY(gridTiles);
    }

    override function update (delta:Float) {
        handleCamera();

        super.update(delta);
    }

    function handleCamera () {
        if (game.keys.pressed(KeyCode.Left)) {
            camera.scroll.x -= 1.0;
        }

        if (game.keys.pressed(KeyCode.Right)) {
            camera.scroll.x += 1.0;
        }

        if (game.keys.pressed(KeyCode.Up)) {
            camera.scroll.y -= 1.0;
        }

        if (game.keys.pressed(KeyCode.Down)) {
            camera.scroll.y += 1.0;
        }
    }
}

function translateWorldPos (x:Float, y:Float):Vec2 {
    return new Vec2((x * 8) + (y * 8), (y * 4) + (x * -4));
}

class TileSprite extends Sprite {
    public function new (x:Int, y:Int, index:Int) {
        final pos = translateWorldPos(x, y);
        super(pos.clone(), Assets.images.grid_tiles, new IntVec2(16, 16));

        tileIndex = index;
    }
}
