package game.data;

import game.data.AttackData;

enum Scale {
    Power50;
    Vel50;
    UpgradeWindstorm;
    UpgradeRainstorm;
    UpgradeFirestorm;
    UpgradeLightstorm;
    // LearnWindthrow; // should be default
    LearnCastlight;
    LearnFireball;
    AllTimesLess25;
    Dex15;
    Def15;
    Spd10;
    Att10;
}

typedef ScaleData = {
    var text:String;
    var level:Int;
    var ?index:Int;
}

final scaleData:Map<Scale, ScaleData> = [
    Power50 => { text: 'Increase power by 50%', level: 0 },
    Vel50 => { text: 'Increase velocity by 50%', level: 0 },
    LearnCastlight => { text: 'Learn Castlight', index: 2, level: 1 },
    LearnFireball => { text: 'Learn Fireball', index: 0, level: 1 },
    UpgradeWindstorm => { text: 'Upgrade to Windstorm', index: 3, level: 2 },
    UpgradeRainstorm => { text: 'Upgrade to Rainstorm', index: 5, level: 2 },
    UpgradeFirestorm => { text: 'Upgrade to Firestorm', index: 4, level: 2 },
    UpgradeLightstorm => { text: 'Upgrade to Lightstorm', index: 2, level: 2 },
    AllTimesLess25 => { text: 'All spells 25% faster', index: 0, level: 3 },
    Dex15 => { text: 'Increase Dexterity by 15', index: 0, level: 3 },
    Def15 => { text: 'Increase Defense by 15', index: 0, level: 3 },
    Spd10 => { text: 'Increase Speed by 10', index: 0, level: 3 },
    Att10 => { text: 'Increase Attatck by 10', index: 0, level: 3 },
];

final playerScales:Map<AttackName, Array<Scale>> = [
    Windthrow => [Vel50, Power50, UpgradeWindstorm],
    Raincast => [Power50, Vel50, UpgradeRainstorm],
    Fireball => [Vel50, UpgradeFirestorm],
    Castlight => [Power50, UpgradeLightstorm]
    // Windthrow => [UpgradeWindstorm],
    // Raincast => [UpgradeRainstorm],
    // Fireball => [UpgradeFirestorm],
    // Castlight => [UpgradeLightstorm]
];

final otherScales:Array<Scale> = [
    LearnFireball,
    LearnCastlight,
    AllTimesLess25,
    Dex15,
    Def15,
    Spd10,
    Att10,
];
