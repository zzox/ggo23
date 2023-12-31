package game.objects;

import core.Types;
import game.util.Utils;
import kha.Assets;

enum ParticleType {
    Portal;
    LevelUp;
    Blood;
    Steam;
}

typedef ParticleData = {
    var color:Int;
    var anim:String;
}

final particleColors:Map<ParticleType, ParticleData> = [
    Portal => {
        color: 0xfffbf236,
        anim: 'cont'
    },
    LevelUp => {
        color: 0xfffbf236,
        anim: 'explode-up'
    },
    Blood => {
        color: 0xffd95763,
        anim: 'explode-down'
    },
    Steam => {
        color: 0xff9badb7,
        anim: 'explode-up'
    }
];

class ParticleSprite extends WorldItemSprite {
    var pType:ParticleType;
    // var time:Float;
    public var done:Bool = false;

    public function new (pos:Vec2, type:ParticleType) {
        super(translateWorldPos(pos.x, pos.y), Assets.images.particles, new IntVec2(16, 32), color);

        animation.add('cont', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 0.1);
        animation.add('explode-down', [10, 11, 12, 13, 14, 15, 16], 0.05, false);
        animation.add('explode-up', [17, 18, 19, 20, 21, 22, 23], 0.05, false);

        animation.play(particleColors[type].anim);

        // HACK:
        if (particleColors[type].anim == 'explode-down') {
            y += 2;
        }

        animation.onComplete = (anim:String) -> {
            if (anim == 'explode-up' || anim == 'explode-down') {
                done = true;
            }
        }

        this.pType = type;
        this.color = particleColors[type].color;
    }

    override function update (delta:Float) {
        // if (pType != Portal) {
        //     time -= delta;
        //     if (time < 0) {
        //         done = true;
        //     }
        // }

        super.update(delta);
    }
}
