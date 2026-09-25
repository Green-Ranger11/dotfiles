import QtQuick
import QtQuick.Layouts

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
        enabled: seg.interactive
        hoverEnabled: seg.interactive
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: m => seg.clicked(m)
        onWheel: w => seg.wheel(w)
    }

    signal clicked(var mouse)
    signal wheel(var event)
}
