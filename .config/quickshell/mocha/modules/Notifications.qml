import QtQuick
import ".."
import "../notifications"

// Reads the in-process notification server directly: no polling, no
// swaync-client subprocesses. Counts stay at zero until swaync is stopped and
// Quickshell picks up the bus name.
Stat {
    id: bell
    interactive: true
    active: Notifs.panelOpen

    // cod-bell_slash / cod-bell_dot / cod-bell
    icon: Notifs.dnd ? "\uec08" : Notifs.count > 0 ? "\ueb9a" : "\ueaa2"
    iconColor: Notifs.dnd ? Theme.iconDim : Notifs.count > 0 ? Theme.iconOn : Theme.iconMid
    value: Notifs.count > 0 ? Notifs.count : ""
    valueColor: Theme.accent

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Notifs.dnd = !Notifs.dnd;
        else
            Notifs.panelOpen = !Notifs.panelOpen;
    }
}
