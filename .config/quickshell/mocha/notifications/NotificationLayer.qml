import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."

// Everything the shell needs: toast stack + history panel. Instantiate once
// (not per-monitor); layer-shell puts it on the focused output.
Item {
    id: root

    // Layer-shell picks an output at map time, so without this toasts land on
    // whichever monitor the compositor prefers (eDP-1 here) instead of the one
    // being used.
    readonly property var focused: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

    // Toasts: top-right, below whatever the bar's exclusive zone reserved.
    PanelWindow {
        screen: root.focused
        anchors { top: true; right: true }
        margins { top: Theme.spacing * 2; right: Theme.marginSide }
        implicitWidth: 320
        implicitHeight: Math.max(1, col.implicitHeight)
        color: "transparent"
        exclusiveZone: 0
        visible: Notifs.popups.length > 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"
        mask: Region { item: col }

        Column {
            id: col
            width: parent.width
            spacing: Theme.spacing * 2

            Repeater {
                model: Notifs.popups

                Toast {
                    required property var modelData
                    width: col.width
                    notif: modelData
                    popup: true
                }
            }
        }
    }

    // History panel, sliding in from the right edge. Anchored to the top
    // only and height-capped instead of spanning the whole screen -- a
    // handful of notifications shouldn't cover the desktop edge to edge.
    PanelWindow {
        screen: root.focused
        anchors { top: true; right: true }
        margins { top: Theme.spacing * 2; right: Theme.marginSide }
        implicitWidth: 340
        // Empty state is just header + divider + "nothing here" -- the full
        // 480 cap left a big dead gap below it once cleared. Collapse to a
        // fixed small height instead of measuring content precisely.
        implicitHeight: Notifs.count === 0
            ? 130
            : Math.min(480, (root.focused?.height ?? 480) - Theme.spacing * 4)
        color: "transparent"
        exclusiveZone: 0
        // Binding visible to the slide position loops through contentItem size,
        // so the panel slides in and snaps out.
        visible: Notifs.panelOpen
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notification-centre"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        mask: Region { item: centre }

        NotificationCentre {
            id: centre
            width: parent.width
            height: parent.height
            x: Notifs.panelOpen ? 0 : width

            Behavior on x {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }
    }
}
