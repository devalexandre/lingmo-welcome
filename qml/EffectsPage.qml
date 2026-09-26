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

    title: qsTr("Effects")
    subtitle: qsTr("A touch of fun for your windows. Try them and keep the ones you like.")

    // One switch: its state comes from kwinrc, a click writes it back
    component EffectRow: RowLayout {
        id: row

        property alias title: _title.text
        property string description
        property string icon
        property bool supported: true
        property bool checked: false
        signal toggled(bool checked)

        Layout.fillWidth: true
        spacing: LingmoUI.Units.largeSpacing * 1.5

        LingmoUI.IconItem {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            source: row.icon
            smooth: true
            opacity: row.supported ? 1 : 0.5
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                id: _title
                Layout.fillWidth: true
                font.weight: Font.DemiBold
                opacity: row.supported ? 1 : 0.6
            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: row.supported ? row.description : qsTr("Requires video acceleration (GPU)")
                color: row.supported ? LingmoUI.Theme.disabledTextColor : LingmoUI.Theme.orangeColor
            }
        }

        Switch {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            rightPadding: 0
            enabled: row.supported
            checked: row.supported && row.checked
            onToggled: row.toggled(checked)
        }
    }

    component Divider: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: LingmoUI.Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.07)
    }

    Card {
        spacing: LingmoUI.Units.largeSpacing * 1.2

        EffectRow {
            Layout.topMargin: LingmoUI.Units.smallSpacing
            icon: "preferences-system-windows-move"
            title: qsTr("Wobbly windows")
            description: qsTr("Windows jiggle like jelly while you drag them around.")
            supported: welcome.isEffectSupported("wobblywindows")
            checked: welcome.revision >= 0 && welcome.isEffectEnabled("wobblywindows")
            onToggled: (on) => welcome.setEffectEnabled("wobblywindows", on)
        }

        Divider {}

        EffectRow {
            icon: "desktop-effects"
            title: qsTr("Magic lamp when minimizing")
            description: qsTr("Windows slide into the dock like a genie going back into its lamp.")
            supported: welcome.isEffectSupported("magiclamp")
            checked: welcome.revision >= 0 && welcome.isEffectEnabled("magiclamp")
            onToggled: (on) => welcome.setMagicLamp(on)
        }

        Divider {}

        EffectRow {
            Layout.bottomMargin: LingmoUI.Units.smallSpacing
            icon: "preferences-system-windows"
            title: qsTr("Alt+Tab page flip")
            description: qsTr("Flip through your windows like the pages of a book instead of a strip of previews.")
            checked: welcome.switcherLayout === "ling_flip"
            onToggled: (on) => welcome.setSwitcherLayout(on ? "ling_flip" : "ling_thumbnail")
        }
    }

    WelcomeButton {
        Layout.topMargin: LingmoUI.Units.smallSpacing
        text: qsTr("More effects in Settings")
        onClicked: welcome.openSettings("effects")
    }

    Item { Layout.fillHeight: true }
}
