import Quickshell

// Drop a single `Osd {}` into shell.qml. The window is shared, so volume and
// brightness can never end up stacked on top of each other.
Scope {
    OsdWindow { id: win }
    VolumeOsd { osd: win }
    BrightnessOsd { osd: win }
}
