import QtQuick
import Quickshell.Services.Pipewire
import ".."

// Click to mute, scroll to change.
Stat {
    id: vol
    interactive: true

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int pct: Math.round((sink?.audio.volume ?? 0) * 100)
    readonly property bool muted: sink?.audio.muted ?? false

    // Without this the node's volume is never read.
    PwObjectTracker { objects: [vol.sink] }

    // cod-mute / cod-unmute
    icon: muted ? "\ueb24" : "\ueb75"
    iconColor: muted ? Theme.iconDim : Theme.iconOn
    value: pct + "%"
    valueColor: muted ? Theme.overlay0 : Theme.mainFg

    onClicked: if (sink) sink.audio.muted = !sink.audio.muted
    onWheel: event => {
        if (!sink) return;
        const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
        sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + step));
    }
}
