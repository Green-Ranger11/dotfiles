import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// openfortivpn@vodafone. Read the unit state directly; the toggle reuses the
// waybar script because it carries the polkit rule and the notifications.
Stat {
    id: vpn
    interactive: true

    property bool connected: false
    readonly property string unit: "openfortivpn@vodafone.service"

    Process {
        id: probe
        command: ["systemctl", "is-active", vpn.unit]
        stdout: StdioCollector {
            onStreamFinished: vpn.connected = text.trim() === "active"
        }
    }

    Process { id: toggle }

    Component.onCompleted: probe.running = true
    Timer { running: true; interval: 10000; repeat: true; onTriggered: probe.running = true }

    // openfortivpn brings ppp0 up/down; any link change re-probes at once, so
    // toggles from the network menu or Super+Shift+W show without the 10s lag.
    Process {
        running: true
        command: ["ip", "-o", "monitor", "link"]
        stdout: SplitParser { onRead: probe.running = true }
    }

    // oct-shield_check when up, cod-shield when down
    icon: connected ? "\uf510" : "\ueb53"
    iconColor: connected ? Theme.iconOn : Theme.iconDim
    value: connected ? "VPN" : ""
    valueColor: Theme.accent

    onClicked: {
        toggle.command = ["sh", Quickshell.env("HOME") + "/.config/waybar/scripts/vpn.sh", "toggle"];
        toggle.running = true;
    }

    // The unit blocks while connecting, so re-probe when the toggle returns.
    Connections {
        target: toggle
        function onExited() { probe.running = true; }
    }
}
