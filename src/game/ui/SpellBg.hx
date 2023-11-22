package game.ui;

import core.Camera;
import core.Input.MouseButton;
import core.Sprite;
import core.Types;
import core.Util;
import game.ui.Button;
import game.ui.UiText.getText;
import kha.Assets;
import kha.graphics2.Graphics;

// special button. should this move into a parent class?
class SpellBg extends Sprite {
    public var selected:Bool;
    public var number:Sprite;

    var isPressed:Bool = false;
    public var state:ButtonState = Idle;
    var onClick:Void -> Void;

    public function new (num:Int, callback:Void -> Void) {
        super(new Vec2(8 + num * 32, num == 0 ? 156 : 164), Assets.images.spell_bg, new IntVec2(24, 24));

        addChild(number = getText(-16, -16, '${num + 1}', 0xffeec39a));

        selected = num == 0;
        this.onClick = callback;
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
                // if (onHover != null) {
                //     onHover();
                // }

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
        number.setPosition(x + 12, y);
        super.render(g2, cam);
    }
}
