package game.util;

import core.Group;
import core.Types.IntVec2;

function sortGroupByY (group:Group) {
    group._children.sort((s1, s2) -> s1.y < s2.y ? -1 : s1.y > s2.y ? 1 : 0);
}

function isDiagonal (pos1:IntVec2, pos2:IntVec2) {
    if (pos1.x != pos2.x && pos1.y != pos2.y) {
        return true;
    }

    return false;
}
