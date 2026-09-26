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

// Last step: community links and whether to show the tour again
Item {
    id: page

    property bool active: false

    component LinkTile: Rectangle {
        id: tile

        property alias icon: _icon.source
        property alias text: _text.text
        property alias hint: _hint.text
        signal clicked()

        Layout.fillWidth: true
        Layout.preferredHeight: 150
        radius: LingmoUI.Theme.bigRadius
        color: mouse.containsMouse ? Qt.darker(LingmoUI.Theme.secondBackgroundColor, LingmoUI.Theme.darkMode ? 0.85 : 1.03)
                                   : LingmoUI.Theme.secondBackgroundColor
        scale: mouse.pressed ? 0.97 : 1
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 120 } }

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - LingmoUI.Units.largeSpacing * 2
            spacing: LingmoUI.Units.smallSpacing

            LingmoUI.IconItem {
                id: _icon
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.bottomMargin: LingmoUI.Units.smallSpacing
                smooth: true
            }

            Label {
                id: _text
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Label {
                id: _hint
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: LingmoUI.Theme.disabledTextColor
                font.pointSize: LingmoUI.Theme.fontSize * 0.9
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.clicked()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: LingmoUI.Units.largeSpacing * 3
        anchors.rightMargin: LingmoUI.Units.largeSpacing * 3
        spacing: LingmoUI.Units.largeSpacing

        Item { Layout.fillHeight: true; Layout.maximumHeight: LingmoUI.Units.largeSpacing * 2 }

        // Check mark that draws itself when the page opens
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 76
            height: 76
            radius: 38
            color: LingmoUI.Theme.highlightColor
            scale: page.active ? 1 : 0.6
            Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }

            Canvas {
                id: check
                anchors.fill: parent
                property real progress: page.active ? 1 : 0
                Behavior on progress { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                onProgressChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = "white"
                    ctx.lineWidth = 6
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    const p = [[0.29, 0.52], [0.44, 0.66], [0.72, 0.37]]
                    const first = Math.hypot(p[1][0] - p[0][0], p[1][1] - p[0][1])
                    const second = Math.hypot(p[2][0] - p[1][0], p[2][1] - p[1][1])
                    let length = (first + second) * progress
                    ctx.beginPath()
                    ctx.moveTo(width * p[0][0], height * p[0][1])
                    const a = Math.min(1, length / first)
                    ctx.lineTo(width * (p[0][0] + (p[1][0] - p[0][0]) * a), height * (p[0][1] + (p[1][1] - p[0][1]) * a))
                    if (length > first) {
                        const b = Math.min(1, (length - first) / second)
                        ctx.lineTo(width * (p[1][0] + (p[2][0] - p[1][0]) * b), height * (p[1][1] + (p[2][1] - p[1][1]) * b))
                    }
                    ctx.stroke()
                }
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.topMargin: LingmoUI.Units.smallSpacing
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("You're all set!")
            font.pointSize: LingmoUI.Theme.fontSize * 2.1
            font.weight: Font.Bold
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Enjoy ArchLingmo. Come say hi to the community, and find everything else in Settings.")
            color: LingmoUI.Theme.disabledTextColor
            font.pointSize: LingmoUI.Theme.fontSize * 1.05
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: LingmoUI.Units.largeSpacing
            spacing: LingmoUI.Units.largeSpacing * 1.5

            LinkTile {
                icon: "discord"
                text: qsTr("Join the Discord")
                hint: qsTr("Chat, help and news")
                onClicked: welcome.openUrl("https://discord.gg/pykAf7uMy")
            }

            LinkTile {
                icon: "internet-web-browser"
                text: qsTr("Website")
                hint: qsTr("Downloads and documentation")
                onClicked: welcome.openUrl("https://devalexandre.github.io/archlingmo/")
            }

            LinkTile {
                icon: "preferences-system"
                text: qsTr("Settings")
                hint: qsTr("Everything else you can change")
                onClicked: welcome.openSettings()
            }
        }

        CheckBox {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: LingmoUI.Units.largeSpacing
            text: qsTr("Show at startup")
            checked: welcome.showOnStartup
            onToggled: welcome.showOnStartup = checked
        }

        Item { Layout.fillHeight: true }
    }
}
