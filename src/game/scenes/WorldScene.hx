package game.scenes;

import core.Group;
import core.Scene;
import core.Sprite;
import core.Types;
import game.util.Utils;
import game.world.Actor;
import game.world.World;
import kha.Assets;
import kha.input.KeyCode;

class WorldScene extends Scene {
    var world:World;
    var gridTiles:Group;
    var player:PlayerSprite;

    override function create () {
        world = new World(new IntVec2(50, 50));

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

        world.playerActor.move(30, 12);

        player = new PlayerSprite(world.playerActor);
        addSprite(player);
        camera.startFollow(player);
    }

    override function update (delta:Float) {
        handleCamera();

        world.update(delta);
        super.update(delta);

        if (game.keys.justPressed(KeyCode.R)) {
            game.switchScene(new WorldScene());
        }
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

    override function render (g2, camera) {
        final index = tileIndex;
        super.render(g2, camera);
        tileIndex = 4;
        super.render(g2, camera);
        tileIndex = index;
    }
}

class PlayerSprite extends Sprite {
    var actorState:Actor;

    public function new (actor:Actor) {
        final pos = translateWorldPos(actor.x, actor.y);
        super(new Vec2(pos.x, pos.y), Assets.images.wizard_test, new IntVec2(16, 32));
        this.actorState = actor;

        animation.add('still-down', [0]);
        animation.add('walk-down', [0, 1, 2], 0.1);
        animation.add('still-up', [0]);
        animation.add('walk-up', [0, 1, 2], 0.1);
    }

    override function update (delta:Float) {
        final pos = translateWorldPos(actorState.x, actorState.y);

        setPosition(pos.x, pos.y);

        if (actorState.moving) {
            animation.play('walk-down');
        } else {
            animation.play('still-down');
        }

        super.update(delta);
    }
}
