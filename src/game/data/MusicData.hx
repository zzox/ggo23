package game.data;

import core.Sound;
import kha.Assets;
import kha.audio1.AudioChannel;

class MusicData {
    static var noise:AudioChannel;
    static var music:AudioChannel;

    public function new () {
        if (noise == null) {
            noise = Sound.stream(Assets.sounds.get('depths_music_noise'), 0.1, true);
        }
    }

    public function update (delta:Float) {
        // turn music down
    }
}