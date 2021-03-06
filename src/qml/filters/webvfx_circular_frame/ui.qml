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
import QtQuick.Dialogs 1.0
import Shotcut.Controls 1.0

Rectangle {
    width: 400
    height: 200
    color: 'transparent'
    Component.onCompleted: {
        if (filter.isNew) {
            filter.set('resource', filter.path + 'filter-demo.html')
            // Set default parameter values
            slider.value = 50
            colorSwatch.color = 'black'
        } else {
            // Initialize parameter values
            slider.value = filter.get('radius') * slider.maximumValue
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8

        RowLayout {
            anchors.fill: parent
            spacing: 8
    
            Label { text: qsTr('Radius') }
            Slider {
                id: slider
                Layout.fillWidth: true
                Layout.minimumWidth: 100
                minimumValue: 0
                maximumValue: 100
                onValueChanged: {
                    spinner.value = value
                    filter.set('radius', value / maximumValue)
                }
            }
            SpinBox {
                id: spinner
                Layout.minimumWidth: 70
                suffix: ' %'
                minimumValue: 0
                maximumValue: 100
                onValueChanged: slider.value = value
            }
            UndoButton {
                onClicked: slider.value = 50
            }
        }

        RowLayout {
            Button {
                text: qsTr('Color')
                onClicked: colorDialog.visible = true
            }
            Rectangle {
                id: colorSwatch
                width: 20
                height: 20
                color: filter.get('color')
            }
        }

        Item {
            Layout.fillHeight: true;
        }
    }

    ColorDialog {
        id: colorDialog
        title: qsTr("Please choose a color")
        showAlphaChannel: false
        onAccepted: {
            // The "''+" hack converts the color into a string.
            filter.set('color', ''+ colorDialog.color)
            colorSwatch.color = colorDialog.color
            console.log("You chose: " + colorDialog.color)
        }
    }
}
