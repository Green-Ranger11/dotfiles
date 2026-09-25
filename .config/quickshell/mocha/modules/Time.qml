import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// Time large, date small underneath: one block instead of two modules.
Segment {
    padding: 8

    SystemClock { id: clock; precision: SystemClock.Minutes }

    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 0

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.pixelSize: Theme.fontSize + 1
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(clock.date, "ddd dd MMM").toUpperCase()
            color: Theme.overlay0
            font.pixelSize: Theme.fontSize - 5
            font.weight: Font.Normal
        }
    }
}
