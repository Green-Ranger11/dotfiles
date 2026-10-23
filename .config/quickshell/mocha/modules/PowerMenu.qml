import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

Segment {
    id: seg
    interactive: true
    padding: 10

    Process { id: proc }

    onClicked: {
        // launcher/PowerPicker.qml (replaced waybar/scripts/power-menu.sh + rofi).
        proc.command = [Sys.shellCommand, "-p", Quickshell.shellDir, "ipc", "call", "power", "toggle"];
        proc.running = true;
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        // fa-power_off
        text: "\uf011"
        color: Theme.iconMid
        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize
    }
}
