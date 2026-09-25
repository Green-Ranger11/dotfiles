import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."

// Count of windows on the focused workspace, as a dim superscript-ish tag.
Segment {
    padding: 2
    visible: count > 0

    readonly property int count: Hyprland.focusedWorkspace?.toplevels.values.length ?? 0

    Label {
        text: parent.parent.count
        color: Theme.overlay0
        font.pixelSize: Theme.fontSize - 3
    }
}
