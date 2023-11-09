package game.scenes;

import core.Group;
import core.Input.MouseButton;
import core.Scene;
import core.Types;
import game.actors.ActorSprite;
import game.objects.TileSprite;
import game.scenes.UiScene;
import game.util.Utils;
import game.world.World;
import kha.input.KeyCode;

class WorldScene extends Scene {
    var world:World;
    var gridTiles:Group;
    var player:ActorSprite;
    var tileSprites:Array<TileSprite> = [];

    var uiScene:UiScene;

    override function create () {
        world = new World(new IntVec2(50, 50));

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

        player = new ActorSprite(world.playerActor);
        addSprite(player);
        camera.startFollow(player);
        camera.followLerp.set(0.25, 0.25);

        uiScene = new UiScene();
        game.addScene(uiScene);
    }

    override function update (delta:Float) {
        for (tile in tileSprites) {
            tile.clean();
        }

        handleCamera();
        handleInput();

        world.update(delta);
        super.update(delta);

        if (game.keys.justPressed(KeyCode.R)) {
            game.switchScene(new WorldScene());
        }
    }

    function handleInput  () {
        final tilePos = getTilePos(world.grid, game.mouse.position.x, game.mouse.position.y);

        if (tilePos != null) {
            // TODO: inline getTileAt method?
            tileSprites[tilePos.x * world.size.y + tilePos.y].focused = true;
        }

        final clicked = game.mouse.justPressed(MouseButton.Left);
        if (tilePos != null) {
            // highlight tile
            if (clicked && !world.playerActor.moving) {
                world.playerActor.move(tilePos.x, tilePos.y);
            }
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
