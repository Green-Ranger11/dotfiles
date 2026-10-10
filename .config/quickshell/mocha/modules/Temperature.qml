import QtQuick
import ".."

Stat {
    tooltip: "CPU temperature"
    // cod-flame
    icon: "\ueaf2"
    value: Sys.temperature + "\u00b0"
}
