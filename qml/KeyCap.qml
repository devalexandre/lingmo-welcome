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
import LingmoUI.CompatibleModule 3.0 as LingmoUI

// A keyboard key drawn as a small raised cap
Rectangle {
    property alias text: _label.text

    implicitWidth: Math.max(implicitHeight, _label.implicitWidth + LingmoUI.Units.largeSpacing * 1.2)
    implicitHeight: 28
    radius: 7
    color: LingmoUI.Theme.darkMode ? "#46464A" : "#FFFFFF"
    border.width: 1
    border.color: LingmoUI.Theme.darkMode ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.14)

    // Bottom edge of the key
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        height: 3
        radius: parent.radius
        z: -1
        anchors.bottomMargin: -2
        color: LingmoUI.Theme.darkMode ? "#2A2A2D" : "#D5D7DE"
    }

    Label {
        id: _label
        anchors.centerIn: parent
        font.pointSize: LingmoUI.Theme.fontSize * 0.92
        font.weight: Font.DemiBold
    }
}
