import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import ".."

// mpris: first player that is actually playing, else the first one.
Segment {
    id: chip
    bg: Theme.mantle
    interactive: true
    visible: player !== null

    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null

    onClicked: mouse => {
        if (!player) return;
        if (mouse.button === Qt.LeftButton) player.togglePlaying();
        else if (mouse.button === Qt.RightButton) player.next();
        else player.previous();
    }

    Label {
        Layout.maximumWidth: 260
        elide: Text.ElideRight
        text: {
            const p = chip.player;
            if (!p) return "";
            const title = p.trackTitle || p.identity || "";
            const artist = p.trackArtist ? p.trackArtist + " - " : "";
            return (p.isPlaying ? "\uead1 " : "\ueb2c ") + artist + title;
        }
    }

}
