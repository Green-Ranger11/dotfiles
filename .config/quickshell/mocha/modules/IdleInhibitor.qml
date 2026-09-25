import QtQuick
import Quickshell.Io
import ".."

// systemd-inhibit holds the lock for as long as its child runs, so the
// running Process *is* the inhibit state.
Stat {
    id: idle
    interactive: true

    readonly property bool lockHeld: holder.running

    Process {
        id: holder
        command: ["systemd-inhibit", "--what=idle", "--who=quickshell",
                  "--why=Idle inhibitor toggled from the bar", "sleep", "infinity"]
    }

    // cod-eye held, cod-eye_closed idle allowed
    icon: lockHeld ? "\uea70" : "\ueae7"
    iconColor: lockHeld ? Theme.iconOn : Theme.iconDim
    active: lockHeld

    onClicked: holder.running = !holder.running
}
