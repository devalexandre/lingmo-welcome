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
import Qt5Compat.GraphicalEffects
import LingmoUI.CompatibleModule 3.0 as LingmoUI

// Selectable miniature desktop drawn in the light or dark theme
Item {
    id: control

    property bool dark: false
    property bool checked: false
    property alias text: _label.text
    property color accent: LingmoUI.Theme.highlightColor

    signal clicked()

    implicitHeight: _column.implicitHeight

    readonly property color windowColor: dark ? "#2C2C2D" : "#FFFFFF"
    readonly property color barColor: dark ? "#3C3C3D" : "#E9EBF1"
    readonly property color lineColor: dark ? "#58585C" : "#D3D6DE"

    ColumnLayout {
        id: _column
        anchors.fill: parent
        spacing: LingmoUI.Units.largeSpacing

        Rectangle {
            id: frame
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: width * 0.62
            radius: LingmoUI.Theme.hugeRadius
            color: "transparent"
            border.width: 3
            border.color: control.checked ? control.accent
                                          : mouse.containsMouse ? Qt.rgba(control.accent.r, control.accent.g, control.accent.b, 0.4)
                                                                : "transparent"
            scale: mouse.pressed ? 0.98 : 1

            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 120 } }

            // Desktop
            Rectangle {
                id: desk
                anchors.fill: parent
                anchors.margins: 6
                radius: LingmoUI.Theme.bigRadius
                // Keep the status bar inside the rounded corners
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: desk.width
                        height: desk.height
                        radius: desk.radius
                    }
                }
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: control.dark ? "#3A2F6B" : "#9CC3F5" }
                    GradientStop { position: 1.0; color: control.dark ? "#141A33" : "#E9D8F7" }
                }

                // Status bar
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * 0.07
                    color: control.dark ? Qt.rgba(0, 0, 0, 0.35) : Qt.rgba(1, 1, 1, 0.55)
                }

                // Back window
                Rectangle {
                    x: parent.width * 0.42
                    y: parent.height * 0.17
                    width: parent.width * 0.48
                    height: parent.height * 0.48
                    radius: 6
                    color: control.windowColor
                    opacity: 0.85
                }

                // Front window
                Rectangle {
                    x: parent.width * 0.1
                    y: parent.height * 0.24
                    width: parent.width * 0.52
                    height: parent.height * 0.52
                    radius: 6
                    color: control.windowColor

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: parent.height * 0.18
                        radius: 6
                        color: control.barColor

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 6
                            spacing: 3
                            Repeater {
                                model: ["#FF5F57", "#FEBC2E", "#28C840"]
                                Rectangle { width: 5; height: 5; radius: 2.5; color: modelData }
                            }
                        }
                    }

                    Column {
                        x: parent.width * 0.1
                        y: parent.height * 0.32
                        width: parent.width * 0.8
                        spacing: parent.height * 0.08
                        Rectangle { width: parent.width * 0.9; height: 4; radius: 2; color: control.lineColor }
                        Rectangle { width: parent.width * 0.6; height: 4; radius: 2; color: control.lineColor }
                        Rectangle { width: parent.width * 0.35; height: 10; radius: 5; color: control.accent }
                    }
                }

                // Dock
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: parent.height * 0.04
                    width: parent.width * 0.5
                    height: parent.height * 0.12
                    radius: height * 0.3
                    color: control.dark ? Qt.rgba(0.17, 0.17, 0.18, 0.85) : Qt.rgba(1, 1, 1, 0.75)

                    Row {
                        anchors.centerIn: parent
                        spacing: parent.height * 0.25
                        Repeater {
                            model: 5
                            Rectangle {
                                width: parent.parent.height * 0.6
                                height: width
                                radius: width * 0.28
                                color: index === 0 ? control.accent : control.lineColor
                            }
                        }
                    }
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: control.clicked()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: LingmoUI.Units.smallSpacing

            // Radio mark
            Rectangle {
                width: 16
                height: 16
                radius: 8
                color: control.checked ? control.accent : "transparent"
                border.width: control.checked ? 0 : 1.5
                border.color: LingmoUI.Theme.disabledTextColor

                Rectangle {
                    anchors.centerIn: parent
                    width: 6
                    height: 6
                    radius: 3
                    color: "white"
                    visible: control.checked
                }
            }

            Label {
                id: _label
                font.weight: control.checked ? Font.DemiBold : Font.Normal
            }
        }
    }
}
