import QtQuick
import QtQuick.Layouts

// One module pill. Waybar gave each module its own background colour
// (current-theme.css "module colors"); keep that. The MouseArea lives here so
// modules don't anchor an item inside the content layout.
Rectangle {
    id: chip
    default property alias content: row.data
    property color bg: Theme.mantle
    property bool interactive: false

    signal clicked(var mouse)
    signal wheel(var event)

    Layout.fillHeight: true
    implicitWidth: row.implicitWidth + Theme.padding * 2
    radius: Theme.radius
    color: interactive && mouse.containsMouse ? Theme.hoverBg : bg
    scale: interactive && mouse.containsMouse ? 1.06 : 1.0

    Behavior on color {
        ColorAnimation { duration: 120 }
    }
    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: chip.interactive
        hoverEnabled: chip.interactive
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: m => chip.clicked(m)
        onWheel: w => chip.wheel(w)
    }
}
