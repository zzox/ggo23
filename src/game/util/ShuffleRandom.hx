package game.util;

import kha.math.Random;

class ShuffleRandom<T> {
    var items:Array<T>;
    var random:Random;
    var index:Int;

    public function new (items:Array<T>, random:Random) {
        this.items = items;
        this.random = random;
        shuffle();
    }

    public function getNext ():T {
        index++;
        if (index == items.length) {
            index = 0;
            shuffle();
        }
        return items[index];
    }

    public function shuffle () {
        for (i in 0...items.length) {
            final j = random.GetIn(0, items.length - 1);
            final temp = items[i];
            items[i] = items[j];
            items[j] = temp;
        }        
    }
}

