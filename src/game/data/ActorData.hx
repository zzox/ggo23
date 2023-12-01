package game.data;

import core.Types;
import game.data.AttackData;
import game.data.ScaleData;
import game.world.Element.ElementType;

enum ActorType {
    PlayerActor;
    Rat;
    BigRat;
    Snake;
    Plant;
    Moth;
    LightningMan;
    Unicorn;
    Spitter;
    Cobra;
    Butterfly;
    Dragon;
}

enum Attitude {
    Aggro;
    Nonchalant;
}

typedef ManageData = {
    var approachDist:Float;
    var retreatDist:Float;
    var attackDist:Float;
    var decideTime:Float;
    var attack:AttackName;
    var attitude:Attitude;
}

typedef Resistance = {
    var type:ElementType;
    var amount:Float;
}

// Data for visuals _and_ state
typedef ActorData = {
    var color:Int;
    var animIndex:Int;

    var meleeDamage:Int;
    var speed:Int;
    var health:Int;

    var ?manageData:ManageData;
    var experience:Int;
    var resistances:Array<Resistance>;

    // ?generate elements ???
}

typedef PlayerData = {
    var maxHealth:Int;
    var speed:Int;
    var attack:Int;
    var defense:Int;
    var dexterity:Int;
    var spells:Array<AttackData>;
    var scales:Array<Array<Scale>>;
    var otherScales:Array<Scale>;

    var level:Int;
    var experience:Int;
    var maxExperience:Int;
    var pointsAvailable:Array<Int>;
    // var health:Int;
}

final actorData:Map<ActorType, ActorData> = [
PlayerActor => {
    meleeDamage: 0,
    health: 0,
    speed: 55,
    experience: 66,
    color: 0xff5b6ee1,
    animIndex: 0,
    resistances: [],
},
Rat => {
    meleeDamage: 5,
    health: 15,
    speed: 40,
    experience: 3,
    color: 0xff9badb7,
    animIndex: 6,
    resistances: [],
    manageData: {
        retreatDist: 10,
        attackDist: Math.sqrt(2),
        approachDist: 0,
        decideTime: 0.5,
        attack: Bite,
        attitude: Aggro
    }
},
BigRat => {
    meleeDamage: 8,
    health: 25,
    speed: 25,
    experience: 10,
    color: 0xff847e87,
    animIndex: 12,
    resistances: [],
    manageData: {
        retreatDist: 0,
        attackDist: Math.sqrt(2),
        approachDist: 10,
        decideTime: 1.0,
        attack: Bite,
        attitude: Aggro
    }
},
Snake => {
    meleeDamage: 12,
    health: 12,
    speed: 35,
    experience: 10,
    color: 0xff6abe30,
    animIndex: 18,
    resistances: [],
    manageData: {
        retreatDist: 0,
        attackDist: Math.sqrt(2),
        approachDist: 12,
        decideTime: 0.5,
        attack: Bite,
        attitude: Aggro
    }
},
Cobra => {
    meleeDamage: 18,
    health: 24,
    speed: 50,
    experience: 10,
    color: 0xffac3232,
    animIndex: 24,
    resistances: [],
    manageData: {
        retreatDist: 0,
        attackDist: Math.sqrt(2),
        approachDist: 18,
        decideTime: 0.5,
        attack: Bite,
        attitude: Aggro
    }
},
Plant => {
    meleeDamage: 17,
    health: 24,
    speed: 25,
    experience: 15,
    color: 0xff37946e,
    resistances: [{ type: Fire, amount: 2.0 }, { type: Water, amount: 0.66 }],
    animIndex: 30,
    manageData: {
        retreatDist: 0,
        attackDist: Math.sqrt(2),
        approachDist: 25,
        decideTime: 0.1,
        attack: Bite,
        attitude: Aggro
    }
},
Moth => {
    meleeDamage: 0,
    health: 10,
    speed: 50,
    experience: 20,
    color: 0xff9badb7,
    animIndex: 54,
    resistances: [{ type: Fire, amount: 1.5 }, { type: Air, amount: 0.0 }, { type: Lightning, amount: 0.0 }],
    manageData: {
        retreatDist: 5,
        attackDist: 10,
        approachDist: 12,
        decideTime: 0.25,
        attack: Windthrow,
        attitude: Aggro
    }
},
LightningMan => {
    meleeDamage: 0,
    health: 50,
    speed: 20,
    experience: 40,
    color: 0xffcbdbfc,
    animIndex: 42,
    resistances: [{ type: Lightning, amount: 0.0 }],
    manageData: {
        retreatDist: 0,
        attackDist: 10,
        approachDist: 18,
        decideTime: 0.25,
        attack: Castlight,
        attitude: Aggro
    }
},
Unicorn => {
    meleeDamage: 20,
    health: 50,
    speed: 66,
    experience: 30,
    color: 0xffcbdbfc,
    animIndex: 48,
    resistances: [],
    manageData: {
        retreatDist: 0,
        attackDist: Math.sqrt(2),
        approachDist: 12,
        decideTime: 0.25,
        attack: Bite,
        attitude: Nonchalant
    }
},
Spitter => {
    meleeDamage: 0,
    health: 35,
    speed: 35,
    experience: 30,
    color: 0xff76428a,
    animIndex: 66,
    resistances: [{ type: Fire, amount: 0.75 }, { type: Lightning, amount: 0.0 }],
    manageData: {
        retreatDist: 5,
        attackDist: 10,
        approachDist: 18,
        decideTime: 0.25,
        attack: Fireball,
        attitude: Aggro
    }
},
Butterfly => {
    meleeDamage: 0,
    health: 20,
    speed: 75,
    experience: 40,
    color: 0xfffbf236,
    animIndex: 36,
    resistances: [{ type: Fire, amount: 1.5 }, { type: Water, amount: 0.0 }, { type: Air, amount: 0.0 }, { type: Lightning, amount: 0.0 }],
    manageData: {
        retreatDist: 7,
        attackDist: 14,
        approachDist: 21,
        decideTime: 0.25,
        attack: BFRainstorm,
        attitude: Aggro
    }
},
Dragon => {
    meleeDamage: 0,
    health: 200,
    speed: 50,
    experience: 80,
    color: 0xff37946e,
    animIndex: 60,
    resistances: [{ type: Fire, amount: 0.25 }, { type: Lightning, amount: 0.25 }],
    manageData: {
        retreatDist: 7,
        attackDist: 14,
        approachDist: 21,
        decideTime: 0.1,
        attack: DragonFirestorm,
        attitude: Nonchalant
    }
}];

