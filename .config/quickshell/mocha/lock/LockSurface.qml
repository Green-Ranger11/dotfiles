// Visual layer for one monitor. Feature-matches ~/.config/hypr/hyprlock.conf:
// background image, clock, date, avatar, password field with fail feedback.
//
// ponytail: skipped vs. hyprlock.conf -
//   - real gaussian blur on the background (hyprlock's blur_passes = 2) -
//     just a dim scrim instead. Add with Qt5Compat.GraphicalEffects
//     FastBlur, or Quickshell.Wayland's BackgroundEffect, if the flat scrim
//     doesn't look good enough.
//   - keyboard layout label ($LAYOUT) - needs Quickshell.Hyprland's Hyprland
//     singleton (devices/keyboards) to fetch active layout. Add if wanted.
//   - capslock indicator - needs a keyboard-state source; Quickshell doesn't
//     surface this directly yet. Skipped.
//   - fingerprint prompt - hyprlock's $FPRINTPROMPT is hyprlock-internal;
//     a real Quickshell equivalent would need a second PamContext against a
//     fprintd service file, run in parallel with the password one. Skipped.
import QtQuick
import QtQuick.Layouts
import Quickshell
import ".." // Theme singleton, same pattern as modules/Time.qml etc.

Rectangle {
    id: root
    required property var context // LockContext

    readonly property var theme: Theme

    color: theme.base

    // Background: same wallpaper hyprlock.conf points at.
    Image {
        id: bg
        anchors.fill: parent
        source: "file:///home/alesana/.github/assets/ml6.jpeg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle {
        anchors.fill: parent
        color: theme.crust
        opacity: 0.45 // scrim in place of hyprlock's real blur, see ponytail note above
    }

    // Clock - centered, where avatar used to sit.
    Text {
        id: clock
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -75 }
        color: theme.mainFg
        font.family: theme.fontFamily
        font.pixelSize: 40
        font.weight: theme.fontWeight
        text: Qt.formatTime(clock.now, "hh:mm")
        horizontalAlignment: Text.AlignHCenter

        property var now: new Date()
        Timer {
            id: clockTimer
            running: true
            repeat: true
            interval: 1000
            onTriggered: clock.now = new Date()
        }
    }

    // Date - matches hyprlock's cmd[update:...] date label.
    Text {
        anchors { top: clock.bottom; horizontalCenter: parent.horizontalCenter; topMargin: 6 }
        color: theme.mainFg
        font.family: theme.fontFamily
        font.pixelSize: 15
        text: Qt.formatDate(new Date(), "dddd, dd MMMM yyyy")
    }

    // Input field - matches hyprlock's input-field block.
    ColumnLayout {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: 47 }
        spacing: 8

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 280
            implicitHeight: 42
            radius: theme.radius
            color: "transparent"
            border.width: 1
            border.color: root.context.showFailure ? theme.crit : theme.subtext0

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.margins: 12
                verticalAlignment: TextInput.AlignVCenter
                color: theme.mainFg
                font.family: theme.fontFamily
                font.pixelSize: theme.fontSize
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                enabled: !root.context.unlockInProgress
                focus: true

                onTextChanged: root.context.currentText = text
                onAccepted: root.context.tryUnlock()

                Connections {
                    target: root.context
                    function onCurrentTextChanged() {
                        if (passwordInput.text !== root.context.currentText)
                            passwordInput.text = root.context.currentText;
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: passwordInput.text === ""
                    color: theme.subtext0
                    font: passwordInput.font
                    text: "Logged in as " + (Quickshell.env("USER") || "")
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: root.context.showFailure
            color: theme.crit
            font.family: theme.fontFamily
            font.italic: true
            text: "Authentication failed (" + root.context.failCount + ")"
        }
    }
}
