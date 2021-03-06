/*
 * Copyright (c) 2013 Meltytech, LLC
 * Author: Dan Dennedy <dan@dennedy.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

var SNAP = 10

function snapClip(clip, repeater) {
    // clip.x = left edge
    var right = clip.x + clip.width
    var cursorX = scrollView.flickableItem.contentX + cursor.x
    if (clip.x > -SNAP && clip.x < SNAP) {
        // Snap around origin.
        clip.x = 0
    } else if (clip.x > cursorX - SNAP && clip.x < cursorX + SNAP) {
        // Snap around cursor/playhead.
        clip.x = cursorX
    } else if (right > cursorX - SNAP && right < cursorX + SNAP) {
        clip.x = cursorX - clip.width
    } else {
        // Snap to other clips.
        for (var i = 0; i < repeater.count; i++) {
            var itemLeft = repeater.itemAt(i).x
            var itemRight = itemLeft + repeater.itemAt(i).width
            if (right > itemLeft - SNAP && right < itemLeft + SNAP)
                clip.x = itemLeft - clip.width
            else if (clip.x > itemRight - SNAP && clip.x < itemRight + SNAP)
                clip.x = itemRight
        }
    }
}

function snapTrimIn(clip, delta) {
    var x = clip.x + delta
    var cursorX = scrollView.flickableItem.contentX + cursor.x
    if (x > -SNAP && x < SNAP) {
        // Snap around origin.
        return Math.round(-clip.x / timeScale)
    } else if (x > cursorX - SNAP && x < cursorX + SNAP) {
        // Snap around cursor/playhead.
        return Math.round((cursorX - clip.x) / timeScale)
    } else if (false) {
        // Snap to other clips.
        for (var i = 0; i < repeater.count; i++) {
            if (i === clip.DelegateModel.itemsIndex || repeater.itemAt(i).isBlank)
                continue
            var itemLeft = repeater.itemAt(i).x
            var itemRight = itemLeft + repeater.itemAt(i).width
            if (x > itemLeft - SNAP && x < itemLeft + SNAP)
                return Math.round((itemLeft - clip.x) / timeScale)
            else if (x > itemRight - SNAP && x < itemRight + SNAP)
                return Math.round((itemRight - clip.x) / timeScale)
        }
    }
    return delta
}

function snapTrimOut(clip, delta) {
    var rightEdge = clip.x + clip.width
    var x = rightEdge - delta
    var cursorX = scrollView.flickableItem.contentX + cursor.x
    if (x > cursorX - SNAP && x < cursorX + SNAP) {
        // Snap around cursor/playhead.
        return Math.round((rightEdge - cursorX) / timeScale)
    } else if (delta < 0) {
        // Snap to other clips.
        for (var i = 0; i < repeater.count; i++) {
            if (i === clip.DelegateModel.itemsIndex || repeater.itemAt(i).isBlank)
                continue
            var itemLeft = repeater.itemAt(i).x
            var itemRight = itemLeft + repeater.itemAt(i).width
            if (x > itemLeft - SNAP && x < itemLeft + SNAP)
                return Math.round((rightEdge - itemLeft) / timeScale)
            else if (x > itemRight - SNAP && x < itemRight + SNAP)
                return Math.round((rightEdge - itemRight) / timeScale)
        }
    }
    return delta
}
