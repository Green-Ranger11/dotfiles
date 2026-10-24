import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// openfortivpn@vodafone, through the shared vpn.sh: it carries the polkit
// rule and the notifications, and on macOS (no systemd) runs the tunnel itself.
Stat {
    id: vpn
    interactive: true
    visible: state !== "missing"

    // vpn.sh status (systemctl is-active): active / activating / deactivating / inactive / failed,
    // or missing (no /etc/openfortivpn/vodafone.conf on this machine: hidden).
    property string state: "missing"
    readonly property bool connected: state === "active"
    // Type=notify, so the unit sits in "activating" for the whole handshake.
    readonly property bool busy: toggle.running || Sys.vpnToggling
        || state === "activating" || state === "deactivating"
    readonly property string script: Quickshell.env("HOME") + "/.config/scripts/vpn.sh"

    Process {
        id: probe
        command: ["sh", vpn.script, "status"]
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
    // toggles from the network menu show without the 10s lag. macOS has no
    // ip(8); its routing socket reports the same link changes (RTM_IF* lines,
    // among route and ARP noise).
    Process {
        id: linkMonitor
        readonly property bool mac: Qt.platform.os === "osx"
        running: vpn.visible
        command: mac ? ["route", "-n", "monitor"] : ["ip", "-o", "monitor", "link"]
        stdout: SplitParser {
            onRead: data => {
                if (!linkMonitor.mac || data.startsWith("RTM_IF")) probe.running = true;
            }
        }
    }

    // cod-loading spinning while busy, oct-shield_check when up, cod-shield when down
    icon: busy ? "\ueb19" : connected ? "\uf510" : "\ueb53"
    iconColor: busy ? Theme.accent : connected ? Theme.iconOn : Theme.iconDim
    spinning: busy
    value: busy ? (connected || state === "deactivating" ? "…" : "VPN…") : connected ? "VPN" : ""
    valueColor: Theme.accent

    onClicked: {
        toggle.command = ["sh", vpn.script, "toggle"];
        toggle.running = true;
    }

    // The unit blocks while connecting, so re-probe when the toggle returns.
    Connections {
        target: toggle
        function onExited() { probe.running = true; }
    }
}
