// Glyph + current value; click opens a list upward to pick another entry.
import QtQuick

Item {
    id: picker
    required property string glyph
    required property var model
    required property string textRole
    property int currentIndex: 0
    property string currentText: ""
    signal picked()

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        color: area.containsMouse || list.visible ? Theme.accent : Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: picker.glyph + "  " + picker.currentText
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: list.visible = !list.visible
        }
    }

    Rectangle {
        id: list
        visible: false
        anchors { bottom: label.top; left: label.left; bottomMargin: 8 }
        width: Math.max(col.implicitWidth, 160) + 24
        height: col.implicitHeight + 16
        color: Theme.crust
        border.color: Theme.accent
        border.width: 2
        radius: Theme.radius

        Column {
            id: col
            anchors { fill: parent; margins: 8 }
            Repeater {
                model: picker.model
                Rectangle {
                    required property int index
                    required property var model
                    readonly property string value: model[picker.textRole]
                    width: col.width
                    height: item.implicitHeight + 8
                    color: hover.containsMouse ? Theme.surface0 : "transparent"
                    Component.onCompleted: if (index === picker.currentIndex) picker.currentText = value
                    Text {
                        id: item
                        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 4 }
                        color: index === picker.currentIndex ? Theme.accent : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        text: parent.value
                    }
                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            picker.currentIndex = index
                            picker.currentText = parent.value
                            list.visible = false
                            picker.picked()
                        }
                    }
                }
            }
        }
    }
}
