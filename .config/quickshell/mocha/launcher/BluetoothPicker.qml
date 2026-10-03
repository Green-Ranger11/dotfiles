import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import ".."

// Bluetooth menu in the shared picker chrome. Toggled over IPC
// (qs ipc call bluetooth toggle) and by the bar's bluetooth icon.
// Opens without scanning: paired devices only, until "Scan" is switched on.
// Enter does the obvious thing per row; Tab (or "a", or right-click) opens
// the row's action submenu: trust, block, pair, forget for a device,
// discoverable/pairable for the adapter.
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
    // Submenu target: a device, or "adapter". null = main list. A target
    // that vanished (device forgotten, adapter switched off) just shows the
    // main list again; no assignment inside the entries binding.
    property var sub: null
    readonly property bool subValid: sub === "adapter" ? on
        : (sub !== null && !!adapter && adapter.devices.values.includes(sub))

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

    // Action rows for one device. `act` names the handler in onAccepted;
    // every row keeps the picker open so the state text updates in place.
    function deviceActions(d) {
        const row = (text, sub, act) => ({ section: d.name, text: text, sub: sub, data: { act: act, dev: d }, key: act, keep: true });
        const out = [];
        if (d.pairing) out.push(row("\u{f0156}  Cancel pairing", "", "cancelPair"));
        else if (!d.paired) out.push(row("\u{f00b1}  Pair", "then trust and connect", "pair"));
        if (d.paired) {
            out.push(d.connected
                ? row("\u{f00b2}  Disconnect", "", "disconnect")
                : row("\u{f00b1}  Connect", "", "connect"));
            out.push(row(d.trusted ? "\u{f04ce}  Trusted" : "\u{f04d2}  Not trusted",
                d.trusted ? "reconnects on its own; enter to stop" : "enter to allow auto-reconnect", "trust"));
        }
        out.push(row(d.blocked ? "\u{f0739}  Blocked" : "\u{f05e1}  Not blocked",
            d.blocked ? "enter to unblock" : "refuse all connections from it", "block"));
        if (d.paired) out.push(row("\u{f01b4}  Forget", "remove pairing", "forget"));
        const info = [d.address, d.batteryAvailable ? Math.round(d.battery * 100) + "% battery" : ""].filter(x => x).join("  ");
        out.push({ section: d.name, text: "\u{f02fd}  " + info, sub: "", data: { act: "none" }, key: "info", keep: true, color: Theme.overlay0 });
        return out;
    }

    function adapterActions(a) {
        const row = (text, sub, act) => ({ section: "Adapter", text: text, sub: sub, data: { act: act }, key: act, keep: true });
        return [
            row(a.discoverable ? "\u{f0208}  Discoverable" : "\u{f0209}  Hidden",
                a.discoverable ? "other devices can see this laptop; enter to hide" : "enter to let a phone find this laptop", "discoverable"),
            row(a.pairable ? "\u{f00b1}  Pairable" : "\u{f00b2}  Not pairable",
                a.pairable ? "accepts pairing requests; enter to refuse" : "enter to accept pairing requests", "pairable"),
            row(a.discovering ? "\u{f0437}  Scanning" : "\u{f0349}  Scan for new devices", a.discovering ? "enter to stop" : "", "scan"),
        ];
    }

    PickerList {
        id: picker
        title: !root.subValid ? "Bluetooth" : (root.sub === "adapter" ? "Bluetooth adapter" : root.sub.name)
        countNoun: !root.subValid ? "entries" : "actions"
        searchable: false
        submenu: root.subValid
        hints: !root.subValid
            ? [["j/k", "navigate"], ["⏎", "connect"], ["tab", "actions"], ["d", "forget"], ["q", "close"]]
            : [["j/k", "navigate"], ["⏎", "toggle"], ["h/esc", "back"]]
        // Fixed height, shared with the network picker so the two boxes
        // match: 9 rows + 3 section headers, anything beyond scrolls.
        boxHeight: fitRows(9, 3)

        // Scanning is opt-in per open; never leave it running after close.
        onVisibleChanged: {
            if (!visible && root.adapter) root.adapter.discovering = false;
            if (!visible) root.sub = null;
        }

        entries: {
            if (root.subValid) return root.sub === "adapter" ? root.adapterActions(root.adapter) : root.deviceActions(root.sub);

            const out = [{
                section: "Adapter",
                text: root.on ? "\u{f00af}  Bluetooth on" : "\u{f00b2}  Bluetooth off",
                sub: root.on ? "enter to turn off  ·  tab for discoverable/pairable" : "enter to turn on",
                data: { power: true },
                key: "power",
                keep: true
            }];
            if (!root.on) return out;
            out.push({
                section: "Adapter",
                text: root.adapter.discovering ? "\u{f0437}  Scanning" : "\u{f0349}  Scan for new devices",
                sub: root.adapter.discovering ? "enter to stop" : "",
                data: { scan: true },
                key: "scan",
                keep: true
            });
            // Paired first (connected on top), then anything a scan found.
            const devs = root.adapter.devices.values
                .filter(d => d.paired || root.adapter.discovering)
                .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name));
            for (const d of devs) {
                const battery = d.batteryAvailable ? Math.round(d.battery * 100) + "%" : "";
                const flags = [d.trusted ? "" : (d.paired ? "untrusted" : ""), d.blocked ? "blocked" : ""].filter(x => x);
                out.push({
                    section: d.paired ? "Devices" : "New devices",
                    text: root.glyph(d.icon) + "  " + d.name,
                    sub: [root.stateText(d), battery].concat(flags).filter(x => x).join("  "),
                    data: { dev: d },
                    key: d.address,
                    color: d.connected ? Theme.accent : undefined,
                    keep: true
                });
            }
            return out;
        }

        onMore: e => {
            if (e.data.dev) root.sub = e.data.dev;
            else if (e.data.power || e.data.scan) { if (root.on) root.sub = "adapter"; }
        }
        onBack: root.sub = null

        onAccepted: e => {
            const d = e.data;
            if (d.act !== undefined) {
                const dev = d.dev, a = root.adapter;
                switch (d.act) {
                case "connect": dev.connect(); break;
                case "disconnect": dev.disconnect(); break;
                case "pair": root.pairing = dev; dev.pair(); break;
                case "cancelPair": dev.cancelPair(); break;
                case "trust": dev.trusted = !dev.trusted; break;
                case "block": dev.blocked = !dev.blocked; break;
                case "forget": dev.forget(); root.sub = null; break;
                case "discoverable": a.discoverable = !a.discoverable; break;
                case "pairable": a.pairable = !a.pairable; break;
                case "scan": a.discovering = !a.discovering; break;
                }
                return;
            }
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
