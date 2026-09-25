import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import ".."

// Bluetooth menu in the shared picker chrome. Toggled over IPC
// (qs ipc call bluetooth toggle) and by the bar's bluetooth icon.
// Opens without scanning: paired devices only, until "Scan" is switched on.
//
// ponytail: no BlueZ agent, so pairing is "just works" only (headsets,
// speakers; phones confirm on their own screen). Devices that need a typed
// passkey (some keyboards): pair them once with bluetoothctl (bluez-utils).
Scope {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter?.enabled ?? false
    // Device being paired; connects once pairing lands.
    property var pairing: null

    function toggle() { picker.toggle(); }

    // BlueZ icon name -> Nerd Font md glyph.
    function glyph(icon) {
        if (icon.startsWith("audio-head")) return "\u{f02cb}";
        if (icon.startsWith("audio")) return "\u{f04c3}";
        if (icon === "phone") return "\u{f011c}";
        if (icon === "computer") return "\u{f0322}";
        if (icon === "input-keyboard") return "\u{f030c}";
        if (icon === "input-mouse") return "\u{f037d}";
        if (icon === "input-gaming") return "\u{f02b4}";
        if (icon === "video-display") return "\u{f0502}";
        return "\u{f00af}";
    }

    function stateText(d) {
        if (d.pairing) return "pairing…";
        if (d.state === BluetoothDeviceState.Connecting) return "connecting…";
        if (d.state === BluetoothDeviceState.Disconnecting) return "disconnecting…";
        if (d.connected) return "connected";
        return d.paired ? "paired" : "new";
    }

    PickerList {
        id: picker
        title: "Bluetooth"
        countNoun: "entries"
        searchable: false
        hints: [["j/k", "navigate"], ["⏎", "connect"], ["d", "forget"], ["q", "close"]]
        // Your rows (toggles + paired devices) plus 4 rows kept free for scan
        // results, so the box doesn't jump when scanning starts; more scroll.
        boxHeight: {
            const found = entries.filter(e => e.data.dev && !e.data.dev.paired).length;
            return fitRows(entries.length - found + 4, 3);
        }

        // Scanning is opt-in per open; never leave it running after close.
        onVisibleChanged: if (!visible && root.adapter) root.adapter.discovering = false

        entries: {
            const out = [{
                section: "Adapter",
                text: root.on ? "\u{f00af}  Bluetooth on" : "\u{f00b2}  Bluetooth off",
                sub: "enter to turn " + (root.on ? "off" : "on"),
                data: { power: true },
                keep: true
            }];
            if (!root.on) return out;
            out.push({
                section: "Adapter",
                text: root.adapter.discovering ? "\u{f0437}  Scanning" : "\u{f0349}  Scan for new devices",
                sub: root.adapter.discovering ? "enter to stop" : "",
                data: { scan: true },
                keep: true
            });
            // Paired first (connected on top), then anything a scan found.
            const devs = root.adapter.devices.values
                .filter(d => d.paired || root.adapter.discovering)
                .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name));
            for (const d of devs) {
                const battery = d.batteryAvailable ? Math.round(d.battery * 100) + "%" : "";
                out.push({
                    section: d.paired ? "Devices" : "New devices",
                    text: root.glyph(d.icon) + "  " + d.name,
                    sub: [root.stateText(d), battery].filter(x => x).join("  "),
                    data: { dev: d },
                    color: d.connected ? Theme.accent : undefined
                });
            }
            return out;
        }

        onAccepted: e => {
            const d = e.data;
            if (d.power) root.adapter.enabled = !root.on;
            else if (d.scan) root.adapter.discovering = !root.adapter.discovering;
            else if (d.dev.connected) d.dev.disconnect();
            else if (d.dev.paired) d.dev.connect();
            else {
                root.pairing = d.dev;
                d.dev.pair();
            }
        }

        onRemoved: e => { if (e.data.dev && e.data.dev.paired) e.data.dev.forget(); }
    }

    // Freshly paired: trust it (auto-reconnect later) and connect now.
    Connections {
        target: root.pairing
        function onPairedChanged() {
            const d = root.pairing;
            if (!d.paired) return;
            d.trusted = true;
            d.connect();
            root.pairing = null;
        }
    }

    IpcHandler {
        target: "bluetooth"
        function toggle(): void { root.toggle(); }
    }
}
