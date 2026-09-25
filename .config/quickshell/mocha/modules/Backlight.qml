import QtQuick
import Quickshell.Io
import ".."

// amdgpu panel backlight. Read straight from sysfs; write through
// brightnessctl so we don't need write permission on the sysfs node.
Stat {
    id: bl
    interactive: true

    property int pct: 0
    readonly property string device: "amdgpu_bl1"

    FileView { id: cur; path: "/sys/class/backlight/" + bl.device + "/brightness"; blockLoading: true }
    FileView { id: max; path: "/sys/class/backlight/" + bl.device + "/max_brightness"; blockLoading: true }

    function refresh() {
        cur.reload();
        max.reload();
        const m = Number(max.text());
        if (m > 0) bl.pct = Math.round(100 * Number(cur.text()) / m);
    }

    Component.onCompleted: refresh()

    Process { id: setter }

    // cod-lightbulb_empty
    icon: "\uec40"
    value: pct + "%"

    onWheel: event => {
        setter.command = ["brightnessctl", "-d", bl.device, "set",
                          event.angleDelta.y > 0 ? "5%+" : "5%-"];
        setter.running = true;
    }

    // brightnessctl writes are not watched, so re-read after our own change
    // and to catch the ASUS hotkeys.
    Timer { running: true; interval: 2000; repeat: true; onTriggered: bl.refresh() }
}
