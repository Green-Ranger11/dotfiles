import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".."

// Quickshell hosts StatusNotifierWatcher itself, so the kded shim in
// install.sh is no longer needed now that waybar is gone.
Segment {
    id: tray
    visible: SystemTray.items.values.length > 0

    // TEMP debug hook: qs ipc call tray dump / tray menu
    IpcHandler {
        target: "tray"
        function dump(): string {
            return SystemTray.items.values.map(i => `${i.id} hasMenu=${i.hasMenu} onlyMenu=${i.onlyMenu} menu=${i.menu}`).join("\n");
        }
        function menu(): string {
            const entry = rep.itemAt(0);
            if (!entry) return "no items";
            entry.openMenu();
            return "opened " + entry.modelData.id;
        }
    }

    Repeater {
        id: rep
        model: SystemTray.items

        Item {
            id: entry
            required property SystemTrayItem modelData
            required property int index
            Layout.alignment: Qt.AlignVCenter
            // A bit smaller than Segment's default 6px gap gives between bar
            // modules, plus its own left margin: SNI icons sit edge-to-edge
            // otherwise and read as one blob instead of separate icons.
            Layout.leftMargin: index === 0 ? 0 : 4
            implicitWidth: 14
            implicitHeight: 14

            IconImage {
                id: icon
                anchors.fill: parent
                source: entry.modelData.icon
                opacity: hover.containsMouse ? 1 : 0.85
                // Colorized by MultiEffect below; the raw pixmap itself must
                // stay invisible or it shows through underneath the effect.
                visible: false
                // MultiEffect can only sample a hidden maskSource through a
                // layer; without this the mask is empty and nothing draws.
                layer.enabled: true

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }
            }

            // Monochrome: a flat rectangle masked by the icon's own alpha
            // shape. colorization (tried first) keeps the source's internal
            // shading/holes, so multi-tone icons still looked patchy next to
            // a solid glyph like the bar's own filled battery icon; masking
            // ignores that and always renders one flat fill.
            Rectangle {
                anchors.fill: icon
                color: hover.containsMouse ? Theme.iconOn : Theme.iconMid
                opacity: icon.opacity
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: icon
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1
                }
            }

            // Right-click menu. SystemTrayItem.display() wants a window, not an
            // item, so drive the item's dbusmenu through an anchor instead.
            // Anchored to the item (not window coords): a mapToItem() binding
            // ran once before layout and froze at x = 0, top-left of the bar.
            QsMenuAnchor {
                id: menu
                menu: entry.modelData.menu
                anchor {
                    item: entry
                    rect.width: 1
                    rect.height: 1
                }
            }

            // Opens at the given point in entry coords; defaults to under the icon.
            function openMenu(x = 0, y = entry.height) {
                menu.anchor.rect.x = x;
                menu.anchor.rect.y = y;
                menu.open();
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: mouse => {
                    const item = entry.modelData;
                    // Items that only carry a menu (no activate handler) should
                    // open it on left click too, the way waybar behaved.
                    if (mouse.button === Qt.RightButton || item.onlyMenu) entry.openMenu(mouse.x, mouse.y);
                    else if (mouse.button === Qt.MiddleButton) item.secondaryActivate();
                    else item.activate();
                }
            }
        }
    }
}
