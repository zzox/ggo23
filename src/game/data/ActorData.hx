package game.data;

import game.data.AttackData;
import game.world.Element.ElementType;

enum ActorType {
    PlayerActor;
    Rat;
    BigRat;
    Snake;
    // Cobra;
    Plant;
    Butterfly;
    LightningMan;
    Unicorn;
}

enum Attitude {
    Aggro;
    // Frightened; // doesn't do anything
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
    var preAttackTime:Float;
    var attackTime:Float;
    var color:Int;
    var animIndex:Int;

    var meleeDamage:Int;
    var speed:Int;
    var health:Int;

    var ?manageData:ManageData;
    var experience:Int;
    var resistances: Array<Resistance>;

    // ?generate elements ???
}

typedef PlayerData = {
    var maxHealth:Int;
    var speed:Int;
    var attack:Int;
    var defense:Int;
    var dexterity:Int;
    var spells:Array<AttackData>;
    var scales:Array<Scale>;

    var level:Int;
    var experience:Int;
    var maxExperience:Int;
    var pointsAvailable:Array<Int>;
    // var health:Int;
}

final actorData:Map<ActorType, ActorData> = [
PlayerActor => {
    preAttackTime: 0.0,
    attackTime: 0.0,
    meleeDamage: 0,
    health: 0,
    speed: 55,
    experience: 66,
    color: 0xff5b6ee1,
    animIndex: 0,
    resistances: [],
},
Rat => {
    preAttackTime: 0.5,
    attackTime: 1.0,
    meleeDamage: 10,
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
    preAttackTime: 0.5,
    attackTime: 1.0,
    meleeDamage: 10,
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
    preAttackTime: 0.1,
    attackTime: 0.5,
    meleeDamage: 20,
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
Plant => {
    preAttackTime: 1.0,
    attackTime: 0.5,
    meleeDamage: 33,
    health: 12,
    speed: 25,
    experience: 15,
    color: 0xff37946e,
    resistances: [{ type: Fire, amount: 2.0 }],
    animIndex: 30,
    // add neg fire resistance
    manageData: {
        retreatDist: 0,
        attackDist: Math.sqrt(2),
        approachDist: 25,
        decideTime: 0.1,
        attack: Bite,
        attitude: Aggro
    }
},
Butterfly => {
    preAttackTime: 0.5,
    attackTime: 0.5,
    meleeDamage: 0,
    health: 10,
    speed: 50,
    experience: 20,
    color: 0xfffbf236,
    animIndex: 36,
    resistances: [{ type: Fire, amount: 1.5 }, { type: Air, amount: 0.0 }],
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
    preAttackTime: 0.25,
    attackTime: 0.25,
    meleeDamage: 0,
    health: 50,
    speed: 20,
    experience: 40,
    color: 0xffcbdbfc,
    animIndex: 42,
    resistances: [],
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
    preAttackTime: 0.25,
    attackTime: 0.25,
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
}
];
