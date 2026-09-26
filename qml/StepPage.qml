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

// One step of the tour: a title, a short explanation and the step's content
Item {
    id: page

    property alias title: _title.text
    property alias subtitle: _subtitle.text
    default property alias content: _content.data

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: LingmoUI.Units.largeSpacing * 3
        anchors.rightMargin: LingmoUI.Units.largeSpacing * 3
        anchors.topMargin: LingmoUI.Units.smallSpacing
        spacing: LingmoUI.Units.smallSpacing

        Label {
            id: _title
            Layout.fillWidth: true
            font.pointSize: LingmoUI.Theme.fontSize * 1.9
            font.weight: Font.Bold
            wrapMode: Text.WordWrap
        }

        Label {
            id: _subtitle
            Layout.fillWidth: true
            Layout.bottomMargin: LingmoUI.Units.largeSpacing
            color: LingmoUI.Theme.disabledTextColor
            font.pointSize: LingmoUI.Theme.fontSize * 1.05
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        ColumnLayout {
            id: _content
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: LingmoUI.Units.largeSpacing
        }
    }
}
