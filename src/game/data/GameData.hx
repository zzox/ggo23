package game.data;

import game.data.ActorData;
import game.data.AttackData;
import game.data.ScaleData;
import kha.math.Random;

function getMaxExp (level:Int):Int {
    return Std.int(Math.pow(level, 2)) + level * 2;
}

class GameData {
    public static var playerData:PlayerData;
    public static var random:Random;
    public static var floorNum:Int = 0;

    public function new () {
        random = new Random(Math.floor(Math.random() * 65536));

        playerData = {
            maxHealth: 100,
            speed: 40 + random.GetIn(1, 15),
            attack: 40 + random.GetIn(1, 15),
            defense: 40 + random.GetIn(1, 15),
            dexterity: 40 + random.GetIn(1, 15),
            spells: [],
            scales: [],
            experience: 0,
            level: 5,
            maxExperience: getMaxExp(5),
            pointsAvailable: []
        }

        final spellOptions = attackOptions.copy();
        for (_ in 0...2) {
            final spell = spellOptions[Math.floor(random.GetFloat() * spellOptions.length)];
            spellOptions.remove(spell);
            playerData.spells.push(cloneSpell(spell));
            playerData.scales.push(playerScales[spell].copy());
        }
        // playerData.spells.push(cloneSpell(Fireball));
        // playerData.spells.push(cloneSpell(Windthrow));
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
                playerData.pointsAvailable.push(5);
            } else {
                maxed = true;
            }
        }

        return leveledUp;
    }
}

final attackOptions:Array<AttackName> = [
    // Fireball, Windthrow
    // Windthrow, Raincast // use these two always to start?
    Fireball, Raincast
];
