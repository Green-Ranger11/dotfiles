import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import ".."

Stat {
    id: bt
    interactive: true

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter?.enabled ?? false
    readonly property bool connected: Bluetooth.devices.values.some(d => d.connected)

    Process { id: proc }

    // fa-bluetooth
    icon: "\uf293"
    iconColor: !on ? Theme.iconDim : connected ? Theme.iconOn : Theme.iconMid

    onClicked: mouse => {
        // launcher/BluetoothPicker.qml
        proc.command = ["qs", "-p", Quickshell.env("HOME") + "/.config/quickshell/mocha", "ipc", "call", "bluetooth", "toggle"];
        proc.running = true;
    }
}
