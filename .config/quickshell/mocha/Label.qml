import QtQuick
import QtQuick.Layouts

// Every piece of text in the bar goes through here, so the font lives in
// exactly one place.
Text {
    Layout.alignment: Qt.AlignVCenter
    verticalAlignment: Text.AlignVCenter
    color: Theme.mainFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
}
