package game.objects;

import core.Types;
import game.util.Utils;
import game.world.Element;
import kha.Assets;

final elementColors:Map<ElementType, Int> = [
    Fire => 0xffdf7126,
    Lightning => 0xfffbf236,
];

class ElementSprite extends WorldItemSprite {
    public var elementState:Element;

    public function new (element:Element) {
        final pos = translateWorldPos(element.x, element.y);
        final elementColor = elementColors[element.type];
        super(new Vec2(pos.x, pos.y), Assets.images.elements, new IntVec2(16, 32), elementColor);

        animation.add('fire-large', [0, 1], 0.2);
        animation.add('fire-medium', [2, 3], 0.175);
        animation.add('fire-small', [4, 5], 0.15);
        animation.add('fire-tiny', [6, 7], 0.125);
        animation.add('lightning-large', [8, 9], 0.2);
        animation.add('lightning-medium', [10, 11], 0.175);
        animation.add('lightning-small', [12, 13], 0.15);
        animation.add('lightning-tiny', [14, 15], 0.125);

        elementState = element;
    }

    override function update (delta:Float) {
        var animType = 'fire';
        if (elementState.type == Lightning) {
            animType = 'lightning';
        }

        var animSize = 'large';
        if (elementState.time < 0.25) {
            animSize = 'tiny';
        } else if (elementState.time < 0.5) {
            animSize = 'small';
        } else if (elementState.time < 1.0) {
            animSize = 'medium';
        }

        animation.play('${animType}-${animSize}');

        final pos = translateWorldPos(elementState.x, elementState.y);
        setPosition(pos.x, pos.y);
        super.update(delta);
    }
}
