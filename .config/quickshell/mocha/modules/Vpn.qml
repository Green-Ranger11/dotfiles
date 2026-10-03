import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// openfortivpn@vodafone. Read the unit state directly; the toggle reuses the
// shared vpn.sh because it carries the polkit rule and the notifications.
Stat {
    id: vpn
    interactive: true

    // systemctl is-active: active / activating / deactivating / inactive / failed.
    property string state: "inactive"
    readonly property bool connected: state === "active"
    // Type=notify, so the unit sits in "activating" for the whole handshake.
    readonly property bool busy: toggle.running || Sys.vpnToggling
        || state === "activating" || state === "deactivating"
    readonly property string unit: "openfortivpn@vodafone.service"

    Process {
        id: probe
        command: ["systemctl", "is-active", vpn.unit]
        stdout: StdioCollector {
            onStreamFinished: vpn.state = text.trim()
        }
    }

    Process { id: toggle }

    Component.onCompleted: probe.running = true
    // 10s at rest; 500ms while a connect/disconnect is in flight.
    Timer { running: true; interval: vpn.busy ? 500 : 10000; repeat: true; onTriggered: probe.running = true }
    Connections {
        target: Sys
        function onVpnTogglingChanged() { probe.running = true; }
    }

    // openfortivpn brings ppp0 up/down; any link change re-probes at once, so
    // toggles from the network menu show without the 10s lag.
    Process {
        running: true
        command: ["ip", "-o", "monitor", "link"]
        stdout: SplitParser { onRead: probe.running = true }
    }

    // cod-loading spinning while busy, oct-shield_check when up, cod-shield when down
    icon: busy ? "\ueb19" : connected ? "\uf510" : "\ueb53"
    iconColor: busy ? Theme.accent : connected ? Theme.iconOn : Theme.iconDim
    spinning: busy
    value: busy ? (connected || state === "deactivating" ? "…" : "VPN…") : connected ? "VPN" : ""
    valueColor: Theme.accent

    onClicked: {
        toggle.command = ["sh", Quickshell.env("HOME") + "/.config/scripts/vpn.sh", "toggle"];
        toggle.running = true;
    }

    // The unit blocks while connecting, so re-probe when the toggle returns.
    Connections {
        target: toggle
        function onExited() { probe.running = true; }
    }
}
