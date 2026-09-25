import QtQuick
import QtQuick.Layouts
import ".."

// Accent tick at the very start of the bar.
Segment {
    padding: 6

    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 3
        implicitHeight: 16
        color: Theme.accent
    }
}
