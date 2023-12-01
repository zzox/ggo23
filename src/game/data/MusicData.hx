package game.data;

import core.Sound;
import kha.Assets;
import kha.audio1.AudioChannel;

class MusicData {
    static var noise:AudioChannel;
    static var music:AudioChannel;

    public function new () {
        stopMusic();
        if (noise == null) {
            noise = Sound.stream(Assets.sounds.get('depths_music_noise'), 1.0, true);
        }
    }

    public static function playMusic () {
        stopMusic();
        music = Sound.stream(Assets.sounds.get('depths_music_gameover'), 0.25, true);
    }

    public static function stopMusic () {
        if (music != null) {
            music.stop();
        }
    }
}