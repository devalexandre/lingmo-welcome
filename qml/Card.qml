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
import QtQuick.Layouts
import LingmoUI.CompatibleModule 3.0 as LingmoUI

// Rounded panel in the style of Lingmo Settings' RoundedItem
Rectangle {
    default property alias content: _layout.data
    property alias spacing: _layout.spacing

    Layout.fillWidth: true
    color: LingmoUI.Theme.secondBackgroundColor
    radius: LingmoUI.Theme.bigRadius
    implicitHeight: _layout.implicitHeight + _layout.anchors.topMargin + _layout.anchors.bottomMargin

    Behavior on color { ColorAnimation { duration: 200 } }

    ColumnLayout {
        id: _layout
        anchors.fill: parent
        anchors.leftMargin: LingmoUI.Units.largeSpacing * 1.5
        anchors.rightMargin: LingmoUI.Units.largeSpacing * 1.5
        anchors.topMargin: LingmoUI.Units.largeSpacing
        anchors.bottomMargin: LingmoUI.Units.largeSpacing
        spacing: LingmoUI.Units.largeSpacing
    }
}
