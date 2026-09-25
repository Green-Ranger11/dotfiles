import Quickshell
import Quickshell.Io

// Power menu, replacing waybar/scripts/power-menu.sh (rofi). Toggled over IPC
// (qs ipc call power toggle): Super+Escape and the bar's power icon.
PickerList {
    id: picker
    searchable: false
    title: "Power"
    countNoun: "actions"
    hints: [["j/k", "navigate"], ["⏎", "select"], ["q", "close"]]
    boxWidth: 360
    boxHeight: fitRows(entries.length, 0)

    entries: [
        { text: "\u{f033e}  Lock", data: ["qs", "-p", Quickshell.env("HOME") + "/.config/quickshell/mocha", "ipc", "call", "lock", "trigger"] },
        { text: "\u{f04b2}  Suspend", data: ["systemctl", "suspend"] },
        { text: "\u{f0717}  Hibernate", data: ["systemctl", "hibernate"] },
        { text: "\u{f0709}  Reboot", data: ["systemctl", "reboot"] },
        { text: "\u{f0425}  Shutdown", data: ["systemctl", "poweroff"] },
        { text: "\u{f0343}  Logout", data: ["sh", "-c", 'loginctl kill-session "$XDG_SESSION_ID"'] }
    ]

    onAccepted: e => run.exec(e.data)

    Process { id: run }

    IpcHandler {
        target: "power"
        function toggle(): void { picker.toggle(); }
    }
}
