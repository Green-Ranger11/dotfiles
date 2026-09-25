import QtQuick
import QtQuick.Layouts

// Powerline divider between two segments, same glyphs waybar used:
//   left  = U+E0B2, right = U+E0B0 (solid arrows)
//   leftInv = U+E0D6, rightInv = U+E0D7 (round caps)
// `fg` is the colour of the segment the curve belongs to, `bg` the one behind.
Item {
    id: div
    property string glyph: ""
    property color fg: Theme.mantle
    property color bg: "transparent"

    Layout.fillHeight: true
    implicitWidth: label.implicitWidth

    Rectangle {
        anchors.fill: parent
        color: div.bg
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: div.glyph
        color: div.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.dividerSize
    }
}
