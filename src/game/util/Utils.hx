package game.util;

import core.Group;
import core.Types;
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
