import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// The history panel's body. NotificationLayer wraps it in the layer-shell
// window; keeping it a plain Item means it also renders offscreen for tests.
Rectangle {
    id: panel

    color: Theme.mainBg
    radius: Theme.radius
    border.width: 1
    border.color: Theme.mainBr
    focus: true

    Keys.onEscapePressed: Notifs.panelOpen = false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.padding
        spacing: Theme.spacing

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing

            Label {
                Layout.fillWidth: true
                text: "notifications" + (Notifs.count ? "  " + Notifs.count : "")
                color: Theme.mainBr
            }

            Repeater {
                model: [
                    { glyph: Notifs.dnd ? "󰂛" : "󰂚", on: Notifs.dnd, act: "dnd" },
                    { glyph: "󰩺", on: false, act: "clear" }
                ]

                Rectangle {
                    required property var modelData
                    implicitWidth: 28
                    implicitHeight: 24
                    radius: Theme.radius
                    color: modelData.on ? Theme.mainBr : btn.containsMouse ? Theme.surface1 : Theme.surface0

                    Label {
                        anchors.centerIn: parent
                        text: modelData.glyph
                        color: modelData.on ? Theme.mainBg : Theme.mainFg
                    }

                    MouseArea {
                        id: btn
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData.act === "dnd")
                                Notifs.dnd = !Notifs.dnd;
                            else
                                Notifs.clearAll();
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.surface0
        }

        Label {
            Layout.fillWidth: true
            visible: Notifs.count === 0
            text: Notifs.dnd ? "do not disturb" : "nothing here"
            color: Theme.overlay0
            horizontalAlignment: Text.AlignHCenter
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Notifs.count > 0
            clip: true
            spacing: Theme.spacing * 2
            model: Notifs.history
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Toast {
                required property var modelData
                width: ListView.view.width
                notif: modelData
                popup: false
            }
        }
    }
}
