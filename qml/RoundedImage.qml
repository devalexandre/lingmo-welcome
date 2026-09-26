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
import Qt5Compat.GraphicalEffects
import LingmoUI.CompatibleModule 3.0 as LingmoUI

// Picture cropped to fill a rounded rectangle, with a placeholder while it loads
Item {
    id: control

    property alias source: _image.source
    property alias status: _image.status
    property real radius: LingmoUI.Theme.bigRadius
    property size decodeSize: Qt.size(width * 1.5, height * 1.5)

    Rectangle {
        anchors.fill: parent
        radius: control.radius
        color: LingmoUI.Theme.alternateBackgroundColor
    }

    Image {
        id: _image
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: control.decodeSize
        asynchronous: true
        cache: true
        smooth: true
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: _image
        opacity: _image.status === Image.Ready ? 1 : 0
        maskSource: Rectangle {
            width: control.width
            height: control.height
            radius: control.radius
        }

        Behavior on opacity { NumberAnimation { duration: 250 } }
    }
}
