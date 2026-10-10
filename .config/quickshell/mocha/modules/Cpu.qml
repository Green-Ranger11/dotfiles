import QtQuick
import ".."

Stat {
    tooltip: "CPU load"
    // oct-cpu
    icon: "\uf4bc"
    value: Sys.cpu + "%"
}
