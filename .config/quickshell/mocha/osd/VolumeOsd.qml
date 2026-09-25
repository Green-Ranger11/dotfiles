import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Watches the default sink and pushes changes into the shared OSD.
Scope {
    id: root
    property var osd

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real vol: sink?.audio.volume ?? 0
    readonly property bool muted: sink?.audio.muted ?? false

    // Without this the node's volume is never read.
    PwObjectTracker { objects: [root.sink] }

    // Pipewire populates a second or two after launch and the sink swaps when
    // a monitor's HDMI audio appears. Either way the first values are not a
    // user action, so don't flash the OSD for them.
    property bool armed: false
    onSinkChanged: { root.armed = false; arm.restart(); }
    Component.onCompleted: arm.restart()   // in case the sink is already up
    Timer { id: arm; interval: 600; onTriggered: root.armed = true }

    function bump() {
        if (!root.armed || !root.osd) return;
        const pct = Math.round(root.vol * 100);
        root.osd.show(root.muted ? "󰝟"
                      : pct >= 50 ? "󰕾"
                      : pct > 0 ? "󰖀" : "󰕿",
                      pct, root.muted);
    }

    onVolChanged: bump()
    onMutedChanged: bump()
}
