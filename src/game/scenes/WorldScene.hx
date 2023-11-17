package game.scenes;

import core.Group;
import core.Input;
import core.Scene;
import core.Types;
import game.data.AttackData;
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

    var ratTest:ActorSprite;

    override function create () {
        world = new World(new IntVec2(100, 100), handleAddElement, handleRemoveElement);

        for (outer in world.grid) {
            for (item in outer) {
                if (item.tile != null) {
                    final gridTile = new TileSprite(item.x, item.y, Math.random() < 0.1 ? 1 : 0);
                    tileSprites.push(gridTile);
                }
            }
        }
        gridTiles = new Group(cast tileSprites.copy());
        addSprite(gridTiles);
        sortGroupByY(gridTiles);

        gridObjects = new Group();
        addSprite(gridObjects);

        player = new ActorSprite(world.playerActor);

        for (actor in world.actors) {
            if (actor != world.playerActor) {
                gridObjects.addChild(new ActorSprite(actor));
            }
        }

        gridObjects.addChild(player);
        camera.startFollow(player);
        camera.scale.set(2.0, 2.0);
        // camera.followLerp.set(0.25, 0.25);

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
            final tile = getTileSpriteAt(tilePos.x, tilePos.y);
            if (tile != null) {
                tile.focused = true;
            }

            // highlight tile
            final clicked = game.mouse.justPressed(MouseButton.Left);
            if (clicked && tilePos.tile != null) {
                world.playerActor.queueMove(new IntVec2(tilePos.x, tilePos.y));
            }

            final rightClicked = game.mouse.justPressed(MouseButton.Right);
            if (rightClicked) {
                // TODO: This should be called from the player's Actor object
                // world.addElement(tilePos.x, tilePos.y, Fire);
                world.playerActor.queueAttack(attackData[Fireball], null, new IntVec2(tilePos.x, tilePos.y));
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

        // DEBUG camera; won't work if camera follow is set
        final speedup = game.keys.pressed(KeyCode.Shift) ? 4.0 : 1.0;
        if (game.keys.pressed(KeyCode.Left)) {
            camera.scroll.x -= speedup * 2 / camera.scale.x;
        }

        if (game.keys.pressed(KeyCode.Right)) {
            camera.scroll.x += speedup * 2 / camera.scale.x;
        }

        if (game.keys.pressed(KeyCode.Up)) {
            camera.scroll.y -= speedup * 2 / camera.scale.x;
        }

        if (game.keys.pressed(KeyCode.Down)) {
            camera.scroll.y += speedup * 2 / camera.scale.x;
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

    function getTileSpriteAt (x:Int, y:Int):Null<TileSprite> {
        // ATTN: find a better way than to have linear-time access, especially if
        // this gets used more often.
        for (ts in tileSprites) {
            if (ts.pos.x == x && ts.pos.y == y) {
                return ts;
            }
        }

        return null;

        // return tileSprites[x * world.size.y + y];
    }
}
