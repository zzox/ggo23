package game.data;

import game.data.AttackData;

enum ActorType {
    PlayerActor;
    // Rat;
    BigRat;
    Snake;
    // Cobra;
    Plant;
    Butterfly;
}

typedef ManageData = {
    var approachDist:Float;
    var retreatDist:Float;
    var attackDist:Float;
    var decideTime:Float;
    var attack:AttackName;
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
    // experience (for kills)
    // resistances: Array<Resistance>;

    // ?generate elements
}

typedef PlayerData = {
    var maxHealth:Int;
    var speed:Int;
    var attack:Int;
    var defense:Int;
    var dexterity:Int;
    var spells:Array<AttackData>;

    // var health:Int;
}

final actorData:Map<ActorType, ActorData> = [
PlayerActor => {
    preAttackTime: 0.0,
    attackTime: 0.0,
    meleeDamage: 0,
    health: 100,
    speed: 55,
    color: 0xff5b6ee1,
    animIndex: 0,
},
BigRat => {
    preAttackTime: 0.5,
    attackTime: 1.0,
    meleeDamage: 10,
    health: 25,
    speed: 25,
    color: 0xffa8a8a8,
    animIndex: 12,
    manageData: {
        retreatDist: 0,
        attackDist: Math.sqrt(2),
        approachDist: 10,
        decideTime: 1.0,
        attack: Bite
    }
},
Snake => {
    preAttackTime: 0.1,
    attackTime: 0.5,
    meleeDamage: 20,
    health: 12,
    speed: 35,
    color: 0xff6abe30,
    animIndex: 18,
    manageData: {
        retreatDist: 0,
        attackDist: Math.sqrt(2),
        approachDist: 12,
        decideTime: 0.5,
        attack: Bite
    }
},
Plant => {
    preAttackTime: 0.1,
    attackTime: 0.5,
    meleeDamage: 33,
    health: 12,
    speed: 25,
    color: 0xff37946e,
    animIndex: 30,
    // add neg fire resistance
    manageData: {
        retreatDist: 0,
        attackDist: Math.sqrt(2),
        approachDist: 25,
        decideTime: 0.1,
        attack: Bite
    }
},
Butterfly => {
    preAttackTime: 0.1,
    attackTime: 0.5,
    meleeDamage: 0,
    health: 10,
    speed: 50,
    color: 0xfffbf236,
    animIndex: 36,
    manageData: {
        retreatDist: 5,
        attackDist: 10,
        approachDist: 25,
        decideTime: 0.25,
        attack: Windthrow
    }
}
];
