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

    // History panel, sliding in from the right edge. The window is a
    // fullscreen transparent overlay (like PickerList) so a click anywhere
    // off the panel dismisses it; the panel itself stays top-right and
    // height-capped -- a handful of notifications shouldn't cover the
    // desktop edge to edge.
    PanelWindow {
        id: centreWindow
        screen: root.focused
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        // Binding visible to the slide position loops through contentItem size,
        // so the panel slides in and snaps out.
        visible: Notifs.panelOpen
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notification-centre"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        // Click-off to dismiss. Covers the bar too, so clicking the bell
        // while open lands here and closes, same as before.
        MouseArea {
            anchors.fill: parent
            onClicked: Notifs.panelOpen = false
        }

        NotificationCentre {
            id: centre
            // Ignore mode puts y=0 at the screen edge, so step past the bar
            // ourselves instead of relying on its exclusive zone.
            y: Theme.barHeight + Theme.spacing * 2
            width: 340
            // Empty state is just header + divider + "nothing here" -- the full
            // 480 cap left a big dead gap below it once cleared. Collapse to a
            // fixed small height instead of measuring content precisely.
            height: Notifs.count === 0
                ? 130
                : Math.min(480, centreWindow.height - y - Theme.spacing * 2)
            x: Notifs.panelOpen ? centreWindow.width - width - Theme.marginSide : centreWindow.width

            Behavior on x {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }
    }
}
