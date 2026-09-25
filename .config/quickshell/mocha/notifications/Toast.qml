import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

// One notification card. Used both as a floating toast (popup: true, which
// arms the expiry timer) and as a row in the notification centre.
Rectangle {
    id: card

    required property var notif
    property bool popup: true

    readonly property bool critical: notif.urgency === 2

    // invoke() does not close the notification; the spec says we should,
    // unless the client asked to stay resident.
    function run(action) {
        action.invoke();
        if (!notif.resident)
            notif.dismiss();
    }
    readonly property string icon: {
        if (notif.image)
            return notif.image;
        if (notif.appIcon)
            return Quickshell.iconPath(notif.appIcon, true);
        const e = DesktopEntries.heuristicLookup(notif.desktopEntry || notif.appName);
        return e ? Quickshell.iconPath(e.icon, true) : "";
    }

    // Small app icon beside the app name; the left bar carries the urgency.
    readonly property int iconSize: 14
    readonly property int pad: 12
    readonly property int barWidth: 3
    readonly property color barColor: critical ? Theme.red : notif.urgency === 0 ? Theme.surface2 : Theme.mainBr

    implicitHeight: col.implicitHeight + pad * 2
    // Toasts float over windows and need the border; centre rows sit inside
    // an already-bordered panel, so they are flat blocks (critical still red).
    color: popup ? Theme.mainBg : Theme.base
    radius: Theme.radius
    border.width: popup || critical ? 1 : 0
    border.color: critical ? Theme.red : notif.urgency === 0 ? Theme.surface2 : Theme.mainBr

    // expireTimeout is milliseconds, -1 for "server decides". Critical never
    // expires on its own, per the spec.
    readonly property int expiry: {
        if (critical)
            return 0;
        const t = notif.expireTimeout;
        return t > 0 ? t : 5000;
    }

    Timer {
        running: card.popup && card.expiry > 0
        interval: card.expiry
        // Drop the toast, but keep the notification in the centre's history;
        // expire() would destroy it.
        onTriggered: Notifs.drop(card.notif)
    }

    // Outside the layout on purpose: anchors on a Layout child warns.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: m => {
            // Left click runs the default action if there is one, else closes.
            if (m.button === Qt.LeftButton)
                for (const a of card.notif.actions)
                    if (a.identifier === "default") {
                        card.run(a);
                        return;
                    }
            card.notif.dismiss();
        }
    }

    // Urgency bar down the left edge, inside the border.
    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: card.border.width
        }
        width: card.barWidth
        color: card.barColor
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: card.pad
        anchors.leftMargin: card.pad + card.barWidth
        spacing: 8

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            // Header: icon, app name, age, close.
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Item {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: card.iconSize
                    implicitHeight: card.iconSize

                    Image {
                        id: img
                        anchors.fill: parent
                        source: card.icon
                        visible: source != "" && status === Image.Ready
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: 32
                        sourceSize.height: 32
                        asynchronous: true
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !img.visible
                        text: card.critical ? "\uea6c" : "\ueaa2"
                        color: card.barColor
                        font.family: Theme.fontFamily
                        font.pixelSize: card.iconSize
                    }
                }

                Label {
                    Layout.fillWidth: true
                    // Bare notify-send (no -a) reports its own name; show the
                    // desktop entry hint instead, else a neutral label.
                    text: {
                        const a = card.notif.appName;
                        if (a && a !== "notify-send")
                            return a;
                        return card.notif.desktopEntry || "System";
                    }
                    color: Theme.subtext0
                    font.pixelSize: Theme.fontSize - 3
                    elide: Text.ElideRight
                }

                Label {
                    text: Notifs.age(card.notif.id)
                    color: Theme.overlay0
                    font.pixelSize: Theme.fontSize - 3
                }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: 20
                    implicitHeight: 20
                    color: closeMouse.containsMouse ? Theme.red : "transparent"
                    radius: Theme.radius

                    Text {
                        anchors.centerIn: parent
                        text: "\uea76"
                        color: closeMouse.containsMouse ? Theme.mainBg : Theme.subtext0
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: card.notif.dismiss()
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                visible: text != ""
                text: card.notif.summary
                color: card.critical ? Theme.red : Theme.mainFg
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true
                visible: text != ""
                text: card.notif.body
                color: Theme.subtext1
                font.weight: Font.Normal
                font.pixelSize: Theme.fontSize - 1
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                maximumLineCount: card.popup ? 4 : 10
                elide: Text.ElideRight
                onLinkActivated: l => Qt.openUrlExternally(l)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing
            visible: buttons.count > 0

            Repeater {
                id: buttons
                model: card.notif.actions.filter(a => a.identifier !== "default")

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 26
                    color: actMouse.containsMouse ? Theme.surface2 : card.popup ? Theme.surface0 : Theme.surface1
                    radius: Theme.radius

                    Label {
                        anchors.centerIn: parent
                        text: modelData.text || modelData.identifier
                        font.pixelSize: Theme.fontSize - 2
                    }

                    MouseArea {
                        id: actMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: card.run(modelData)
                    }
                }
            }
        }
    }
}
