package game.scenes;

import core.Group;
import core.Input.MouseButton;
import core.Scene;
import core.Sprite;
import core.Types;
import game.scenes.UiScene;
import game.util.Utils;
import game.world.Actor;
import game.world.World;
import kha.Assets;
import kha.input.KeyCode;

class WorldScene extends Scene {
    var world:World;
    var gridTiles:Group;
    var player:PlayerSprite;

    var uiScene:UiScene;

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

        player = new PlayerSprite(world.playerActor);
        addSprite(player);
        camera.startFollow(player);
        camera.followLerp.set(0.25, 0.25);

        uiScene = new UiScene();
        game.addScene(uiScene);
    }

    override function update (delta:Float) {
        handleCamera();

        // diff of 2 here for the tile distance from the top.
        final tilePos = getTilePos(world.grid, game.mouse.position.x, game.mouse.position.y - 2);
        final clicked = game.mouse.justPressed(MouseButton.Left);
        if (tilePos != null) {
            // highlight tile
            if (clicked && !world.playerActor.moving) {
                world.playerActor.move(tilePos.x, tilePos.y);
            }
        }

        world.update(delta);
        super.update(delta);

        if (game.keys.justPressed(KeyCode.R)) {
            game.switchScene(new WorldScene());
        }
    }

    function handleCamera () {
        if (game.keys.justPressed(KeyCode.Equals)) {
            camera.scale.set(2.0, 2.0);
        }

        if (game.keys.justPressed(KeyCode.HyphenMinus)) {
            camera.scale.set(1.0, 1.0);
        }
    }
}

function translateWorldPos (x:Float, y:Float):Vec2 {
    return new Vec2((x * 8) + (y * 8), (y * 4) + (x * -4));
}

function getTilePos (grid:Grid, xPos:Float, yPos:Float) {
    final x = (xPos - 8) / 16;
    final y = (yPos - 4) / 8;
    return getGridItem(grid, Math.round(x - y), Math.round(x + y));
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
        // tileIndex = 4;
        // super.render(g2, camera);
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
        setPosition(Math.round(pos.x), Math.round(pos.y));

        if (actorState.moving) {
            animation.play('walk-down');
        } else {
            animation.play('still-down');
        }

        super.update(delta);
    }

    // is this needed?
    // override function render (g2, cam) {
    //     final px = x;
    //     final py = y;

    //     setPosition(Math.round(x), Math.round(y));
    //     super.render(g2, cam);
    //     setPosition(px, py);
    // }
}
