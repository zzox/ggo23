package game.data;

import game.data.AttackData;

enum ActorType {
    PlayerActor;
    BigRat;
    Snake;
}

typedef ManageData = {
    var approachDist:Float;
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
    // attack distance
    // ?generate elements
}

final actorData:Map<ActorType, ActorData> = [
PlayerActor => {
    preAttackTime: 0.0,
    attackTime: 0.0,
    meleeDamage: 10,
    health: 100,
    speed: 60,
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
    animIndex: 6,
    manageData: {
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
    color: 0xff37946e,
    animIndex: 12,
    manageData: {
        attackDist: Math.sqrt(2),
        approachDist: 12,
        decideTime: 0.5,
        attack: Fireball
    }
}
];
