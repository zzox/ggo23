package game.util;

import core.Group;

function sortGroupByY (group:Group) {
    group._children.sort((s1, s2) -> s1.y < s2.y ? -1 : s1.y > s2.y ? 1 : 0);
}
