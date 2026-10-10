import QtQuick
import ".."

Stat {
    tooltip: "Memory in use"
    // cod-server
    icon: "\ueb50"
    value: Sys.memory + "%"
}
