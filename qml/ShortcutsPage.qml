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

    title: qsTr("Shortcuts")
    subtitle: qsTr("A few keys that make everyday work faster. Super is the key with the Windows logo.")

    readonly property var shortcuts: [
        { keys: ["Super"], text: qsTr("Open the launcher") },
        { keys: ["Super", qsTr("Space")], text: qsTr("Search with Spotlight") },
        { keys: ["Super", "D"], text: qsTr("Show the desktop") },
        { keys: ["Super", "W"], text: qsTr("Overview of all windows") },
        { keys: ["Alt", "Tab"], text: qsTr("Switch between windows") },
        { keys: ["Super", "↑ / ↓"], text: qsTr("Maximize / minimize") },
        { keys: ["Super", "Q"], text: qsTr("Close the window") },
        { keys: ["Ctrl", "Alt", "T"], text: qsTr("Open the terminal") },
        { keys: ["Print"], text: qsTr("Take a screenshot") },
        { keys: ["Super", "L"], text: qsTr("Lock the screen") },
        { keys: ["Super", "R"], text: qsTr("Reload the desktop") }
    ]

    Card {
        GridLayout {
            Layout.fillWidth: true
            Layout.topMargin: LingmoUI.Units.smallSpacing
            Layout.bottomMargin: LingmoUI.Units.smallSpacing
            columns: 2
            columnSpacing: LingmoUI.Units.largeSpacing * 3
            rowSpacing: LingmoUI.Units.largeSpacing * 0.9
            // Fill column by column so related keys stay together
            flow: GridLayout.TopToBottom
            rows: Math.ceil(page.shortcuts.length / 2)

            Repeater {
                model: page.shortcuts

                delegate: RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    spacing: LingmoUI.Units.largeSpacing

                    Row {
                        Layout.preferredWidth: 150
                        spacing: 4

                        Repeater {
                            model: modelData.keys
                            delegate: Row {
                                spacing: 4
                                Label {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "+"
                                    visible: index > 0
                                    color: LingmoUI.Theme.disabledTextColor
                                }
                                KeyCap { text: modelData }
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: modelData.text
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    WelcomeButton {
        Layout.topMargin: LingmoUI.Units.smallSpacing
        text: qsTr("Customize in Settings → Shortcuts")
        onClicked: welcome.openSettings("shortcuts")
    }

    Item { Layout.fillHeight: true }
}
