// The mocha bar laid out for macOS: same widgets and order as the bar in
// ../mocha/shell.qml, minus what macOS can't host (Tray: macOS 27 draws
// menu-bar items as one window; Notifications: macOS can't hand them to
// other apps). On the built-in display the centre group splits around the
// notch.
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../mocha"
import "../mocha/modules"

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    // MacBook notch: the built-in panel's top centre is hardware.
    readonly property bool notched: modelData.name.indexOf("Built-in") !== -1
    readonly property int notchWidth: notched ? 220 : 0

    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    color: Theme.mainBg

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2
        color: Theme.accent
    }

    RowLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.padding
        spacing: Theme.groupSpacing

        User {}
        Workspaces {}
        WindowCount {}
    }

    // Centre, left of the notch (or of centre).
    RowLayout {
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: bar.notched ? bar.notchWidth / 2 : Theme.groupSpacing / 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: Theme.groupSpacing

        RowLayout {
            spacing: Theme.spacing
            Temperature {}
            Memory {}
            Cpu {}
        }

        Distro {}
    }

    // Centre, right of the notch.
    RowLayout {
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: bar.notched ? bar.notchWidth / 2 : Theme.groupSpacing / 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: Theme.groupSpacing

        RowLayout {
            spacing: Theme.spacing
            IdleInhibitor {}
            Time {}
        }

        RowLayout {
            spacing: Theme.spacing
            Network {}
            Vpn {}
            Bluetooth {}
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: Theme.padding
        spacing: Theme.groupSpacing

        Media {}

        RowLayout {
            spacing: Theme.spacing
            Volume {}
            Backlight {}
            Battery {}
        }

        PowerMenu {}
    }
}
