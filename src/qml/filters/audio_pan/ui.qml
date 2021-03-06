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

import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Shotcut.Controls 1.0

Rectangle {
    width: 400
    height: 200
    color: 'transparent'
    Component.onCompleted: {
        if (filter.isNew) {
            // Set default parameter values
            combo.value = 0
            slider.value = 0
        } else {
            // Initialize parameter values
            combo.value = filter.get('channel')
            slider.value = filter.get('start') * slider.maximumValue
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8

        RowLayout {
            spacing: 8
            Label { text: qsTr('Channel') }
            ComboBox {
                id: combo
                model: [qsTr('Left'), qsTr('Right')]
                onCurrentIndexChanged: filter.set('channel', currentIndex)
            }
        }
        RowLayout {
            spacing: 8
    
            Label { text: qsTr('Left') }
            Slider {
                id: slider
                Layout.fillWidth: true
                Layout.minimumWidth: 100
                minimumValue: 0
                maximumValue: 1000
                onValueChanged: {
                    spinner.value = value / maximumValue
                    filter.set('start', value / maximumValue)
                }
            }
            Label { text: qsTr('Right') }
            SpinBox {
                id: spinner
                Layout.minimumWidth: 70
                decimals: 2
                minimumValue: 0
                maximumValue: 1
                onValueChanged: slider.value = value * slider.maximumValue
            }
            UndoButton {
                onClicked: slider.value = 0
            }
        }
        Item {
            Layout.fillHeight: true;
        }
    }
}
