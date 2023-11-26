package game.ui;

import core.Camera;
import core.Input.MouseButton;
import core.Sprite;
import core.Types;
import core.Util;
import game.ui.Button;
import game.ui.UiText;
import kha.Assets;
import kha.graphics2.Graphics;

// special button. should this move into a parent class?
class SpellBg extends Sprite {
    public var selected:Bool;
    public var number:Sprite;
    public var imageSprite:Sprite;

    var isPressed:Bool = false;
    public var state:ButtonState = Idle;
    var onClick:Void -> Void;
    var onHover:Void -> Void;

    public function new (num:Int, imageIndex:Int, callback:Void -> Void, onHover:Void -> Void) {
        super(new Vec2(8 + num * 40, num == 0 ? 156 : 164), Assets.images.spell_bg, new IntVec2(32, 32));

        addChild(number = getText(-16, -16, '${num + 1}', 0xffeec39a));

        imageSprite = new Sprite(new Vec2(-32, -32), Assets.images.spell_image, new IntVec2(32, 32));
        imageSprite.tileIndex = imageIndex;
        addChild(imageSprite);

        selected = num == 0;
        this.onClick = callback;
        this.onHover = onHover;
    }

    override function update (delta:Float) {
        y = fuzzyLerp(selected ? 156 : 164, y, 0.25, 0.1);

        if (state != Disabled) {
            state = Idle;
            // dividing by 2 because of the scale.
            if (pointInRect(
                scene.game.mouse.screenPos.x / 2,
                scene.game.mouse.screenPos.y / 2,
                x,
                y,
                size.x,
                size.y
            )) {
                state = Hovered;
                if (onHover != null) {
                    onHover();
                }

                if (isPressed) {
                    if (scene.game.mouse.justReleased(MouseButton.Left)) {
                        if (onClick != null) {
                            onClick();
                        }
                    }
                }

                if (scene.game.mouse.justPressed(MouseButton.Left)) {
                    isPressed = true;
                }
            }

            // here so that the button stays pressed down looking even when
            // moving off of the sprite
            if (isPressed) {
                state = Pressed;
            }
        }

        if (!scene.game.mouse.pressed(MouseButton.Left)) {
            isPressed = false;
        }

        super.update(delta);
    }

    // draw number and image relative to y position
    override function render (g2:Graphics, cam:Camera) {
        number.setPosition(x + 14, y + 1);
        imageSprite.setPosition(x + 2, y + 8);
        super.render(g2, cam);
    }
}
