package game.data;

import game.data.ActorData;
import game.data.AttackData;

class GameData {
    public static var playerData:PlayerData;

    public function new () {
        playerData = {
            maxHealth: 100,
            speed: 40,
            attack: 40,
            defense: 40,
            dexterity: 40,
            spells: []
        }

        trace(playerData.spells);

        playerData.spells.push(cloneSpell(Fireball));
        playerData.spells.push(cloneSpell(FlameSquare));
    }
}
