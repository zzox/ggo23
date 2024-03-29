package game.scenes;

import core.Group;
import core.Input;
import core.Scene;
import core.Sound;
import core.Timers;
import core.Types;
import game.data.GameData;
import game.data.MusicData;
import game.data.RoomData;
import game.objects.ActorSprite;
import game.objects.ElementSprite;
import game.objects.ParticleSprite;
import game.objects.TileSprite;
import game.scenes.UiScene;
import game.ui.Numbers;
import game.util.Utils;
import game.world.Actor;
import game.world.Element;
import game.world.Grid;
import game.world.World;
import kha.Assets;
import kha.input.KeyCode;

class WorldScene extends Scene {
    var world:World;
    var gridTiles:Group;
    var gridObjects:Group;
    var player:ActorSprite;
    var tileSprites:Array<Null<TileSprite>> = [];
    var ditheredTiles:Array<TileSprite> = [];
    var elementSprites:Array<ElementSprite> = [];
    var particleSprites:Array<ParticleSprite> = [];
    var damageNumbers:Group;
    var roundOver:Bool = false;

    var uiScene:UiScene;

    override function create () {
        MusicData.stopMusic();

        world = new World(handleWorldSignal, handleAddElement, handleRemoveElement);
        world.isPaused = true;

        for (outer in world.grid) {
            for (item in outer) {
                if (item.tile != null) {
                    final gridTile = new TileSprite(item.x, item.y, Math.random() < 0.1 ? 1 : 0);
                    tileSprites.push(gridTile);
                    if (!item.seen) {
                        gridTile.visible = false;
                    }
                } else {
                    tileSprites.push(null);
                }
            }
        }
        gridTiles = new Group(cast tileSprites.filter((i) -> i != null).copy());
        addSprite(gridTiles);
        sortGroupByY(gridTiles);

        gridObjects = new Group();
        addSprite(gridObjects);

        damageNumbers = new Group();
        addSprite(damageNumbers);

        player = new ActorSprite(world.playerActor);
        world.playerActor.updateListeners.push(handleActorUpdate);

        getTileSpriteAt(world.portalPos.x, world.portalPos.y).isPortal = true;
        if (!world.isBossLevel) {
            addExitParticle();
        }

        for (actor in world.actors) {
            actor.updateListeners.push(handleActorUpdate);
            if (actor != world.playerActor) {
                gridObjects.addChild(new ActorSprite(actor));
            }
        }

        for (_ in 0...20) {
            damageNumbers.addChild(new Numbers());
        }

        gridObjects.addChild(player);
        camera.startFollow(player, new IntVec2(8, 2), new Vec2(0.5, 0.1));
        camera.scroll.set(player.x - 320, player.y - 180);
        camera.scale.set(2.0, 2.0);
        // camera.scroll.y -= 180;

        uiScene = new UiScene();
        game.addScene(uiScene);

        timers.addTimer(new Timer(1.0, () -> {
            world.isPaused = false;
        }));
    }

    override function update (delta:Float) {
        if (roundOver) {
            camera.scroll.y--;
        }

        for (tile in tileSprites) {
            if (tile != null) {
                tile.clean();
            }
        }

        if (player.actorState != null) {
            uiScene.healthNum = player.actorState.health;
            uiScene.recoveryNum = player.actorState.currentAttack != null ?
                Math.floor(player.actorState.currentAttack.elapsed / player.actorState.currentAttack.time * 100)
                : 100;
            uiScene.experienceNum = GameData.playerData.experience;
            uiScene.experienceMaxNum = GameData.playerData.maxExperience;

            if (player.actorState.state == Moving && player.actorState.currentPath != null) {
                for (tile in player.actorState.currentPath) {
                    getTileSpriteAt(tile.x, tile.y).stepped = true;
                }

                final pos = player.actorState.currentMove.to;
                getTileSpriteAt(pos.x, pos.y).stepped = true;
            }

            if (player.actorState.currentAttack != null) {
                final ts = getTileSpriteAt(
                    Math.round(player.actorState.currentAttack.targetPos.x),
                    Math.round(player.actorState.currentAttack.targetPos.y)
                );

                if (ts != null) {
                    ts.isTarget = true;
                }
            }
        } else {
            uiScene.healthNum = 0;
        }
        uiScene.forceUpdate(delta);

        handleCamera();
        handleInput();

        world.update(delta);
        super.update(delta);

        handleRemoveParticles();

        sortGroupByY(gridObjects);

        // if (game.keys.justPressed(KeyCode.R)) {
        //     game.switchScene(new WorldScene());
        // }
    }

