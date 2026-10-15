import QtQuick
import Quickshell.Services.UPower
import ".."

Stat {
    id: bat
    visible: UPower.displayDevice?.isLaptopBattery ?? false

    readonly property var dev: UPower.displayDevice
    readonly property int pct: Math.round(dev?.percentage * 100)
    readonly property bool charging: dev?.state === UPowerDeviceState.Charging
    // Plugged in is not the same as charging: a full battery, or one held by
    // conservation mode / a charge limit, reports fully-charged on AC.
    readonly property bool plugged: !UPower.onBattery

    // fa-battery_empty .. fa-battery_full, plus cod-plug while on AC.
    readonly property var icons: ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"]

    function duration(s) {
        const h = Math.floor(s / 3600), m = Math.round((s % 3600) / 60);
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    icon: plugged ? "\ueb2d" : icons[Math.min(4, Math.floor(pct / 20))]
    value: pct + "%"
    tooltip: charging ? "Charging" + (dev?.timeToFull > 0 ? ` \u00b7 full in ${duration(dev.timeToFull)}` : "")
        : plugged ? "Plugged in \u00b7 not charging (full or held at limit)"
        : "On battery" + (dev?.timeToEmpty > 0 ? ` \u00b7 ${duration(dev.timeToEmpty)} left` : "")
}
