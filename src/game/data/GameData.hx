package game.data;

import game.data.ActorData;
import game.data.AttackData;
import game.data.ScaleData;
import game.util.ShuffleRandom;
import kha.math.Random;
#if is_ng
import Keys;
import io.newgrounds.NG;
import io.newgrounds.crypto.Cipher;

function unlockMedal (medalNum:Int) {
    final medal = NG.core.medals.get(medalNum);
    if (medal != null && !medal.unlocked) {
        medal.sendUnlock();
    }
}
#end

function getMaxExp (level:Int):Int {
    return Std.int(Math.pow(level, 2)) + level * 2 + 20;
}

class GameData {
    public static var playerData:PlayerData;
    public static var random:Random;
    public static var floorNum:Int;
    public static var selectedSpell:Int; // used to store val between levels
    static var shuffleExp:ShuffleRandom<Int>;

    static var initialized:Bool = false;

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
            otherScales: otherScales.copy(),
            experience: 0,
            level: 1,
            maxExperience: getMaxExp(1),
            pointsAvailable: []
        }

        addSpell(attackOptions[0]);
        addSpell(attackOptions[1]);

        shuffleExp = new ShuffleRandom([4, 5, 5, 6, 6, 7, 7, 8], random);

        selectedSpell = 0;
        floorNum = 0;

#if is_ng
        if (!initialized) {
            NG.create(appId);
            NG.createAndCheckSession(appId);
            NG.core.medals.loadList();
            NG.core.scoreBoards.loadList();
            NG.core.setupEncryption(encKey);
            initialized = true;
        }
#end
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

    public static function addSpell (spell:AttackName) {
        playerData.spells.push(cloneSpell(spell));
        playerData.scales.push(playerScales[spell].copy());
    }

    public static function replaceSpell (index:Int, spell:AttackName) {
        playerData.spells[index] = cloneSpell(spell);
        // playerData.scales[index] = playerScales[spell].copy();
        // for now, spells that can be replaced cannot be upgraded.
        playerData.scales[index] = [];
    }

    public static function nextRound () {
        floorNum++;
    }

    public static function finishedFloor () {
#if is_ng
        if (floorNum == 3) unlockMedal(boss1Medal);
        if (floorNum == 7) unlockMedal(boss2Medal);
        if (floorNum == 10) unlockMedal(boss3Medal);
#end
    }
}

final attackOptions:Array<AttackName> = [
    Raincast, Windthrow // use these two always to start?
];
