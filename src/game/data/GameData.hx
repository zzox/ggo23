package game.data;

import game.data.ActorData;

class GameData {
    public static var playerData:PlayerData;

    public function new () {
        playerData = {
            maxHealth: 100,
            speed: 50,
            attack: 50,
            defense: 50,
            dexterity: 50
        }
    }
}
