package game.data;

import game.data.AttackData;

enum Scale {
    Power50;
    Vel50;
    Power100Vel;
    BeFlamebigsquare;
    BeWindStorm;
    LearnCastlight;
    LearnFireball;
    LearnWindthrow;
    AllTime50;
}

final scaleData:Map<Scale, String> = [
    Power50 => 'Increase power by 50%',
    Vel50 => 'Increase velocity by 50%',
    Power100Vel => 'Double power',
];

// TODO: add scales when cloning, or make a separate type
final playerScales:Map<AttackName, Array<Scale>> = [
    Windthrow => [Power50, Vel50],
    Fireball => [Power50, Vel50],
    Raincast => [Power50, Vel50],
];
