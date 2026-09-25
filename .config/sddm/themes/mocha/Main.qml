// SDDM login screen. Centre mirrors ~/.config/quickshell/mocha/lock/LockSurface.qml
// (wallpaper, scrim, clock, date, password field). Bottom bar adds the login-
// manager bits: user, session, keyboard layout, and power actions.
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property int failCount: 0
    property bool busy: false

    color: Theme.base

    function login() {
        root.busy = true
        sddm.login(userPicker.currentText, password.text, sessionPicker.currentIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false
            root.failCount++
            password.text = ""
            password.forceActiveFocus()
        }
    }

    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle {
        anchors.fill: parent
        color: Theme.crust
        opacity: 0.45
    }

    Text {
        id: clock
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: -75 }
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 40
        font.weight: Font.Bold
        text: Qt.formatTime(now, "hh:mm")

        property var now: new Date()
        Timer {
            running: true
            repeat: true
            interval: 1000
            onTriggered: clock.now = new Date()
        }
    }

    Text {
        anchors { top: clock.bottom; horizontalCenter: parent.horizontalCenter; topMargin: 6 }
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 15
        text: Qt.formatDate(clock.now, "dddd, dd MMMM yyyy")
    }

    ColumnLayout {
        id: inputCol
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; verticalCenterOffset: 47 }
        spacing: 8

        Rectangle {
            id: inputBox
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 280
            implicitHeight: 42
            radius: Theme.radius
            color: "transparent"
            border.width: 1
            border.color: root.failCount > 0 ? Theme.crit : Theme.subtext0

            TextInput {
                id: password
                anchors.fill: parent
                anchors.margins: 12
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                enabled: !root.busy
                focus: true
                onAccepted: root.login()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: password.text === ""
                    color: Theme.subtext0
                    font: password.font
                    text: "Log in as " + userPicker.currentText
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: keyboard.capsLock
            color: Theme.warn
            font.family: Theme.fontFamily
            text: "Caps Lock is on"
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: root.failCount > 0
            color: Theme.crit
            font.family: Theme.fontFamily
            font.italic: true
            text: "Authentication failed (" + root.failCount + ")"
        }
    }

    // Bottom bar, left: who / what / keyboard.
    Row {
        anchors { left: parent.left; bottom: parent.bottom; margins: 24 }
        spacing: 28

        Picker {
            id: userPicker
            glyph: ""
            model: userModel
            textRole: "name"
            currentIndex: userModel.lastIndex
            onPicked: password.forceActiveFocus()
        }
        Picker {
            id: sessionPicker
            glyph: ""
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
            onPicked: password.forceActiveFocus()
        }
        // Layout switcher (not an on-screen keyboard): only useful with 2+
        // layouts, so a single-layout machine doesn't show a dead button.
        Text {
            visible: keyboard.layouts.length > 1
            color: layoutArea.containsMouse ? Theme.accent : Theme.subtext0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            text: "  " + (visible ? keyboard.layouts[keyboard.currentLayout].shortName : "")
            MouseArea {
                id: layoutArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
                    password.forceActiveFocus()
                }
            }
        }
    }

    // Power actions SDDM says this machine supports.
    Row {
        // Centred halfway between the password box and the screen bottom.
        anchors.horizontalCenter: parent.horizontalCenter
        y: (inputCol.y + inputBox.y + inputBox.height + root.height - height) / 2
        spacing: 28

        Repeater {
            model: [
                { glyph: "", label: "Sleep", enabled: sddm.canSuspend, action: () => sddm.suspend() },
                { glyph: "", label: "Hibernate", enabled: sddm.canHibernate, action: () => sddm.hibernate() },
                { glyph: "", label: "Restart", enabled: sddm.canReboot, action: () => sddm.reboot() },
                { glyph: "", label: "Shut Down", enabled: sddm.canPowerOff, action: () => sddm.powerOff() }
            ]
            Text {
                required property var modelData
                visible: modelData.enabled
                color: mouse.containsMouse ? Theme.accent : Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                text: modelData.glyph + "  " + modelData.label
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: parent.modelData.action()
                }
            }
        }
    }
}
