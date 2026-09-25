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
        // Left: the Quickshell menu (launcher/BluetoothPicker.qml).
        // Right: bluetuith, for pairing devices that need a typed passkey.
        // foreground=green: bluetuith draws the selected row in reverse video
        // of the terminal default fg, so this is what turns the highlight green.
        proc.command = mouse.button === Qt.LeftButton
            ? ["qs", "-p", Quickshell.env("HOME") + "/.config/quickshell/mocha", "ipc", "call", "bluetooth", "toggle"]
            : ["kitty", "--class", "bluetuith", "-o", "foreground=#a6e3a1", "-e", "bluetuith"];
        proc.running = true;
    }
}
