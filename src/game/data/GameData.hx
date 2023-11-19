package game.data;

import game.data.ActorData;

class GameData {
    public static var playerData:PlayerData;

    public function new () {
        playerData = {
            maxHealth: 100,
            speed: 99,
            attack: 99,
            defense: 1,
            dexterity: 99
        }
    }
}
