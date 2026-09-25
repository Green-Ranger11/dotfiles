import QtQuick
import Quickshell.Services.UPower
import ".."

Stat {
    id: bat
    visible: UPower.displayDevice?.isLaptopBattery ?? false

    readonly property var dev: UPower.displayDevice
    readonly property int pct: Math.round(dev?.percentage * 100)
    readonly property bool charging: dev?.state === UPowerDeviceState.Charging

    // fa-battery_empty .. fa-battery_full, plus cod-plug while charging.
    readonly property var icons: ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"]

    icon: charging ? "\ueb2d" : icons[Math.min(4, Math.floor(pct / 20))]
    value: pct + "%"
}
