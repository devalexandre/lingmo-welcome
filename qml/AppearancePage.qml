/*
 * Copyright (C) 2026 LingmoOS Team.
 *
 * Author:     devalexandre <alexandre@dev2learn.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LingmoUI.CompatibleModule 3.0 as LingmoUI

StepPage {
    id: page

    title: qsTr("Appearance")
    subtitle: qsTr("Pick the look you like best. It changes right away.")

    // Same order as the settings daemon's accent colors
    readonly property var accentColors: [
        LingmoUI.Theme.blueColor, LingmoUI.Theme.redColor, LingmoUI.Theme.greenColor,
        LingmoUI.Theme.purpleColor, LingmoUI.Theme.pinkColor, LingmoUI.Theme.orangeColor,
        LingmoUI.Theme.greyColor
    ]
    readonly property color accent: accentColors[welcome.accentColor] || LingmoUI.Theme.highlightColor

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.maximumHeight: 300
        spacing: LingmoUI.Units.largeSpacing * 3

        ThemePreview {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("Light")
            dark: false
            accent: page.accent
            checked: !LingmoUI.Theme.darkMode
            onClicked: welcome.setDarkMode(false)
        }

        ThemePreview {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("Dark")
            dark: true
            accent: page.accent
            checked: LingmoUI.Theme.darkMode
            onClicked: welcome.setDarkMode(true)
        }
    }

    Card {
        Layout.topMargin: LingmoUI.Units.largeSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: LingmoUI.Units.largeSpacing

            Label {
                text: qsTr("Accent color")
                Layout.fillWidth: true
            }

            Repeater {
                model: page.accentColors

                delegate: Item {
                    id: dot
                    readonly property bool checked: welcome.accentColor === index
                    width: 34
                    height: 34

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.width: dot.checked || dotMouse.containsMouse ? 2.5 : 0
                        border.color: Qt.rgba(modelData.r, modelData.g, modelData.b, dot.checked ? 0.7 : 0.35)
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        radius: 12
                        color: modelData
                        scale: dotMouse.pressed ? 0.88 : 1
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 8
                            height: 8
                            radius: 4
                            color: "white"
                            scale: dot.checked ? 1 : 0
                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                        }
                    }

                    MouseArea {
                        id: dotMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: welcome.setAccentColor(index)
                    }
                }
            }
        }
    }

    Item { Layout.fillHeight: true }
}
