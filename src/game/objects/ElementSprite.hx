package game.objects;

import core.Types;
import game.util.Utils;
import game.world.Element;
import kha.Assets;

class ElementSprite extends WorldItemSprite {
    public var elementState:Element;

    public function new (element:Element) {
        final pos = translateWorldPos(element.x, element.y);
        super(new Vec2(pos.x, pos.y), Assets.images.elements, new IntVec2(16, 32), 0xffdf7126);
        
        animation.add('fire-large', [0, 1], 0.2);
        animation.add('fire-medium', [2, 3], 0.175);
        animation.add('fire-small', [4, 5], 0.15);
        animation.add('fire-tiny', [6, 7], 0.125);
        animation.play('fire-large');

        elementState = element;
    }

    override function update (delta:Float) {
        if (elementState.time > 1.0) {
            animation.play('fire-large');
        } else if (elementState.time > 0.5) {
            animation.play('fire-medium');
        } else if (elementState.time > 0.25) {
            animation.play('fire-small');
        } else {
            animation.play('fire-tiny');
        }

        final pos = translateWorldPos(elementState.x, elementState.y);
        setPosition(pos.x, pos.y);
        super.update(delta);
    }
}
