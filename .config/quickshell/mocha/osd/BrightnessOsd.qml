import QtQuick
import Quickshell
import Quickshell.Io

// Watches the panel backlight. brightnessctl owns the writes (hotkeys, the
// bar's scroll wheel), we only notice them.
Scope {
    id: root
    property var osd
    property string device: "amdgpu_bl1"
    property int pct: -1

    // blockLoading, or text() comes back empty.
    FileView { id: cur; path: "/sys/class/backlight/" + root.device + "/brightness"; blockLoading: true }
    FileView { id: max; path: "/sys/class/backlight/" + root.device + "/max_brightness"; blockLoading: true }

    readonly property var icons: ["\ue38d", "\ue3d3", "\ue3d1", "\ue3cf", "\ue3ce", "\ue3cd", "\ue3ca", "\ue3c8", "\ue39b"]

    // ponytail: 150ms sysfs poll. sysfs has no usable inotify and the writer
    // is another process; swap in `udevadm monitor --subsystem-match=backlight`
    // if this ever shows up in a profile.
    Timer {
        running: true
        interval: 150
        repeat: true
        onTriggered: {
            cur.reload();
            const m = Number(max.text());
            if (!(m > 0)) return;
            const p = Math.round(100 * Number(cur.text()) / m);
            if (p === root.pct) return;
            const first = root.pct < 0;   // first reading is startup, not a change
            root.pct = p;
            if (!first && root.osd)
                root.osd.show(root.icons[Math.min(8, Math.floor(p / 12))], p, false);
        }
    }
}
