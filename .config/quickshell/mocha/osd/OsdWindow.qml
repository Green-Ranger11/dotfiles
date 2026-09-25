import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."

// The one OSD frame: everything visual, the auto-hide timer and the fade.
// Sources call show(); nothing in here knows what a source is.
PanelWindow {
    id: win

    property string icon: ""
    property int pct: 0
    property bool dim: false
    property bool shown: false

    function show(icon, pct, dim) {
        win.icon = icon;
        win.pct = pct;
        win.dim = dim === true;

        // Follow the focused monitor. Hyprland's monitor and Quickshell's
        // screen only share a name, so match on that.
        const m = Hyprland.focusedMonitor;
        if (m) {
            const s = Quickshell.screens.find(x => x.name === m.name);
            if (s) win.screen = s;
        }

        win.shown = true;
        hideTimer.restart();
    }

    Timer { id: hideTimer; interval: 1500; onTriggered: win.shown = false }

    // Stay mapped until the fade-out has actually finished.
    visible: shown || frame.opacity > 0

    anchors.bottom: true
    margins.bottom: 140
    implicitWidth: 340
    implicitHeight: 56
    color: "transparent"

    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    // Empty input region: clicks fall through to whatever is underneath.
    mask: Region {}

    Rectangle {
        id: frame
        anchors.fill: parent
        color: Theme.mainBg
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.mainBr

        opacity: win.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 140 } }

        Label {
            id: glyph
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding + 4
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.iconSize + 6
            text: win.icon
            color: win.dim ? Theme.overlay0 : Theme.mainFg
            font.pixelSize: Theme.iconSize
        }

        Label {
            id: value
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding + 4
            anchors.verticalCenter: parent.verticalCenter
            width: 46
            horizontalAlignment: Text.AlignRight
            text: win.pct + "%"
            color: win.dim ? Theme.overlay0 : Theme.mainFg
        }

        Rectangle {
            id: track
            anchors.left: glyph.right
            anchors.right: value.left
            anchors.leftMargin: Theme.padding
            anchors.rightMargin: Theme.padding
            anchors.verticalCenter: parent.verticalCenter
            height: 8
            radius: Theme.radius
            color: Theme.surface0

            Rectangle {
                width: track.width * Math.max(0, Math.min(1, win.pct / 100))
                height: track.height
                radius: Theme.radius
                color: win.dim ? Theme.overlay0 : Theme.mainBr
                Behavior on width { NumberAnimation { duration: 90 } }
            }
        }
    }
}
