package game.data;

import game.data.ActorData;
import game.data.AttackData;
import game.data.ScaleData;
import game.util.ShuffleRandom;
import kha.math.Random;

function getMaxExp (level:Int):Int {
    return Std.int(Math.pow(level, 2)) + level * 2;
}

class GameData {
    public static var playerData:PlayerData;
    public static var random:Random;
    public static var floorNum:Int = 0;
    static var shuffleExp:ShuffleRandom<Int>;

    public function new () {
        random = new Random(Math.floor(Math.random() * 65536));

        final shufflePts = new ShuffleRandom([7, 8, 9, 12], random);

        playerData = {
            maxHealth: 100,
            speed: 40 + shufflePts.getNext(),
            attack: 40 + shufflePts.getNext(),
            defense: 40 + shufflePts.getNext(),
            dexterity: 40 + shufflePts.getNext(),
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
            addSpell(spell);
        }

        shuffleExp = new ShuffleRandom([4, 5, 5, 6, 6, 7, 7, 8], random);
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
                playerData.pointsAvailable.push(shuffleExp.getNext());
            } else {
                maxed = true;
            }
        }

        return leveledUp;
    }

    function addSpell (spell:AttackName) {
        playerData.spells.push(cloneSpell(spell));
        playerData.scales.push(playerScales[spell].copy());
    }
}

final attackOptions:Array<AttackName> = [
    // Fireball, Windthrow
    // Windthrow, Raincast // use these two always to start?
    Fireball, Raincast
];
