package game.util;

import core.Group;
import core.Types;
import game.world.Element;
import game.world.Grid;
import game.world.World;

function translateWorldPos (x:Float, y:Float):Vec2 {
    return new Vec2((x * 8) + (y * 8), (y * 4) + (x * -4));
}

function getTilePos (grid:Grid, xPos:Float, yPos:Float) {
    final x = (xPos - 8) / 16;
    final y = (yPos - 4) / 8;
    return getGridItem(grid, Math.round(x - y), Math.round(x + y));
}

function sortGroupByY (group:Group) {
    group._children.sort((s1, s2) -> s1.y < s2.y ? -1 : s1.y > s2.y ? 1 : 0);
}

function isDiagonal (pos1:IntVec2, pos2:IntVec2) {
    if (pos1.x != pos2.x && pos1.y != pos2.y) {
        return true;
    }

    return false;
}

function getVisDiffFromDir (dir:GridDir) {
    return switch (dir) {
        case North: new IntVec2(-8, -8);
        case East: new IntVec2(8, -8);
        case South: new IntVec2(8, 8);
        case West: new IntVec2(-8, 8);
        case NorthEast: new IntVec2(0, -8);
        case NorthWest: new IntVec2(-16, 0);
        case SouthEast: new IntVec2(16, 0);
        case SouthWest: new IntVec2(0, 8);
        default: throw 'Bad dir!';
    }
}

function getDiffFromDir (dir:GridDir) {
    return switch (dir) {
        case North: new IntVec2(0, -1);
        case East: new IntVec2(1, 0);
        case South: new IntVec2(0, 1);
        case West: new IntVec2(-1, 0);
        case NorthEast: new IntVec2(1, -1);
        case NorthWest: new IntVec2(-1, -1);
        case SouthEast: new IntVec2(1, 1);
        case SouthWest: new IntVec2(-1, 1);
        default: throw 'Bad dir!';
    }
}

function getDirFromDiff (x:Int, y:Int):GridDir {
    if (x == 0 && y == -1) return North;
    if (x == 1 && y == 0) return East;
    if (x == 0 && y == 1) return South;
    if (x == -1 && y == 0) return West;
    if (x == 1 && y == -1) return NorthEast;
    if (x == -1 && y == -1) return NorthWest;
    if (x == 1 && y == 1) return SouthEast;
    if (x == -1 && y == 1) return SouthWest;
    return null;
}

function xCollides (x1:Float, y1:Float, x2:Float, y2:Float) {
    return Math.abs(y1 - y2) < Math.abs(x1 - x2);
}

function separateElements (elem1:Element, elem2:Element, xCollide:Bool) {
    if (xCollide) {
        if (elem1.x < elem2.x) {
            elem1.x = elem2.x - World.HIT_DISTANCE;
        } else {
            elem1.x = elem2.x + World.HIT_DISTANCE;
        }
    } else {
        if (elem1.y < elem2.y) {
            elem1.y = elem2.y - World.HIT_DISTANCE;
        } else {
            elem1.y = elem2.y + World.HIT_DISTANCE;
        }
    }
}

function separateElementGridItem (elem1:Element, elem2:GridItem, xCollide:Bool) {
    if (xCollide) {
        if (elem1.x < elem2.x) {
            elem1.x = elem2.x - World.HIT_DISTANCE;
        } else {
            elem1.x = elem2.x + World.HIT_DISTANCE;
        }
    } else {
        if (elem1.y < elem2.y) {
            elem1.y = elem2.y - World.HIT_DISTANCE;
        } else {
            elem1.y = elem2.y + World.HIT_DISTANCE;
        }
    }
}
