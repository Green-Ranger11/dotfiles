pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Per-laptop hardware names, picked by hostname (default: the ROG).
// kbd "" = no controllable keyboard backlight (the Legion's RGB keyboard is
// USB, not a sysfs LED).
Singleton {
    id: root

    readonly property var machines: ({
        battlestation: { // Lenovo Legion S7 15ACH6
            output: "eDP-2", res: "1920x1080", acHz: 165,
            panel: "amdgpu_bl2", kbd: "",
            tempHwmon: "k10temp" // no thermal zones on this board
        }
    })
    readonly property var rog: ({
        output: "eDP-1", res: "1920x1200", acHz: 144,
        panel: "amdgpu_bl1", kbd: "asus::kbd_backlight",
        tempHwmon: ""
    })

    FileView { id: hostnameFile; path: "/etc/hostname"; blockLoading: true }
    readonly property var hw: machines[hostnameFile.text().trim()] ?? rog

    readonly property string output: hw.output   // laptop panel connector
    readonly property string res: hw.res         // panel resolution
    readonly property int acHz: hw.acHz          // refresh rate on AC
    readonly property string panel: hw.panel     // /sys/class/backlight device
    readonly property string kbd: hw.kbd         // keyboard backlight LED, or ""

    // CPU temperature file. thermal_zone0 unless the machine names an hwmon
    // driver; hwmonN numbering changes between boots, so look it up by name.
    property string tempPath: hw.tempHwmon !== "" ? "" : "/sys/class/thermal/thermal_zone0/temp"
    Process {
        running: root.hw.tempHwmon !== ""
        command: ["sh", "-c", `for h in /sys/class/hwmon/hwmon*; do [ "$(cat $h/name)" = "${root.hw.tempHwmon}" ] && echo $h/temp1_input && break; done`]
        stdout: StdioCollector {
            onStreamFinished: if (text.trim() !== "") root.tempPath = text.trim()
        }
    }
}