    function handleWorldSignal (signalType:SignalType, ?signalOptions:SignalOptions) {
        if (signalType == PlayerPortal) {
            player.tweenOut();
            timers.addTimer(new Timer(1.0, () -> {
                roundOver = true;
                uiScene.setupScales();
            }));
            camera.stopFollow();
            Sound.play(Assets.sounds.depths_sfx_portal, 0.5);
        } else if (signalType == PlayerStep) {
            for (dt in ditheredTiles) {
                dt.isDithered = false;
            }
            if (tileSprites.length > 0) {
                ditheredTiles = [];
                for (tile in signalOptions.tiles) {
                    final ts = getTileSpriteAt(tile.x, tile.y);
                    ts.visible = true;
                    ts.isDithered = true;
                    ditheredTiles.push(ts);
                }
            }
            Sound.play(Assets.sounds.depths_sfx_step, 0.25);
        } else if (signalType == PlayerDead) {
            for (c in gridObjects._children) {
                if (c != player) {
                    c.destroy();
                }
            }
            for (ts in tileSprites) {
                if (ts != null) ts.destroy();
            }
            uiScene.gameOver(false);
        } else if (signalType == BossDead) {
            addExitParticle();
        } else if (signalType == SteamParticle) {
            handleAddParticle(signalOptions.pos.clone(), Steam);
            Sound.play(Assets.sounds.depths_sfx_rain, 0.5);
        } else if (signalType == WindDeflect) {
            Sound.play(Assets.sounds.depths_sfx_wind, 0.25);
        }
    }

    function handleActorUpdate (updateType:UpdateType, ?updateOptions:UpdateOptions) {
        if (updateType == Damage && updateOptions.amount != 0) {
            final num = damageNumbers.getNext();
            final worldPos = translateWorldPos(updateOptions.pos.x, updateOptions.pos.y);
            num.setPosition(worldPos.x + 4, worldPos.y - 18);
            num.text = updateOptions.amount + '';
            num.color = 0xffd95763;
            num.start();

            handleAddParticle(updateOptions.pos.clone(), Blood);
            Sound.play(Assets.sounds.depths_sfx_hurt, 0.5);
        } else if (updateType == Experience) {
            final num = damageNumbers.getNext();
            final worldPos = translateWorldPos(updateOptions.pos.x, updateOptions.pos.y);
            num.setPosition(worldPos.x + 4, worldPos.y - 18);
            num.text = updateOptions.amount + '';
            num.color = 0xfffbf236;
            num.start();
        } else if (updateType == TooFar) {
            uiScene.tooFar();
        } else if (updateType == AttackDone) {
            if (updateOptions.type == Bite) {
                Sound.play(Assets.sounds.depths_sfx_melee, 0.5);
            } else if (updateOptions.type == Fireball) {
                Sound.play(Assets.sounds.depths_sfx_flame1, 0.5);
            } else if (updateOptions.type == Windthrow) {
                Sound.play(Assets.sounds.depths_sfx_wind, 0.5);
            } else if (updateOptions.type == Raincast) {
                Sound.play(Assets.sounds.depths_sfx_rain, 0.5);
            } else if (updateOptions.type == Castlight) {
                Sound.play(Assets.sounds.depths_sfx_lightning, 0.8);
            } else if (updateOptions.type == Firestorm || updateOptions.type == DragonFirestorm) {
                Sound.play(Assets.sounds.depths_sfx_flame2, 0.5);
            } else if (updateOptions.type == Windstorm) {
                Sound.play(Assets.sounds.depths_sfx_wind2, 0.5);
            } else if (updateOptions.type == Rainstorm || updateOptions.type == BFRainstorm) {
                Sound.play(Assets.sounds.depths_sfx_rain2, 0.5);
            } else if (updateOptions.type == Lightstorm) {
                Sound.play(Assets.sounds.depths_sfx_lightning2, 0.8);
            }
        } else if (updateType == PreAttack) {
            Sound.play(Assets.sounds.depths_sfx_preattack, 0.1);
        }
    }

