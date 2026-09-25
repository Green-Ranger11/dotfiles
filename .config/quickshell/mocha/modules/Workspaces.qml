import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."

// Numbered tabs; the focused one carries the green underline.
RowLayout {
    spacing: 0

    Repeater {
        // Persistent 1-5, matching waybar's persistent-workspaces config.
        model: 5

        Segment {
            id: ws
            required property int index
            readonly property int wsId: index + 1
            readonly property bool populated: Hyprland.workspaces.values.some(w => w.id === wsId)

            padding: 8
            interactive: true
            active: Hyprland.focusedWorkspace?.id === wsId
            // waybar 0.15 still sends the pre-Lua dispatch form, which
            // Hyprland rejects; send the Lua expression directly.
            onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${wsId} })`)

            Label {
                text: ws.wsId
                color: ws.active ? Theme.accent : ws.populated ? Theme.mainFg : Theme.overlay0
            }
        }
    }
}
