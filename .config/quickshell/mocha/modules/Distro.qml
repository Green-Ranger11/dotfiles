import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

// Arch mark, centre of the bar: opens the launcher.
Segment {
    id: seg
    interactive: true
    padding: 12

    Process { id: proc }

    onClicked: {
        proc.command = ["qs", "-p", Quickshell.shellDir,
                        "ipc", "call", "launcher", "toggle"];
        proc.running = true;
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        // linux-archlinux
        // Arch on Linux, Apple on macOS (quickshell-macos).
        text: Qt.platform.os === "osx" ? "\uf179" : "\uf303"
        color: Theme.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize + 3
    }
}
