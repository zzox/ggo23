package game.data;

import game.data.ActorData;
import game.data.AttackData;

function getMaxExp (level:Int):Int {
    return Std.int(Math.pow(level, 2)) + level * 2;
}

class GameData {
    public static var playerData:PlayerData;

    public function new () {
        playerData = {
            maxHealth: 100,
            speed: 40,
            attack: 40,
            defense: 40,
            dexterity: 40,
            spells: [],
            experience: 0,
            level: 5,
            maxExperience: getMaxExp(5),
            pointsAvailable: [3]
        }

        playerData.spells.push(cloneSpell(Fireball));
        playerData.spells.push(cloneSpell(FlameSquare));
    }

    public static function addExperience (amount:Int):Bool {
        playerData.experience += amount;

        var leveledUp = false;
        var maxed = false;
        while (!maxed) {
            if (playerData.experience >= playerData.maxExperience) {
                playerData.experience -= playerData.maxExperience;
                playerData.level++;
                playerData.maxExperience = getMaxExp(playerData.level);
                leveledUp = true;
                playerData.pointsAvailable.push(3);
            } else {
                maxed = true;
            }
        }

        return leveledUp;
    }
}
