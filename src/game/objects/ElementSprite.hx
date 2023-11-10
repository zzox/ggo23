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
        animation.play('fire-large');

        elementState = element;
    }
}
