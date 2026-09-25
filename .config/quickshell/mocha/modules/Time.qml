import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// One line: time, then the date in a readable size and colour
// ("14:51  Fri 25 Sep"). The old two-line stack shrank the date to 9px grey.
Segment {
    padding: 8

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Label {
        text: Qt.formatDateTime(clock.date, "HH:mm")
    }

    Label {
        text: Qt.formatDateTime(clock.date, "ddd d MMM")
        color: Theme.subtext0
        font.weight: Font.Normal
    }
}
