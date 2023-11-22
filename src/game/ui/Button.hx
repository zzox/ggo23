package game.ui;

import core.Input.MouseButton;
import core.Sprite;
import core.Types;
import core.Util;
import game.ui.UiText;
import kha.Image;

enum ButtonState {
    Idle;
    Hovered;
    Pressed;
    Disabled;
}

// function pointInSprite (point:Vec2, sprite:Sprite):Bool {
//     return pointInRect(point.x, point.y, sprite.x, sprite.y, sprite.size.x, sprite.size.y);
// }

class Button extends Sprite {
    var onClick:Void -> Void;
    var onHover:Void -> Void;
    var isPressed:Bool = false;
    public var state:ButtonState = Idle;

    var textSprite:Sprite;

    // different from size
    public var buttonSize:IntVec2;

    public function new (
        pos:Vec2,
        sheet:Image,
        size:IntVec2,
        buttonSize:IntVec2,
        textColor:Int,
        textString:String,
        ?onClick:Void -> Void,
        ?onHover:Void -> Void
    ) {
        super(pos, sheet, size);
        this.onClick = onClick;
        this.onHover = onHover;
        this.buttonSize = buttonSize;

        makeNineSliceImage(buttonSize.clone(), new IntVec2(2, 2), new IntVec2(6, 6));

        textSprite = getText(Math.round(pos.clone().x), Math.round(pos.clone().y), textString);
        textSprite.color = textColor;
        textSprite.setBitmapText(textString);
        // TODO: set on movement
        textSprite.setPosition(
            pos.x + buttonSize.x / 2 - textSprite.textWidth / 2,
            pos.y + buttonSize.y / 2 - 4 // 4 for now
        );
        addChild(textSprite);
    }

    override function update (delta:Float) {
        super.update(delta);

        if (scene != null && state != Disabled) {
            state = Idle;
            if (pointInRect(
                scene.game.mouse.screenPos.x / 2,
                scene.game.mouse.screenPos.y / 2,
                x,
                y,
                buttonSize.x,
                buttonSize.y
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

        setFromState(state);
    }

    // This was a special method to force a certain state, requires calling every frame
    // _after_ update has run.
    function setFromState (buttonState:ButtonState) {
        tileIndex = switch (buttonState) {
            case Idle: 0;
            case Hovered: 1;
            case Pressed: 2;
            case Disabled: 3;
        }
    }
}
