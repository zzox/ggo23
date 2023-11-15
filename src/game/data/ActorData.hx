package game.data;

enum ActorType {
    PlayerActor;
    Rat;
}

// Data for visuals _and_ state
typedef ActorData = {
    var preAttackTime:Float;
    var attackTime:Float;
    var color:Int;
    // TODO: use a single index for anims and go from there.
    var moveAnims:Array<Int>;
    var preAttackAnim:Int;
    var attackAnim:Int;

    var meleeDamage:Int;
    var speed:Float;
    var health:Int;
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
    speed: 0.25,
    color: 0xff5b6ee1,
    moveAnims: [0, 1],
    preAttackAnim: 2,
    attackAnim: 3,
},
Rat => {
    preAttackTime: 0.5,
    attackTime: 1.0,
    meleeDamage: 10,
    health: 25,
    speed: 0.5,
    color: 0xffa8a8a8,
    moveAnims: [4, 5],
    preAttackAnim: 6,
    attackAnim: 6
}
];
