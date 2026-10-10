import QtQuick
import QtQuick.Layouts
import Quickshell

// One tab in the bar: flat, no fill, with a green underline that lights up
// when the module is active or hovered.
Item {
    id: seg
    default property alias content: row.data
    property int padding: Theme.padding
    property bool interactive: false
    property bool active: false
    // Kept so modules can still name a colour; the tab style ignores fills.
    property color bg: "transparent"
    // Hover text shown in a small popup under the segment after a short
    // pause. Non-interactive segments get hover tracking for it but keep
    // passing clicks through.
    property string tooltip: ""

    Layout.fillHeight: true
    implicitWidth: row.implicitWidth + padding * 2

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: seg.active || (seg.interactive && mouse.containsMouse) ? parent.width - 4 : 0
        height: Theme.underline
        color: seg.active ? Theme.accent : Theme.surface2

        Behavior on width {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: seg.interactive || seg.tooltip !== ""
        hoverEnabled: enabled
        acceptedButtons: seg.interactive ? (Qt.LeftButton | Qt.MiddleButton | Qt.RightButton) : Qt.NoButton
        onClicked: m => seg.clicked(m)
        onWheel: w => seg.wheel(w)
    }

    Timer {
        id: tipDelay
        interval: 450
        running: seg.tooltip !== "" && mouse.containsMouse
    }

    PopupWindow {
        anchor.item: seg
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 4
        visible: seg.tooltip !== "" && mouse.containsMouse && !tipDelay.running
        color: "transparent"
        implicitWidth: tip.implicitWidth + 16
        implicitHeight: tip.implicitHeight + 10

        Rectangle {
            anchors.fill: parent
            color: Theme.mainBg
            border.width: 1
            border.color: Theme.mainBr
            radius: Theme.radius

            Label {
                id: tip
                anchors.centerIn: parent
                text: seg.tooltip
                color: Theme.mainFg
            }
        }
    }

    signal clicked(var mouse)
    signal wheel(var event)
}
