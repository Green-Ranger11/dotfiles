import QtQuick
import Quickshell.Io
import ".."

// amdgpu panel backlight. Read straight from sysfs; write through
// brightnessctl so we don't need write permission on the sysfs node.
Stat {
    id: bl
    interactive: true

    property int pct: 0
    readonly property string device: Machine.panel

    FileView { id: cur; path: "/sys/class/backlight/" + bl.device + "/brightness"; blockLoading: true }
    FileView { id: max; path: "/sys/class/backlight/" + bl.device + "/max_brightness"; blockLoading: true }

    function refresh() {
        cur.reload();
        max.reload();
        const m = Number(max.text());
        if (m > 0) bl.pct = Math.round(100 * Number(cur.text()) / m);
    }

    Component.onCompleted: refresh()

    // Percent scrolled but not yet handed to brightnessctl. Scrolling outruns
    // it (a wheel flick is a burst of events), so steps pile up here and go
    // out as one change when the previous one finishes.
    property int pending: 0

    function flush() {
        if (setter.running || pending === 0) return;
        setter.command = ["brightnessctl", "-d", bl.device, "set",
                          Math.abs(pending) + (pending > 0 ? "%+" : "%-")];
        pending = 0;
        setter.running = true;
    }

    Process {
        id: setter
        onExited: bl.pending === 0 ? bl.refresh() : bl.flush()
    }

    // cod-lightbulb_empty
    icon: "\uec40"
    value: pct + "%"

    onWheel: event => {
        // Show the new value now; refresh() corrects it once the write lands.
        const next = Math.max(0, Math.min(100, pct + (event.angleDelta.y > 0 ? 5 : -5)));
        pending += next - pct;
        pct = next;
        flush();
    }

    // brightnessctl writes are not watched, so re-read after our own change
    // and to catch the ASUS hotkeys.
    Timer { running: true; interval: 500; repeat: true; onTriggered: if (bl.pending === 0 && !setter.running) bl.refresh() }
}
