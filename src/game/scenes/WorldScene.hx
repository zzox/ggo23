package game.scenes;

import core.Group;
import core.Input;
import core.Scene;
import core.Types;
import game.objects.ActorSprite;
import game.objects.ElementSprite;
import game.objects.TileSprite;
import game.scenes.UiScene;
import game.util.Utils;
import game.world.Element;
import game.world.World;
import kha.input.KeyCode;

class WorldScene extends Scene {
    var world:World;
    var gridTiles:Group;
    var gridObjects:Group;
    var player:ActorSprite;
    var tileSprites:Array<TileSprite> = [];
    var elementSprites:Array<ElementSprite> = [];

    var uiScene:UiScene;

    override function create () {
        world = new World(new IntVec2(50, 50), handleAddElement, handleRemoveElement);

        for (outer in world.grid) {
            for (item in outer) {
                final gridTile = new TileSprite(item.x, item.y, Math.random() < 0.1 ? 1 : 0);
                tileSprites.push(gridTile);
            }
        }
        gridTiles = new Group(cast tileSprites.copy());
        addSprite(gridTiles);
        sortGroupByY(gridTiles);

        gridObjects = new Group();
        addSprite(gridObjects);

        player = new ActorSprite(world.playerActor);
        gridObjects.addChild(player);
        camera.startFollow(player);
        camera.followLerp.set(0.1, 0.1);

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

        sortGroupByY(gridObjects);

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

        if (tilePos != null) {
            // highlight tile
            final clicked = game.mouse.justPressed(MouseButton.Left);
            if (clicked && !world.playerActor.moving) {
                world.playerActor.move(tilePos.x, tilePos.y);
            }

            final rightClicked = game.mouse.justPressed(MouseButton.Right);
            if (rightClicked) {
                // TODO: This should be called from the player's Actor object
                world.addElement(tilePos.x, tilePos.y, Fire);
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

    function handleAddElement (element:Element) {
        trace('a', element);
        // TODO: use pool for these.
        final elementSprite = new ElementSprite(element);
        elementSprites.push(elementSprite);
        gridObjects.addChild(elementSprite);
    }

    function handleRemoveElement (element:Element) {
        trace('r', element);
        for (e in elementSprites) {
            if (e.elementState == element) {
                gridObjects.removeChild(e);
                elementSprites.remove(e);
                e.elementState = null;
                e.destroy();
                return;
            }
        }
    }
}