    function handleInput  () {
        // // ATTN: remove these
        // if (game.keys.justPressed(KeyCode.P)) {
        //     world.isPaused = !world.isPaused;
        // }

        // if (game.keys.justPressed(KeyCode.B)) {
        //     world.playerActor.x = world.portalPos.x;
        //     world.playerActor.y = world.portalPos.y;
        //     world.playerActor.currentMove = {
        //         from: new IntVec2(0, 0),
        //         to: new IntVec2(world.portalPos.x, world.portalPos.y),
        //         elapsed: 1.0,
        //         time: 1.0
        //     };
        //     world.playerActor.currentPath = [];
        //     world.playerActor.state = Moving;
        // }

        // if (game.keys.justPressed(KeyCode.L)) {
        //     GameData.addExperience(200);
        // }

        // ATTN: we are checking the mouse buttons here on release, in order to
        // be in sync with the uiScene's button release.
        // Some potential fixes may be not triggering on longer holds with mouse movement.
        final tilePos = getTilePos(world.grid, game.mouse.position.x, game.mouse.position.y - 2);
        if (tilePos != null && !uiScene.buttonClicked) {
            final tile = getTileSpriteAt(tilePos.x, tilePos.y);
            if (tile != null) {
                tile.focused = true;
            }

            final clicked = game.mouse.justReleased(MouseButton.Left);
            final rightClicked = game.mouse.justReleased(MouseButton.Right) || (clicked && game.keys.pressed(KeyCode.Control));
            if (rightClicked) {
                world.playerActor.queueAttack(
                    GameData.playerData.spells[uiScene.selectedSpell],
                    null,
                    new IntVec2(tilePos.x, tilePos.y)
                );
            }

            if (clicked && !rightClicked) {
                var p = new IntVec2(tilePos.x, tilePos.y);

                // check the 4 tiles around the tile for a good tile,
                // ugly way to prevent a misclick or assist a near-click
                if (tilePos.tile == null) {
                    final adjTiles = get4AdjacentItems(world.grid, tilePos.x, tilePos.y);
                    for (at in adjTiles) {
                        if (at.tile != null && at.seen) {
                            p.set(at.x, at.y);
                            break;
                        }
                    }
                }

                final gi = getGridItem(world.grid, p.x, p.y);
                if (gi.tile != null && gi.seen) {
                    world.playerActor.queueMove(new IntVec2(p.x, p.y));
                }
            }
        }

        // move with keys if we have no queued move already and we're either
        // in wait state or almost between moves. not the best but it works
        if (
            world.playerActor.queuedMove == null && (
                world.playerActor.state == Wait ||
                (
                    world.playerActor.state == Moving &&
                    world.playerActor.currentMove.elapsed / world.playerActor.currentMove.time > 0.90
                )
        )) {
            final pos = world.playerActor.getLinkedPosition();
            final upPressed = game.keys.anyPressed([KeyCode.W, KeyCode.Up]);
            final downPressed = game.keys.anyPressed([KeyCode.S, KeyCode.Down]);
            final leftPressed = game.keys.anyPressed([KeyCode.A, KeyCode.Left]);
            final rightPressed = game.keys.anyPressed([KeyCode.D, KeyCode.Right]);

            var selectedTile = null;
            if (upPressed && leftPressed) {
                selectedTile = new IntVec2(pos.x, pos.y - 1);
            } else if (downPressed && rightPressed) {
                selectedTile = new IntVec2(pos.x, pos.y + 1);
            } else if (upPressed && rightPressed) {
                selectedTile = new IntVec2(pos.x + 1, pos.y);
            } else if (downPressed && leftPressed) {
                selectedTile = new IntVec2(pos.x - 1, pos.y);
            } else if (upPressed) {
                selectedTile = new IntVec2(pos.x + 1, pos.y - 1);
            } else if (downPressed) {
                selectedTile = new IntVec2(pos.x - 1, pos.y + 1);
            } else if (leftPressed) {
                selectedTile = new IntVec2(pos.x - 1, pos.y - 1);
            } else if (rightPressed) {
                selectedTile = new IntVec2(pos.x + 1, pos.y + 1);
            }

            if (
                selectedTile != null &&
                getGridItem(world.grid, selectedTile.x, selectedTile.y) != null &&
                getGridItem(world.grid, selectedTile.x, selectedTile.y).tile != null
            ) {
                world.playerActor.queueMove(selectedTile);
            }
        }
    }

    function handleCamera () {
        // TODO: remove these?
        // if (game.keys.justPressed(KeyCode.Equals)) {
        //     camera.scale.set(2.0, 2.0);
        // }

        // if (game.keys.justPressed(KeyCode.HyphenMinus)) {
        //     camera.scale.set(1.0, 1.0);
        // }

        // // DEBUG camera; won't work if camera follow is set
        // final speedup = game.keys.pressed(KeyCode.Shift) ? 4.0 : 1.0;
        // if (game.keys.pressed(KeyCode.Left)) {
        //     camera.scroll.x -= speedup * 2 / camera.scale.x;
        // }

        // if (game.keys.pressed(KeyCode.Right)) {
        //     camera.scroll.x += speedup * 2 / camera.scale.x;
        // }

        // if (game.keys.pressed(KeyCode.Up)) {
        //     camera.scroll.y -= speedup * 2 / camera.scale.x;
        // }

        // if (game.keys.pressed(KeyCode.Down)) {
        //     camera.scroll.y += speedup * 2 / camera.scale.x;
        // }
    }

    function addExitParticle () {
        handleAddParticle(new Vec2(world.portalPos.x, world.portalPos.y), Portal);
    }

    function handleAddElement (element:Element) {
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

    function handleAddParticle (pos:Vec2, type:ParticleType) {
        final particleSprite = new ParticleSprite(pos.clone(), type);
        particleSprites.push(particleSprite);
        gridObjects.addChild(particleSprite);
    }

    function handleRemoveParticles () {
        for (p in particleSprites) {
            if (p.done) {
                gridObjects.removeChild(p);
                particleSprites.remove(p);
                p.destroy();
            }
        }
    }

    function getTileSpriteAt (x:Int, y:Int):Null<TileSprite> {
        return tileSprites[x * world.size.y + y];
    }
}