final seeDiffs = [
    [new IntVec2(-6, -2), new IntVec2(-6, -1), new IntVec2(-6, 0), new IntVec2(-6, 1), new IntVec2(-6, 2), new IntVec2(-5, -4), new IntVec2(-5, -3), new IntVec2(-5, -2), new IntVec2(-5, -1), new IntVec2(-5, 0), new IntVec2(-5, 1), new IntVec2(-5, 2), new IntVec2(-5, 3), new IntVec2(-5, 4), new IntVec2(-4, -5), new IntVec2(-4, -4), new IntVec2(-4, -3), new IntVec2(-4, -2), new IntVec2(-4, -1), new IntVec2(-4, 0), new IntVec2(-4, 1), new IntVec2(-4, 2), new IntVec2(-4, 3), new IntVec2(-4, 4), new IntVec2(-4, 5), new IntVec2(-3, -5), new IntVec2(-3, -4), new IntVec2(-3, -3), new IntVec2(-3, -2), new IntVec2(-3, -1), new IntVec2(-3, 0), new IntVec2(-3, 1), new IntVec2(-3, 2), new IntVec2(-3, 3), new IntVec2(-3, 4), new IntVec2(-3, 5), new IntVec2(-2, -6), new IntVec2(-2, -5), new IntVec2(-2, -4), new IntVec2(-2, -3), new IntVec2(-2, -2), new IntVec2(-2, -1), new IntVec2(-2, 0), new IntVec2(-2, 1), new IntVec2(-2, 2), new IntVec2(-2, 3), new IntVec2(-2, 4), new IntVec2(-2, 5), new IntVec2(-2, 6), new IntVec2(-1, -6), new IntVec2(-1, -5), new IntVec2(-1, -4), new IntVec2(-1, -3), new IntVec2(-1, -2), new IntVec2(-1, -1), new IntVec2(-1, 0), new IntVec2(-1, 1), new IntVec2(-1, 2), new IntVec2(-1, 3), new IntVec2(-1, 4), new IntVec2(-1, 5), new IntVec2(-1, 6), new IntVec2(0, -6), new IntVec2(0, -5), new IntVec2(0, -4), new IntVec2(0, -3), new IntVec2(0, -2), new IntVec2(0, -1), new IntVec2(0, 0), new IntVec2(0, 1), new IntVec2(0, 2), new IntVec2(0, 3), new IntVec2(0, 4), new IntVec2(0, 5), new IntVec2(0, 6), new IntVec2(1, -6), new IntVec2(1, -5), new IntVec2(1, -4), new IntVec2(1, -3), new IntVec2(1, -2), new IntVec2(1, -1), new IntVec2(1, 0), new IntVec2(1, 1), new IntVec2(1, 2), new IntVec2(1, 3), new IntVec2(1, 4), new IntVec2(1, 5), new IntVec2(1, 6), new IntVec2(2, -6), new IntVec2(2, -5), new IntVec2(2, -4), new IntVec2(2, -3), new IntVec2(2, -2), new IntVec2(2, -1), new IntVec2(2, 0), new IntVec2(2, 1), new IntVec2(2, 2), new IntVec2(2, 3), new IntVec2(2, 4), new IntVec2(2, 5), new IntVec2(2, 6), new IntVec2(3, -5), new IntVec2(3, -4), new IntVec2(3, -3), new IntVec2(3, -2), new IntVec2(3, -1), new IntVec2(3, 0), new IntVec2(3, 1), new IntVec2(3, 2), new IntVec2(3, 3), new IntVec2(3, 4), new IntVec2(3, 5), new IntVec2(4, -5), new IntVec2(4, -4), new IntVec2(4, -3), new IntVec2(4, -2), new IntVec2(4, -1), new IntVec2(4, 0), new IntVec2(4, 1), new IntVec2(4, 2), new IntVec2(4, 3), new IntVec2(4, 4), new IntVec2(4, 5), new IntVec2(5, -4), new IntVec2(5, -3), new IntVec2(5, -2), new IntVec2(5, -1), new IntVec2(5, 0), new IntVec2(5, 1), new IntVec2(5, 2), new IntVec2(5, 3), new IntVec2(5, 4), new IntVec2(6, -2), new IntVec2(6, -1), new IntVec2(6, 0), new IntVec2(6, 1), new IntVec2(6, 2)],
    [new IntVec2(-7, -2), new IntVec2(-7, -1), new IntVec2(-7, 0), new IntVec2(-7, 1), new IntVec2(-7, 2), new IntVec2(-6, -4), new IntVec2(-6, -3), new IntVec2(-6, -2), new IntVec2(-6, -1), new IntVec2(-6, 0), new IntVec2(-6, 1), new IntVec2(-6, 2), new IntVec2(-6, 3), new IntVec2(-6, 4), new IntVec2(-5, -5), new IntVec2(-5, -4), new IntVec2(-5, -3), new IntVec2(-5, -2), new IntVec2(-5, -1), new IntVec2(-5, 0), new IntVec2(-5, 1), new IntVec2(-5, 2), new IntVec2(-5, 3), new IntVec2(-5, 4), new IntVec2(-5, 5), new IntVec2(-4, -6), new IntVec2(-4, -5), new IntVec2(-4, -4), new IntVec2(-4, -3), new IntVec2(-4, -2), new IntVec2(-4, -1), new IntVec2(-4, 0), new IntVec2(-4, 1), new IntVec2(-4, 2), new IntVec2(-4, 3), new IntVec2(-4, 4), new IntVec2(-4, 5), new IntVec2(-4, 6), new IntVec2(-3, -6), new IntVec2(-3, -5), new IntVec2(-3, -4), new IntVec2(-3, -3), new IntVec2(-3, -2), new IntVec2(-3, -1), new IntVec2(-3, 0), new IntVec2(-3, 1), new IntVec2(-3, 2), new IntVec2(-3, 3), new IntVec2(-3, 4), new IntVec2(-3, 5), new IntVec2(-3, 6), new IntVec2(-2, -7), new IntVec2(-2, -6), new IntVec2(-2, -5), new IntVec2(-2, -4), new IntVec2(-2, -3), new IntVec2(-2, -2), new IntVec2(-2, -1), new IntVec2(-2, 0), new IntVec2(-2, 1), new IntVec2(-2, 2), new IntVec2(-2, 3), new IntVec2(-2, 4), new IntVec2(-2, 5), new IntVec2(-2, 6), new IntVec2(-2, 7), new IntVec2(-1, -7), new IntVec2(-1, -6), new IntVec2(-1, -5), new IntVec2(-1, -4), new IntVec2(-1, -3), new IntVec2(-1, -2), new IntVec2(-1, -1), new IntVec2(-1, 0), new IntVec2(-1, 1), new IntVec2(-1, 2), new IntVec2(-1, 3), new IntVec2(-1, 4), new IntVec2(-1, 5), new IntVec2(-1, 6), new IntVec2(-1, 7), new IntVec2(0, -7), new IntVec2(0, -6), new IntVec2(0, -5), new IntVec2(0, -4), new IntVec2(0, -3), new IntVec2(0, -2), new IntVec2(0, -1), new IntVec2(0, 0), new IntVec2(0, 1), new IntVec2(0, 2), new IntVec2(0, 3), new IntVec2(0, 4), new IntVec2(0, 5), new IntVec2(0, 6), new IntVec2(0, 7), new IntVec2(1, -7), new IntVec2(1, -6), new IntVec2(1, -5), new IntVec2(1, -4), new IntVec2(1, -3), new IntVec2(1, -2), new IntVec2(1, -1), new IntVec2(1, 0), new IntVec2(1, 1), new IntVec2(1, 2), new IntVec2(1, 3), new IntVec2(1, 4), new IntVec2(1, 5), new IntVec2(1, 6), new IntVec2(1, 7), new IntVec2(2, -7), new IntVec2(2, -6), new IntVec2(2, -5), new IntVec2(2, -4), new IntVec2(2, -3), new IntVec2(2, -2), new IntVec2(2, -1), new IntVec2(2, 0), new IntVec2(2, 1), new IntVec2(2, 2), new IntVec2(2, 3), new IntVec2(2, 4), new IntVec2(2, 5), new IntVec2(2, 6), new IntVec2(2, 7), new IntVec2(3, -6), new IntVec2(3, -5), new IntVec2(3, -4), new IntVec2(3, -3), new IntVec2(3, -2), new IntVec2(3, -1), new IntVec2(3, 0), new IntVec2(3, 1), new IntVec2(3, 2), new IntVec2(3, 3), new IntVec2(3, 4), new IntVec2(3, 5), new IntVec2(3, 6), new IntVec2(4, -6), new IntVec2(4, -5), new IntVec2(4, -4), new IntVec2(4, -3), new IntVec2(4, -2), new IntVec2(4, -1), new IntVec2(4, 0), new IntVec2(4, 1), new IntVec2(4, 2), new IntVec2(4, 3), new IntVec2(4, 4), new IntVec2(4, 5), new IntVec2(4, 6), new IntVec2(5, -5), new IntVec2(5, -4), new IntVec2(5, -3), new IntVec2(5, -2), new IntVec2(5, -1), new IntVec2(5, 0), new IntVec2(5, 1), new IntVec2(5, 2), new IntVec2(5, 3), new IntVec2(5, 4), new IntVec2(5, 5), new IntVec2(6, -4), new IntVec2(6, -3), new IntVec2(6, -2), new IntVec2(6, -1), new IntVec2(6, 0), new IntVec2(6, 1), new IntVec2(6, 2), new IntVec2(6, 3), new IntVec2(6, 4), new IntVec2(7, -2), new IntVec2(7, -1), new IntVec2(7, 0), new IntVec2(7, 1), new IntVec2(7, 2)],
    [new IntVec2(-8, -2), new IntVec2(-8, -1), new IntVec2(-8, 0), new IntVec2(-8, 1), new IntVec2(-8, 2), new IntVec2(-7, -4), new IntVec2(-7, -3), new IntVec2(-7, -2), new IntVec2(-7, -1), new IntVec2(-7, 0), new IntVec2(-7, 1), new IntVec2(-7, 2), new IntVec2(-7, 3), new IntVec2(-7, 4), new IntVec2(-6, -6), new IntVec2(-6, -5), new IntVec2(-6, -4), new IntVec2(-6, -3), new IntVec2(-6, -2), new IntVec2(-6, -1), new IntVec2(-6, 0), new IntVec2(-6, 1), new IntVec2(-6, 2), new IntVec2(-6, 3), new IntVec2(-6, 4), new IntVec2(-6, 5), new IntVec2(-6, 6), new IntVec2(-5, -6), new IntVec2(-5, -5), new IntVec2(-5, -4), new IntVec2(-5, -3), new IntVec2(-5, -2), new IntVec2(-5, -1), new IntVec2(-5, 0), new IntVec2(-5, 1), new IntVec2(-5, 2), new IntVec2(-5, 3), new IntVec2(-5, 4), new IntVec2(-5, 5), new IntVec2(-5, 6), new IntVec2(-4, -7), new IntVec2(-4, -6), new IntVec2(-4, -5), new IntVec2(-4, -4), new IntVec2(-4, -3), new IntVec2(-4, -2), new IntVec2(-4, -1), new IntVec2(-4, 0), new IntVec2(-4, 1), new IntVec2(-4, 2), new IntVec2(-4, 3), new IntVec2(-4, 4), new IntVec2(-4, 5), new IntVec2(-4, 6), new IntVec2(-4, 7), new IntVec2(-3, -7), new IntVec2(-3, -6), new IntVec2(-3, -5), new IntVec2(-3, -4), new IntVec2(-3, -3), new IntVec2(-3, -2), new IntVec2(-3, -1), new IntVec2(-3, 0), new IntVec2(-3, 1), new IntVec2(-3, 2), new IntVec2(-3, 3), new IntVec2(-3, 4), new IntVec2(-3, 5), new IntVec2(-3, 6), new IntVec2(-3, 7), new IntVec2(-2, -8), new IntVec2(-2, -7), new IntVec2(-2, -6), new IntVec2(-2, -5), new IntVec2(-2, -4), new IntVec2(-2, -3), new IntVec2(-2, -2), new IntVec2(-2, -1), new IntVec2(-2, 0), new IntVec2(-2, 1), new IntVec2(-2, 2), new IntVec2(-2, 3), new IntVec2(-2, 4), new IntVec2(-2, 5), new IntVec2(-2, 6), new IntVec2(-2, 7), new IntVec2(-2, 8), new IntVec2(-1, -8), new IntVec2(-1, -7), new IntVec2(-1, -6), new IntVec2(-1, -5), new IntVec2(-1, -4), new IntVec2(-1, -3), new IntVec2(-1, -2), new IntVec2(-1, -1), new IntVec2(-1, 0), new IntVec2(-1, 1), new IntVec2(-1, 2), new IntVec2(-1, 3), new IntVec2(-1, 4), new IntVec2(-1, 5), new IntVec2(-1, 6), new IntVec2(-1, 7), new IntVec2(-1, 8), new IntVec2(0, -8), new IntVec2(0, -7), new IntVec2(0, -6), new IntVec2(0, -5), new IntVec2(0, -4), new IntVec2(0, -3), new IntVec2(0, -2), new IntVec2(0, -1), new IntVec2(0, 0), new IntVec2(0, 1), new IntVec2(0, 2), new IntVec2(0, 3), new IntVec2(0, 4), new IntVec2(0, 5), new IntVec2(0, 6), new IntVec2(0, 7), new IntVec2(0, 8), new IntVec2(1, -8), new IntVec2(1, -7), new IntVec2(1, -6), new IntVec2(1, -5), new IntVec2(1, -4), new IntVec2(1, -3), new IntVec2(1, -2), new IntVec2(1, -1), new IntVec2(1, 0), new IntVec2(1, 1), new IntVec2(1, 2), new IntVec2(1, 3), new IntVec2(1, 4), new IntVec2(1, 5), new IntVec2(1, 6), new IntVec2(1, 7), new IntVec2(1, 8), new IntVec2(2, -8), new IntVec2(2, -7), new IntVec2(2, -6), new IntVec2(2, -5), new IntVec2(2, -4), new IntVec2(2, -3), new IntVec2(2, -2), new IntVec2(2, -1), new IntVec2(2, 0), new IntVec2(2, 1), new IntVec2(2, 2), new IntVec2(2, 3), new IntVec2(2, 4), new IntVec2(2, 5), new IntVec2(2, 6), new IntVec2(2, 7), new IntVec2(2, 8), new IntVec2(3, -7), new IntVec2(3, -6), new IntVec2(3, -5), new IntVec2(3, -4), new IntVec2(3, -3), new IntVec2(3, -2), new IntVec2(3, -1), new IntVec2(3, 0), new IntVec2(3, 1), new IntVec2(3, 2), new IntVec2(3, 3), new IntVec2(3, 4), new IntVec2(3, 5), new IntVec2(3, 6), new IntVec2(3, 7), new IntVec2(4, -7), new IntVec2(4, -6), new IntVec2(4, -5), new IntVec2(4, -4), new IntVec2(4, -3), new IntVec2(4, -2), new IntVec2(4, -1), new IntVec2(4, 0), new IntVec2(4, 1), new IntVec2(4, 2), new IntVec2(4, 3), new IntVec2(4, 4), new IntVec2(4, 5), new IntVec2(4, 6), new IntVec2(4, 7), new IntVec2(5, -6), new IntVec2(5, -5), new IntVec2(5, -4), new IntVec2(5, -3), new IntVec2(5, -2), new IntVec2(5, -1), new IntVec2(5, 0), new IntVec2(5, 1), new IntVec2(5, 2), new IntVec2(5, 3), new IntVec2(5, 4), new IntVec2(5, 5), new IntVec2(5, 6), new IntVec2(6, -6), new IntVec2(6, -5), new IntVec2(6, -4), new IntVec2(6, -3), new IntVec2(6, -2), new IntVec2(6, -1), new IntVec2(6, 0), new IntVec2(6, 1), new IntVec2(6, 2), new IntVec2(6, 3), new IntVec2(6, 4), new IntVec2(6, 5), new IntVec2(6, 6), new IntVec2(7, -4), new IntVec2(7, -3), new IntVec2(7, -2), new IntVec2(7, -1), new IntVec2(7, 0), new IntVec2(7, 1), new IntVec2(7, 2), new IntVec2(7, 3), new IntVec2(7, 4), new IntVec2(8, -2), new IntVec2(8, -1), new IntVec2(8, 0), new IntVec2(8, 1), new IntVec2(8, 2)],
    [new IntVec2(-9, -3), new IntVec2(-9, -2), new IntVec2(-9, -1), new IntVec2(-9, 0), new IntVec2(-9, 1), new IntVec2(-9, 2), new IntVec2(-9, 3), new IntVec2(-8, -5), new IntVec2(-8, -4), new IntVec2(-8, -3), new IntVec2(-8, -2), new IntVec2(-8, -1), new IntVec2(-8, 0), new IntVec2(-8, 1), new IntVec2(-8, 2), new IntVec2(-8, 3), new IntVec2(-8, 4), new IntVec2(-8, 5), new IntVec2(-7, -6), new IntVec2(-7, -5), new IntVec2(-7, -4), new IntVec2(-7, -3), new IntVec2(-7, -2), new IntVec2(-7, -1), new IntVec2(-7, 0), new IntVec2(-7, 1), new IntVec2(-7, 2), new IntVec2(-7, 3), new IntVec2(-7, 4), new IntVec2(-7, 5), new IntVec2(-7, 6), new IntVec2(-6, -7), new IntVec2(-6, -6), new IntVec2(-6, -5), new IntVec2(-6, -4), new IntVec2(-6, -3), new IntVec2(-6, -2), new IntVec2(-6, -1), new IntVec2(-6, 0), new IntVec2(-6, 1), new IntVec2(-6, 2), new IntVec2(-6, 3), new IntVec2(-6, 4), new IntVec2(-6, 5), new IntVec2(-6, 6), new IntVec2(-6, 7), new IntVec2(-5, -8), new IntVec2(-5, -7), new IntVec2(-5, -6), new IntVec2(-5, -5), new IntVec2(-5, -4), new IntVec2(-5, -3), new IntVec2(-5, -2), new IntVec2(-5, -1), new IntVec2(-5, 0), new IntVec2(-5, 1), new IntVec2(-5, 2), new IntVec2(-5, 3), new IntVec2(-5, 4), new IntVec2(-5, 5), new IntVec2(-5, 6), new IntVec2(-5, 7), new IntVec2(-5, 8), new IntVec2(-4, -8), new IntVec2(-4, -7), new IntVec2(-4, -6), new IntVec2(-4, -5), new IntVec2(-4, -4), new IntVec2(-4, -3), new IntVec2(-4, -2), new IntVec2(-4, -1), new IntVec2(-4, 0), new IntVec2(-4, 1), new IntVec2(-4, 2), new IntVec2(-4, 3), new IntVec2(-4, 4), new IntVec2(-4, 5), new IntVec2(-4, 6), new IntVec2(-4, 7), new IntVec2(-4, 8), new IntVec2(-3, -9), new IntVec2(-3, -8), new IntVec2(-3, -7), new IntVec2(-3, -6), new IntVec2(-3, -5), new IntVec2(-3, -4), new IntVec2(-3, -3), new IntVec2(-3, -2), new IntVec2(-3, -1), new IntVec2(-3, 0), new IntVec2(-3, 1), new IntVec2(-3, 2), new IntVec2(-3, 3), new IntVec2(-3, 4), new IntVec2(-3, 5), new IntVec2(-3, 6), new IntVec2(-3, 7), new IntVec2(-3, 8), new IntVec2(-3, 9), new IntVec2(-2, -9), new IntVec2(-2, -8), new IntVec2(-2, -7), new IntVec2(-2, -6), new IntVec2(-2, -5), new IntVec2(-2, -4), new IntVec2(-2, -3), new IntVec2(-2, -2), new IntVec2(-2, -1), new IntVec2(-2, 0), new IntVec2(-2, 1), new IntVec2(-2, 2), new IntVec2(-2, 3), new IntVec2(-2, 4), new IntVec2(-2, 5), new IntVec2(-2, 6), new IntVec2(-2, 7), new IntVec2(-2, 8), new IntVec2(-2, 9), new IntVec2(-1, -9), new IntVec2(-1, -8), new IntVec2(-1, -7), new IntVec2(-1, -6), new IntVec2(-1, -5), new IntVec2(-1, -4), new IntVec2(-1, -3), new IntVec2(-1, -2), new IntVec2(-1, -1), new IntVec2(-1, 0), new IntVec2(-1, 1), new IntVec2(-1, 2), new IntVec2(-1, 3), new IntVec2(-1, 4), new IntVec2(-1, 5), new IntVec2(-1, 6), new IntVec2(-1, 7), new IntVec2(-1, 8), new IntVec2(-1, 9), new IntVec2(0, -9), new IntVec2(0, -8), new IntVec2(0, -7), new IntVec2(0, -6), new IntVec2(0, -5), new IntVec2(0, -4), new IntVec2(0, -3), new IntVec2(0, -2), new IntVec2(0, -1), new IntVec2(0, 0), new IntVec2(0, 1), new IntVec2(0, 2), new IntVec2(0, 3), new IntVec2(0, 4), new IntVec2(0, 5), new IntVec2(0, 6), new IntVec2(0, 7), new IntVec2(0, 8), new IntVec2(0, 9), new IntVec2(1, -9), new IntVec2(1, -8), new IntVec2(1, -7), new IntVec2(1, -6), new IntVec2(1, -5), new IntVec2(1, -4), new IntVec2(1, -3), new IntVec2(1, -2), new IntVec2(1, -1), new IntVec2(1, 0), new IntVec2(1, 1), new IntVec2(1, 2), new IntVec2(1, 3), new IntVec2(1, 4), new IntVec2(1, 5), new IntVec2(1, 6), new IntVec2(1, 7), new IntVec2(1, 8), new IntVec2(1, 9), new IntVec2(2, -9), new IntVec2(2, -8), new IntVec2(2, -7), new IntVec2(2, -6), new IntVec2(2, -5), new IntVec2(2, -4), new IntVec2(2, -3), new IntVec2(2, -2), new IntVec2(2, -1), new IntVec2(2, 0), new IntVec2(2, 1), new IntVec2(2, 2), new IntVec2(2, 3), new IntVec2(2, 4), new IntVec2(2, 5), new IntVec2(2, 6), new IntVec2(2, 7), new IntVec2(2, 8), new IntVec2(2, 9), new IntVec2(3, -9), new IntVec2(3, -8), new IntVec2(3, -7), new IntVec2(3, -6), new IntVec2(3, -5), new IntVec2(3, -4), new IntVec2(3, -3), new IntVec2(3, -2), new IntVec2(3, -1), new IntVec2(3, 0), new IntVec2(3, 1), new IntVec2(3, 2), new IntVec2(3, 3), new IntVec2(3, 4), new IntVec2(3, 5), new IntVec2(3, 6), new IntVec2(3, 7), new IntVec2(3, 8), new IntVec2(3, 9), new IntVec2(4, -8), new IntVec2(4, -7), new IntVec2(4, -6), new IntVec2(4, -5), new IntVec2(4, -4), new IntVec2(4, -3), new IntVec2(4, -2), new IntVec2(4, -1), new IntVec2(4, 0), new IntVec2(4, 1), new IntVec2(4, 2), new IntVec2(4, 3), new IntVec2(4, 4), new IntVec2(4, 5), new IntVec2(4, 6), new IntVec2(4, 7), new IntVec2(4, 8), new IntVec2(5, -8), new IntVec2(5, -7), new IntVec2(5, -6), new IntVec2(5, -5), new IntVec2(5, -4), new IntVec2(5, -3), new IntVec2(5, -2), new IntVec2(5, -1), new IntVec2(5, 0), new IntVec2(5, 1), new IntVec2(5, 2), new IntVec2(5, 3), new IntVec2(5, 4), new IntVec2(5, 5), new IntVec2(5, 6), new IntVec2(5, 7), new IntVec2(5, 8), new IntVec2(6, -7), new IntVec2(6, -6), new IntVec2(6, -5), new IntVec2(6, -4), new IntVec2(6, -3), new IntVec2(6, -2), new IntVec2(6, -1), new IntVec2(6, 0), new IntVec2(6, 1), new IntVec2(6, 2), new IntVec2(6, 3), new IntVec2(6, 4), new IntVec2(6, 5), new IntVec2(6, 6), new IntVec2(6, 7), new IntVec2(7, -6), new IntVec2(7, -5), new IntVec2(7, -4), new IntVec2(7, -3), new IntVec2(7, -2), new IntVec2(7, -1), new IntVec2(7, 0), new IntVec2(7, 1), new IntVec2(7, 2), new IntVec2(7, 3), new IntVec2(7, 4), new IntVec2(7, 5), new IntVec2(7, 6), new IntVec2(8, -5), new IntVec2(8, -4), new IntVec2(8, -3), new IntVec2(8, -2), new IntVec2(8, -1), new IntVec2(8, 0), new IntVec2(8, 1), new IntVec2(8, 2), new IntVec2(8, 3), new IntVec2(8, 4), new IntVec2(8, 5), new IntVec2(9, -3), new IntVec2(9, -2), new IntVec2(9, -1), new IntVec2(9, 0), new IntVec2(9, 1), new IntVec2(9, 2), new IntVec2(9, 3)]
];
