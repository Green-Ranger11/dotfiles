import QtQuick
import QtQuick.Layouts

// A module with an icon and a value, both on the green ramp.
Segment {
    id: stat
    property string icon: ""
    property color iconColor: Theme.iconOn
    property string value: ""
    property color valueColor: Theme.mainFg

    padding: 8

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: stat.icon
        color: stat.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize

        Behavior on color {
            ColorAnimation { duration: 300 }
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
