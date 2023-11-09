package game.ui;

import core.BitmapFont;
import core.Sprite;
import core.Types;
import kha.Assets;

function getFont ():ConstructBitmapFont {
    return new ConstructBitmapFont(
        new IntVec2(16, 16),
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,;:?!"\'+-=*%_() ',
        [[3," "],[8,"m"],[7,""],[6,"ABCDEFGHJKLMNOPQRSTUVWXYZabcdefghjknopqstuvwxyz0123456789?+-=*%_"],[5,"r"],[4,"Ii\"()"],[3,"l.,;:!'"]],
        -4
    );
}

function getText (x:Int, y:Int, text:String = ''):Sprite {
    final sprite = new Sprite(new Vec2(x, y), Assets.images.somepx_04);
    sprite.makeBitmapText(text, getFont());
    return sprite;
}
