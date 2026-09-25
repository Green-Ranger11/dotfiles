//@ pragma UseQApplication
//@ pragma IconTheme Breeze-Dark-Green
// Platform (dbusmenu) tray menus need QApplication rather than QGuiApplication.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "modules"
import "osd"
import "notifications"
import "launcher"
import "lock"

ShellRoot {
    // Volume / brightness popups: one window that follows the focused monitor.
    Osd {}

    // Toast stack + notification centre. The server takes the bus name as soon
    // as swaync releases it, so this is inert until swaync is stopped.
    NotificationLayer {}

    // Real WlSessionLock, triggered via `qs ipc call lock trigger`. See
    // lock/LockLayer.qml for why this has to live here instead of running as
    // its own `qs -p` process.
    LockLayer {}

    // rofi replacements: toggled over IPC (qs ipc call launcher|emoji|clipboard|network|bluetooth|power|bitwarden toggle).
    AppLauncher {}
    EmojiPicker {}
    ClipboardPicker {}
    NetworkPicker {}
    BluetoothPicker {}
    PowerPicker {}
    BitwardenPicker {}

    Variants {
        // One bar per monitor, rebuilt on hotplug (the external monitor moves
        // between the Philips at work and the AOC at home).
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            // Docked: flush to the top edge, full width, no gaps.
            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.barHeight
            color: Theme.mainBg
            WlrLayershell.namespace: "quickshell-bar"

            // Thin accent line along the bottom edge, so the bar still reads as
            // a separate surface without a border box.
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

            RowLayout {
                anchors.centerIn: parent
                height: parent.height
                spacing: Theme.groupSpacing

                RowLayout {
                    spacing: Theme.spacing
                    Temperature {}
                    Memory {}
                    Cpu {}
                }

                Distro {}

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
                Tray {}

                RowLayout {
                    spacing: Theme.spacing
                    Volume {}
                    Backlight {}
                    Notifications {}
                    Battery {}
                }

                PowerMenu {}
            }
        }
    }
}
