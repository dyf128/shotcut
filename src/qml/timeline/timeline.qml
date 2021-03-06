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

import QtQuick 2.0
import QtQml.Models 2.1
import QtQuick.Controls 1.0

Rectangle {
    id: root
    SystemPalette { id: activePalette }
    color: activePalette.window

    property int headerWidth: 176
    property int trackHeight: 50
    property real scaleFactor: 0.5
    property int currentTrack: 0
    property int currentClip: -1
    property int currentClipTrack: -1
    property color selectedTrackColor: Qt.tint(activePalette.base, Qt.rgba(0.8, 0.8, 0, 0.3));

    Row {
        Column {
            z: 1
            Rectangle {
                id: toolbar
                height: ruler.height
                width: headerWidth
                z: 1
                color: activePalette.window
                Row {
                    spacing: 6
                    Item {
                        width: 1
                        height: 1
                    }
                    Button {
                        action: menuAction
                        implicitWidth: 28
                        implicitHeight: 24
                    }
                    Button {
                        action: appendAction
                        implicitWidth: 28
                        implicitHeight: 24
                    }
                    Button {
                        action: liftAction
                        implicitWidth: 28
                        implicitHeight: 24
                    }
                    Button {
                        action: insertAction
                        implicitWidth: 28
                        implicitHeight: 24
                    }
                    Button {
                        action: overwriteAction
                        implicitWidth: 28
                        implicitHeight: 24
                    }
                }
            }
            Flickable {
                // Non-slider scroll area for the track headers.
                contentY: scrollView.flickableItem.contentY
                width: headerWidth
                height: trackHeaders.height
                interactive: false

                Column {
                    id: trackHeaders
                    Repeater {
                        model: multitrack
                        TrackHead {
                            trackName: model.name
                            isMute: model.mute
                            isHidden: model.hidden
                            isComposite: model.composite
                            isVideo: !model.audio
                            color: (index === currentTrack)? selectedTrackColor : (index % 2)? activePalette.alternateBase : activePalette.base
                            width: headerWidth
                            height: model.audio? trackHeight : trackHeight * 2
                            onClicked: currentTrack = index
                            onRightClick: menu.popup()
                        }
                    }
                }
                Rectangle {
                    // thin dividing line between headers and tracks
                    color: activePalette.windowText
                    width: 1
                    x: parent.x + parent.width
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }
            }
            Rectangle {
                color: activePalette.window
                height: root.height - trackHeaders.height - ruler.height + 4
                width: headerWidth

                Slider {
                    id: scaleSlider
                    orientation: Qt.Horizontal
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: 4
                        rightMargin: 4
                    }
                    minimumValue: 0
                    maximumValue: 1
                    value: 0.5
                    onValueChanged: {
                        if (typeof root.scaleFactor != 'undefined')
                            root.scaleFactor = Math.pow(value, 3) + 0.01
                        if (typeof scrollIfNeeded != 'undefined')
                            scrollIfNeeded()
                    }
                    onPressedChanged: {
                        if (!pressed) {
                            for (var i = 0; i < tracksRepeater.count; i++)
                                tracksRepeater.itemAt(i).redrawWaveforms()
                        }
                    }
                }
            }
        }

        MouseArea {
            width: root.width - headerWidth
            height: root.height

            // This provides continuous scrubbing and scimming at the left/right edges.
            focus: true
            hoverEnabled: true
            property bool scim: false
            Keys.onPressed: scim = (event.modifiers === Qt.ShiftModifier)
            Keys.onReleased: scim = false
            onReleased: scrubTimer.stop()
            onMouseXChanged: {
                if (scim || pressedButtons === Qt.LeftButton) {
                    timeline.position = (scrollView.flickableItem.contentX + mouse.x) / scaleFactor
                    if ((scrollView.flickableItem.contentX > 0 && mouse.x < 50) || (mouse.x > scrollView.width - 50))
                        scrubTimer.start()
                }
            }
            Timer {
                id: scrubTimer
                interval: 25
                repeat: true
                onTriggered: {
                    if (parent.scim || parent.pressedButtons === Qt.LeftButton) {
                        if (parent.mouseX < 50)
                            timeline.position -= 10
                        else if (parent.mouseX > scrollView.flickableItem.contentX - 50)
                            timeline.position += 10
                    }
                    if (parent.mouseX >= 50 && parent.mouseX <= scrollView.width - 50)
                        stop()
                }
            }
        

            Column {
                Flickable {
                    // Non-slider scroll area for the Ruler.
                    contentX: scrollView.flickableItem.contentX
                    width: root.width - headerWidth
                    height: ruler.height
                    interactive: false

                    Ruler {
                        id: ruler
                        width: tracksContainer.width
                        index: index
                        timeScale: scaleFactor
                    }
                }
                ScrollView {
                    id: scrollView
                    width: root.width - headerWidth
                    height: root.height - ruler.height
        
                    Item {
                        width: tracksContainer.width + headerWidth
                        height: trackHeaders.height + 30 // 30 is padding
                        Column {
                            // These make the striped background for the tracks.
                            // It is important that these are not part of the track visual hierarchy;
                            // otherwise, the clips will be obscured by the Track's background.
                            Repeater {
                                model: multitrack
                                delegate: Rectangle {
                                    width: tracksContainer.width
                                    color: (index === currentTrack)? selectedTrackColor : (index % 2)? activePalette.alternateBase : activePalette.base
                                    height: audio? trackHeight : trackHeight * 2
                                }
                            }
                        }
                        Column {
                            id: tracksContainer
                            Repeater { id: tracksRepeater; model: trackDelegateModel }
                        }
                    }
                }
            }
            Rectangle {
                id: cursor
                visible: timeline.position > -1
                color: activePalette.text
                width: 1
                height: root.height - scrollView.__horizontalScrollBar.height
                x: timeline.position * scaleFactor - scrollView.flickableItem.contentX
                y: 0
            }
            Canvas {
                id: playhead
                visible: timeline.position > -1
                x: timeline.position * scaleFactor - scrollView.flickableItem.contentX - 5
                y: 0
                width: 11
                height: 5
                property bool init: true
                onPaint: {
                    if (init) {
                        init = false;
                        var cx = getContext('2d');
                        cx.fillStyle = activePalette.windowText;
                        cx.beginPath();
                        // Start from the root-left point.
                        cx.lineTo(width, 0);
                        cx.lineTo(width / 2.0, height);
                        cx.lineTo(0, 0);
                        cx.fill();
                        cx.closePath();
                    }
                }
            }
        }
    }

    Rectangle {
        id: dropTarget
        height: trackHeight
        opacity: 0.5
        visible: false
        Text {
            anchors.fill: parent
            anchors.leftMargin: 100
            text: qsTr('Append')
            style: Text.Outline
            styleColor: 'white'
            font.pixelSize: parent.height * 0.8
            verticalAlignment: Text.AlignVCenter
        }
    }

    Menu {
        id: menu
        MenuItem {
            text: qsTr('Add Audio Track')
            shortcut: qsTr('Ctrl+U')
            onTriggered: timeline.addAudioTrack();
        }
        MenuItem {
            text: qsTr('Add Video Track')
            shortcut: qsTr('Ctrl+Y')
            onTriggered: timeline.addVideoTrack();
        }
        MenuItem {
            enabled: trackHeight >= 50
            text: qsTr('Make Tracks Shorter')
            shortcut: qsTr('Ctrl+K')
            onTriggered: trackHeight = Math.max(30, trackHeight - 20)
        }
        MenuItem {
            text: qsTr('Make Tracks Taller')
            shortcut: qsTr('Ctrl+L')
            onTriggered: trackHeight += 20
        }
        MenuItem {
            text: qsTr('Close')
            shortcut: qsTr('Ctrl+W')
            onTriggered: timeline.close()
        }
    }

    Action {
        id: menuAction
        tooltip: qsTr('Display a menu of additional actions')
        iconName: 'format-justify-fill'
        iconSource: 'qrc:///icons/oxygen/16x16/actions/format-justify-fill.png'
        onTriggered: menu.popup()
    }

    Action {
        id: appendAction
        tooltip: qsTr('Append to the current track')
        iconName: 'list-add'
        iconSource: 'qrc:///icons/oxygen/16x16/actions/list-add.png'
        onTriggered: timeline.append(currentTrack)
    }

    Action {
        id: liftAction
        tooltip: qsTr('Lift - Remove current clip without\naffecting position of other clips')
        iconName: 'list-remove'
        iconSource: 'qrc:///icons/oxygen/16x16/actions/list-remove.png'
        onTriggered: timeline.lift(currentClipTrack, currentClip)
    }

    Action {
        id: insertAction
        tooltip: qsTr('Insert clip into the current track')
        iconName: 'go-next'
        iconSource: 'qrc:///icons/oxygen/16x16/actions/go-next.png'
        onTriggered: timeline.insert(currentTrack)
    }

    Action {
        id: overwriteAction
        tooltip: qsTr('Overwrite clip onto the current track')
        iconName: 'go-down'
        iconSource: 'qrc:///icons/oxygen/16x16/actions/go-down.png'
        onTriggered: timeline.overwrite(currentTrack)
    }

    Keys.onUpPressed: timeline.selectTrack(-1)
    Keys.onDownPressed: timeline.selectTrack(1)
    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_B:
            timeline.overwrite(currentTrack)
            break;
        case Qt.Key_C:
            timeline.append(currentTrack)
            break;
        case Qt.Key_V:
            timeline.insert(currentTrack)
            break;
        case Qt.Key_X:
            timeline.remove(currentClipTrack, currentClip)
            currentClip = -1
            break;
        case Qt.Key_Z:
            timeline.lift(currentClipTrack, currentClip)
            currentClip = -1
            break;
        case Qt.Key_Delete:
        case Qt.Key_Backspace:
            if (event.modifiers & Qt.ShiftModifier)
                timeline.remove(currentClipTrack, currentClip)
            else
                timeline.lift(currentClipTrack, currentClip)
            currentClip = -1
            break;
        case Qt.Key_Equal:
            scaleSlider.value += 0.0625
            for (var i = 0; i < tracksRepeater.count; i++)
                tracksRepeater.itemAt(i).redrawWaveforms()
            break;
        case Qt.Key_Minus:
            scaleSlider.value -= 0.0625
            for (var i = 0; i < tracksRepeater.count; i++)
                tracksRepeater.itemAt(i).redrawWaveforms()
            break;
        case Qt.Key_0:
            scaleSlider.value = 0.5
            for (var i = 0; i < tracksRepeater.count; i++)
                tracksRepeater.itemAt(i).redrawWaveforms()
            break;
        default:
            timeline.pressKey(event.key, event.modifiers)
            break;
        }
    }
    Keys.onReleased: {
        switch (event.key) {
        case Qt.Key_B:
        case Qt.Key_C:
        case Qt.Key_V:
        case Qt.Key_X:
        case Qt.Key_Z:
        case Qt.Key_Delete:
        case Qt.Key_Backspace:
        case Qt.Key_Equal:
        case Qt.Key_Minus:
        case Qt.Key_0:
            break;
        default:
            timeline.releaseKey(event.key, event.modifiers)
            break;
        }
    }

    DelegateModel {
        id: trackDelegateModel
        model: multitrack
        Track {
            model: multitrack
            rootIndex: trackDelegateModel.modelIndex(index)
            height: audio? trackHeight : trackHeight * 2
            width: childrenRect.width
            isAudio: audio
            timeScale: scaleFactor
            onClipSelected: {
                currentClip = clip.DelegateModel.itemsIndex
                currentClipTrack = track.DelegateModel.itemsIndex
                for (var i = 0; i < tracksRepeater.count; i++)
                    if (i !== track.DelegateModel.itemsIndex) tracksRepeater.itemAt(i).resetStates();
                timeline.selectClip(currentClipTrack, currentClip)
            }
            onClipDragged: {
                // This provides continuous scrolling at the left/right edges.
                if (x > scrollView.flickableItem.contentX + scrollView.width - 50) {
                    scrollTimer.item = clip
                    scrollTimer.backwards = false
                    scrollTimer.start()
                } else if (x < 50) {
                    scrollView.flickableItem.contentX = 0;
                    scrollTimer.stop()
                } else if (x < scrollView.flickableItem.contentX + 50) {
                    scrollTimer.item = clip
                    scrollTimer.backwards = true
                    scrollTimer.start()
                } else {
                    scrollTimer.stop()
                }
            }
            onClipDropped: scrollTimer.running = false
            onClipDraggedToTrack: {
                var i = clip.trackIndex + direction
                if (i >= 0  && i < tracksRepeater.count) {
                    var track = tracksRepeater.itemAt(i)
                    clip.reparent(track)
                    clip.trackIndex = track.DelegateModel.itemsIndex
                }
            }
            onCheckSnap: {
                for (var i = 0; i < tracksRepeater.count; i++)
                    tracksRepeater.itemAt(i).snapClip(clip)
            }
        }
    }
    
    Connections {
        target: timeline
        onPositionChanged: scrollIfNeeded()
        onDragging: {
            if (tracksRepeater.count > 0) {
                dropTarget.x = pos.x
                dropTarget.y = pos.y
                dropTarget.width = duration * scaleFactor
                dropTarget.visible = true

                for (var i = 0; i < tracksRepeater.count; i++) {
                    var trackY = tracksRepeater.itemAt(i).y
                    var trackH = tracksRepeater.itemAt(i).height
                    if (pos.y >= trackY && pos.y < trackY + trackH) {
                        currentTrack = i
                        break
                    }
                }

                // Scroll tracks if at edges.
                if (pos.x > headerWidth + scrollView.width - 50) {
                    scrollTimer.backwards = false
                    scrollTimer.start()
                } else if (pos.x >= headerWidth && pos.x < headerWidth + 50) {
                    if (scrollView.flickableItem.contentX < 50) {
                        scrollView.flickableItem.contentX = 0;
                        scrollTimer.stop()
                    } else {
                        scrollTimer.backwards = true
                        scrollTimer.start()
                    }
                } else {
                    scrollTimer.stop()
                }
            }
        }
        onDropped: {
            dropTarget.visible = false
            scrollTimer.running = false
        }
    }

    // This provides continuous scrolling at the left/right edges.
    Timer {
        id: scrollTimer
        interval: 25
        repeat: true
        triggeredOnStart: true
        property var item
        property bool backwards
        onTriggered: {
            var delta = backwards? -10 : 10
            if (item) item.x += delta
            scrollView.flickableItem.contentX += delta
            if (scrollView.flickableItem.contentX <= 0)
                stop()
        }
    }

    function scrollIfNeeded() {
        var x = timeline.position * scaleFactor;
        if (x > scrollView.flickableItem.contentX + scrollView.width - 50)
            scrollView.flickableItem.contentX = x - scrollView.width + 50;
        else if (x < 50)
            scrollView.flickableItem.contentX = 0;
        else if (x < scrollView.flickableItem.contentX + 50)
            scrollView.flickableItem.contentX = x - 50;
    }

    function trackCount() {
        return tracksRepeater.count
    }
}
