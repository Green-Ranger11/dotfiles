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
    // Submenu target: a Wi-Fi network, or "wifi" for the radio row. null =
    // main list. A target that vanished from the scan shows the main list.
    property var sub: null
    readonly property bool subValid: sub === "wifi" ? !!wifi
        : (sub !== null && !!wifi && wifi.networks.values.includes(sub))

    function toggle() { picker.toggle(); }

    // md-wifi_strength_1..4 (outline for ~0).
    function bars(s) {
        return s > 0.75 ? "\u{f0928}" : s > 0.5 ? "\u{f0925}" : s > 0.25 ? "\u{f0922}" : s > 0.05 ? "\u{f091f}" : "\u{f092f}";
    }
    function secured(n) {
        return n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Owe;
    }
    function securityName(t) {
        switch (t) {
        case WifiSecurityType.Open: return "open";
        case WifiSecurityType.Owe: return "OWE (encrypted, no password)";
        case WifiSecurityType.WpaPsk: return "WPA";
        case WifiSecurityType.Wpa2Psk: return "WPA2";
        case WifiSecurityType.Sae: return "WPA3";
        case WifiSecurityType.WpaEap: return "WPA Enterprise";
        case WifiSecurityType.Wpa2Eap: return "WPA2 Enterprise";
        case WifiSecurityType.Wpa3SuiteB192: return "WPA3 Enterprise";
        case WifiSecurityType.StaticWep:
        case WifiSecurityType.DynamicWep: return "WEP";
        case WifiSecurityType.Leap: return "LEAP";
        default: return "unknown";
        }
    }

    // Action rows for one network; every row keeps the picker open.
    function netActions(n) {
        const row = (text, sub, act) => ({ section: n.name, text: text, sub: sub, data: { act: act, net: n }, key: act, keep: true });
        const out = [];
        if (n.connected) out.push(row("\u{f05aa}  Disconnect", "", "disconnect"));
        else if (n.known || !root.secured(n)) out.push(row("\u{f05a9}  Connect", n.stateChanging ? "connecting…" : "", "connect"));
        else out.push(row("\u{f05a9}  Connect", "asks for the password", "password"));
        if (root.secured(n) && n.known) out.push(row("\u{f033e}  Connect with a new password", "when the Wi-Fi password changed", "password"));
        if (n.known) out.push(row("\u{f01b4}  Forget", "drop the saved password", "forget"));
        out.push({ section: n.name, text: "\u{f02fd}  " + root.securityName(n.security) + "  ·  " + Math.round(n.signalStrength * 100) + "% signal",
            sub: "", data: { act: "none" }, key: "info", keep: true, color: Theme.overlay0 });
        return out;
    }

    function wifiActions(w) {
        const row = (text, sub, act) => ({ section: "Wi-Fi", text: text, sub: sub, data: { act: act }, key: act, keep: true });
        return [
            row(Networking.wifiEnabled ? "\u{f05a9}  Wi-Fi on" : "\u{f05aa}  Wi-Fi off", "enter to turn " + (Networking.wifiEnabled ? "off" : "on"), "radio"),
            row(w.autoconnect ? "\u{f04ce}  Auto-connect on" : "\u{f04d2}  Auto-connect off",
                w.autoconnect ? "joins saved networks by itself; enter to stop" : "enter to join saved networks automatically", "autoconnect"),
            row("\u{f0450}  Rescan", "scan runs while this menu is open; enter restarts it", "rescan"),
        ];
    }

    PickerList {
        id: picker
        title: !root.subValid ? "Network" : (root.sub === "wifi" ? "Wi-Fi" : root.sub.name)
        countNoun: !root.subValid ? "entries" : "actions"
        searchable: false
        submenu: root.subValid
        hints: !root.subValid
            ? [["j/k", "navigate"], ["⏎", "connect"], ["tab", "actions"], ["d", "forget"], ["q", "close"]]
            : [["j/k", "navigate"], ["⏎", "do"], ["h/esc", "back"]]
        // Fixed height, same as the bluetooth picker: 9 rows + 3 headers.
        boxHeight: fitRows(9, 3)

        // Scan only while the menu is up.
        onVisibleChanged: {
            if (root.wifi) root.wifi.scannerEnabled = visible;
            if (visible) vpnList.running = true;
            else root.sub = null;
        }

        entries: {
            if (root.subValid) return root.sub === "wifi" ? root.wifiActions(root.wifi) : root.netActions(root.sub);
            const out = root.vpns.map(v => ({
                section: "VPN",
                text: (v.active ? "\u{f0582}  " : "\u{f0fc6}  ") + v.name,
                sub: v.active ? "connected" : "",
                color: v.active ? Theme.accent : undefined,
                data: { vpn: v.name },
                key: "vpn " + v.name
            }));
            out.push({
                section: "Wi-Fi",
                text: Networking.wifiEnabled ? "\u{f05a9}  Wi-Fi on" : "\u{f05aa}  Wi-Fi off",
                sub: "enter to turn " + (Networking.wifiEnabled ? "off" : "on") + "  ·  tab for auto-connect/rescan",
                data: { radio: true },
                key: "wifi",
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
                        key: n.name,
                        color: n.connected ? Theme.accent : undefined
                    });
                }
            }
            return out;
        }

        onMore: e => {
            if (e.data.net) root.sub = e.data.net;
            else if (e.data.radio && root.wifi) root.sub = "wifi";
        }
        onBack: root.sub = null

        onAccepted: e => {
            const d = e.data;
            if (d.act !== undefined) {
                switch (d.act) {
                case "connect": d.net.connect(); break;
                case "disconnect": d.net.disconnect(); break;
                case "password":
                    root.pending = d.net;
                    prompt.title = "Password for " + d.net.name;
                    prompt.open();
                    break;
                case "forget": d.net.forget(); root.sub = null; break;
                case "radio": Networking.wifiEnabled = !Networking.wifiEnabled; break;
                case "autoconnect": root.wifi.autoconnect = !root.wifi.autoconnect; break;
                case "rescan": root.wifi.scannerEnabled = false; rescan.restart(); break;
                }
                return;
            }
            if (d.vpn) {
                Sys.vpnToggling = true;
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

    // vpn.sh blocks until the tunnel is up or the unit fails; relist then.
    Process {
        id: vpnToggle
        onExited: { Sys.vpnToggling = false; vpnList.running = true; }
    }

    // "Rescan": NetworkManager only scans when the scanner is (re)enabled.
    Timer { id: rescan; interval: 300; onTriggered: if (root.wifi && picker.visible) root.wifi.scannerEnabled = true }

    IpcHandler {
        target: "network"
        function toggle(): void { root.toggle(); }
    }
}
