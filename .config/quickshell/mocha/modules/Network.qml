import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import ".."

Stat {
    id: net
    interactive: true

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wired: Networking.devices.values.find(d => d.type === DeviceType.Wired) ?? null
    readonly property bool wiredUp: wired?.state === ConnectionState.Connected
    readonly property bool wifiUp: wifi?.state === ConnectionState.Connected
    readonly property int strength: wifi?.network?.signalStrength ?? 0

    Process { id: proc }

    // fa-ethernet when wired, cod-radio_tower on wifi
    icon: wiredUp ? "\uef44" : "\ueb34"
    iconColor: wiredUp || wifiUp ? Theme.iconOn : Theme.iconDim

    onClicked: mouse => {
        // Left: the Quickshell network menu (launcher/NetworkPicker.qml).
        // Right: gazelle for what that menu skips (enterprise Wi-Fi, IP settings).
        proc.command = mouse.button === Qt.LeftButton
            ? ["qs", "-p", Quickshell.env("HOME") + "/.config/quickshell/mocha", "ipc", "call", "network", "toggle"]
            : ["kitty", "--class", "gazelle", Quickshell.env("HOME") + "/.local/bin/gazelle"];
        proc.running = true;
    }
}
