import QtQuick
import QtQuick.Layouts

// A module with an icon and a value, both on the green ramp.
Segment {
    id: stat
    property string icon: ""
    property color iconColor: Theme.iconOn
    property string value: ""
    property color valueColor: Theme.mainFg
    // Rotates the icon while true (VPN connecting). Icon snaps upright when it stops.
    property bool spinning: false

    padding: 8

    Text {
        id: glyph
        Layout.alignment: Qt.AlignVCenter
        text: stat.icon
        color: stat.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize

        Behavior on color {
            ColorAnimation { duration: 300 }
        }

        RotationAnimation on rotation {
            running: stat.spinning
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 900
        }
        Connections {
            target: stat
            function onSpinningChanged() { if (!stat.spinning) glyph.rotation = 0; }
        }
    }

    Label {
        Layout.alignment: Qt.AlignVCenter
        visible: stat.value !== ""
        text: stat.value
        color: stat.valueColor
        font.pixelSize: Theme.fontSize - 1
    }
}
