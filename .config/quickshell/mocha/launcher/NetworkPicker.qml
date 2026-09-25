import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import ".."

// Network menu: openfortivpn tunnels + Wi-Fi, in the shared picker chrome.
// Toggled over IPC (qs ipc call network toggle) and by the bar's network icon.
//
// ponytail: skipped - 802.1X/enterprise Wi-Fi, hidden SSIDs, IP settings.
// Use nmtui / nmcli (networkmanager) for those.
Scope {
    id: root

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    // [{ name, active }] from /etc/openfortivpn/<name>.conf; "config" is the
    // bare-openfortivpn default, not a unit instance.
    property var vpns: []
    // Network waiting on the password prompt.
    property var pending: null

    function toggle() { picker.toggle(); }

    // md-wifi_strength_1..4 (outline for ~0).
    function bars(s) {
        return s > 0.75 ? "\u{f0928}" : s > 0.5 ? "\u{f0925}" : s > 0.25 ? "\u{f0922}" : s > 0.05 ? "\u{f091f}" : "\u{f092f}";
    }
    function secured(n) {
        return n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Owe;
    }

    PickerList {
        id: picker
        title: "Network"
        countNoun: "entries"
        searchable: false
        hints: [["j/k", "navigate"], ["⏎", "connect"], ["d", "forget"], ["q", "close"]]
        // Fits your rows (VPNs, toggle, saved/connected networks) plus up to
        // 5 scanned ones; anything beyond that scrolls.
        boxHeight: {
            const scanned = entries.filter(e => e.data.net && !e.data.net.known && !e.data.net.connected).length;
            const rows = entries.length - scanned + Math.min(scanned, 5);
            return fitRows(rows, root.vpns.length > 0 ? 2 : 1);
        }

        // Scan only while the menu is up.
        onVisibleChanged: {
            if (root.wifi) root.wifi.scannerEnabled = visible;
            if (visible) vpnList.running = true;
        }

        entries: {
            const out = root.vpns.map(v => ({
                section: "VPN",
                text: (v.active ? "\u{f0582}  " : "\u{f0fc6}  ") + v.name,
                sub: v.active ? "connected" : "",
                color: v.active ? Theme.accent : undefined,
                data: { vpn: v.name }
            }));
            out.push({
                section: "Wi-Fi",
                text: Networking.wifiEnabled ? "\u{f05a9}  Wi-Fi on" : "\u{f05aa}  Wi-Fi off",
                sub: "enter to turn " + (Networking.wifiEnabled ? "off" : "on"),
                data: { radio: true },
                keep: true
            });
            if (root.wifi && Networking.wifiEnabled) {
                // Connected first, then saved, then by signal.
                const nets = root.wifi.networks.values.slice().sort((a, b) =>
                    (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength));
                for (const n of nets) {
                    const state = n.stateChanging ? "connecting…"
                        : n.connected ? "connected"
                        : n.known ? "saved" : "";
                    out.push({
                        section: "Wi-Fi",
                        text: root.bars(n.signalStrength) + "  " + n.name,
                        sub: [state, root.secured(n) ? "\u{f033e}" : "", Math.round(n.signalStrength * 100) + "%"]
                            .filter(x => x).join("  "),
                        data: { net: n },
                        color: n.connected ? Theme.accent : undefined
                    });
                }
            }
            return out;
        }

        onAccepted: e => {
            const d = e.data;
            if (d.vpn) {
                vpnToggle.exec(["sh", Quickshell.env("HOME") + "/.config/scripts/vpn.sh", "toggle", d.vpn]);
            } else if (d.radio) {
                Networking.wifiEnabled = !Networking.wifiEnabled;
            } else if (d.net.connected) {
                d.net.disconnect();
            } else if (d.net.known || !root.secured(d.net)) {
                d.net.connect();
            } else {
                root.pending = d.net;
                prompt.title = "Password for " + d.net.name;
                prompt.open();
            }
        }

        onRemoved: e => { if (e.data.net && e.data.net.known) e.data.net.forget(); }
    }

    PickerList {
        id: prompt
        password: true
        boxHeight: 124
        hints: [["⏎", "connect"], ["esc", "cancel"]]
        onSubmitted: t => {
            if (root.pending && t !== "") root.pending.connectWithPsk(t);
            root.pending = null;
        }
    }

    // A saved network whose password changed fails with NoSecrets: ask again.
    Instantiator {
        model: root.wifi ? root.wifi.networks : null
        delegate: Connections {
            required property var modelData
            target: modelData
            function onConnectionFailed(reason) {
                if (reason !== ConnectionFailReason.NoSecrets || !root.secured(modelData)) return;
                root.pending = modelData;
                prompt.title = "Password for " + modelData.name + " (rejected)";
                prompt.open();
            }
        }
    }

    Process {
        id: vpnList
        command: ["sh", "-c", 'for f in /etc/openfortivpn/*.conf; do n=$(basename "$f" .conf); [ "$n" = config ] && continue; printf "%s %s\\n" "$n" "$(systemctl is-active "openfortivpn@$n.service")"; done']
        stdout: StdioCollector {
            onStreamFinished: root.vpns = text.split("\n").filter(l => l).map(l => {
                const [name, state] = l.split(" ");
                return { name: name, active: state === "active" };
            })
        }
    }

    Process { id: vpnToggle }

    IpcHandler {
        target: "network"
        function toggle(): void { root.toggle(); }
    }
}
