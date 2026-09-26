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

LingmoUI.Window {
    id: root

    width: 880
    height: 620
    minimumWidth: 780
    minimumHeight: 580
    visible: false
    title: qsTr("Welcome")

    background.opacity: LingmoUI.Theme.darkMode ? 0.9 : 0.97
    header.height: 40

    readonly property int pageCount: 6
    readonly property int lastPage: pageCount - 1
    property int current: 0

    function go(index) {
        if (index >= 0 && index < pageCount)
            current = index
    }

    LingmoUI.WindowBlur {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: root.windowRadius
        enabled: true
    }

    // Arrow keys / Enter move between the steps
    Shortcut { sequence: "Right"; enabled: root.current > 0; onActivated: root.go(root.current + 1) }
    Shortcut { sequence: "Left"; enabled: root.current > 1; onActivated: root.go(root.current - 1) }

    // Each step slides in from the side it comes from and fades
    component Slot: Item {
        id: slot
        required property int index
        readonly property bool active: root.current === index

        width: stage.width
        height: stage.height
        x: active ? 0 : (index < root.current ? -60 : 60)
        opacity: active ? 1 : 0
        visible: opacity > 0
        enabled: active

        Behavior on x { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    }

    Item {
        id: stage
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: navBar.top

        Slot {
            index: 0
            HeroPage {
                anchors.fill: parent
                onStart: root.go(1)
                onSkip: welcome.finish()
            }
        }
        Slot { index: 1; AppearancePage { anchors.fill: parent } }
        Slot { index: 2; WallpaperPage { anchors.fill: parent } }
        Slot { index: 3; EffectsPage { anchors.fill: parent } }
        Slot { index: 4; ShortcutsPage { anchors.fill: parent } }
        Slot {
            id: doneSlot
            index: 5
            DonePage { anchors.fill: parent; active: doneSlot.active }
        }
    }

    // Skip · progress dots · Back / Next
    Item {
        id: navBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.current === 0 ? 0 : 72
        opacity: root.current === 0 ? 0 : 1
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 250 } }
        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        WelcomeButton {
            anchors.left: parent.left
            anchors.leftMargin: LingmoUI.Units.largeSpacing * 2
            anchors.verticalCenter: parent.verticalCenter
            flat: true
            text: qsTr("Skip")
            visible: root.current < root.lastPage
            onClicked: welcome.finish()
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: root.pageCount - 1

                Rectangle {
                    readonly property int step: index + 1
                    anchors.verticalCenter: parent.verticalCenter
                    height: 8
                    width: step === root.current ? 26 : 8
                    radius: 4
                    color: step <= root.current ? LingmoUI.Theme.highlightColor
                                                : (LingmoUI.Theme.darkMode ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.15))

                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 300 } }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.go(parent.step)
                    }
                }
            }
        }

        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: LingmoUI.Units.largeSpacing * 2
            anchors.verticalCenter: parent.verticalCenter
            spacing: LingmoUI.Units.largeSpacing

            WelcomeButton {
                text: qsTr("Back")
                onClicked: root.go(root.current - 1)
            }

            WelcomeButton {
                primary: true
                Layout.preferredWidth: Math.max(implicitWidth, 120)
                text: root.current === root.lastPage ? qsTr("Finish") : qsTr("Next")
                onClicked: root.current === root.lastPage ? welcome.finish() : root.go(root.current + 1)
            }
        }
    }
}
