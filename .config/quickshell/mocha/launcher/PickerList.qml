import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import ".."

// Shared picker chrome: fullscreen overlay, centred sharp-cornered box with a
// search line (optional) and a filtered list. Feed it `entries`, listen for
// `accepted`. Entry shape: { text, sub, icon (url, optional), data, keep and
// color (optional; row text colour when not selected) }.
PanelWindow {
    id: root

    property var entries: []
    // Accent heading above the search box.
    property string title: "Search"
    // "63 applications": the word after the count line's number.
    property string countNoun: "results"
    // false: no text field, no filtering, bare vim keys drive the cursor.
    property bool searchable: true
    property bool showIcons: false
    // Footer keycaps: [key, label] pairs. Empty list hides the footer.
    property var hints: [["↑↓", "navigate"], ["⏎", "select"], ["esc", "close"]]
    property int boxWidth: 700
    property int boxHeight: 480
    // Not Theme.borderWidth: the bar dropped that property mid-session.
    readonly property int frame: 2
    // Compact rows: padding lives on the box frame, not between rows.
    // Callers raise this for two-line rows (AppLauncher).
    property int rowHeight: 28
    property int rowSpacing: 2
    // Icon box side, in px. Callers may raise this for a denser/bigger look.
    property int iconSize: 24
    // AppLauncher-only: name on top, sub (genericName/comment) on its own
    // line below, instead of the default same-line "name  sub".
    property bool twoLineRows: false
    // Read-only peek at the search text, for callers that reorder/group
    // `entries` themselves (e.g. a "recent" pin list shown only when empty).
    readonly property alias query: input.text
    // Prompt mode (NetworkPicker's Wi-Fi password): masked field, no list;
    // Enter emits `submitted` with the typed text instead of `accepted`.
    property bool password: false
    // false: no title/search/count block, just the list (Clipboard).
    property bool showHeader: true
    // Vim-driven pickers only: "/" slides in a search field (Clipboard).
    property bool slashSearch: false
    property bool searching: false
    // Typing goes to the field: a real search box, or one opened with "/".
    readonly property bool typing: searchable || searching
    // Modifiers held on the last Enter (0 for a click), for alternate
    // actions such as Shift+Enter in BitwardenPicker.
    property int acceptModifiers: 0
    signal accepted(var entry)
    signal removed(var entry)
    signal submitted(string text)

    // `shown` drives the animation. The window stays mapped until the close
    // animation finishes, otherwise it would blink out on frame one.
    property bool shown: false
    property bool intro: false
    property bool gPending: false

    visible: false
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-picker"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    function open() { visible = true; shown = true; }
    function close() { console.log("DBG close", new Error().stack); shown = false; gPending = false; }
    function toggle() { if (shown) close(); else open(); }

    onVisibleChanged: {
        if (visible) {
            searching = false;
            input.text = "";
            list.currentIndex = 0;
            intro = true;
            introTimer.restart();
            // Focus first, before any animation: keystrokes are never dropped.
            if (searchable) input.forceActiveFocus();
            else keys.forceActiveFocus();
        }
    }

    Timer { id: introTimer; interval: 340; onTriggered: root.intro = false }

    // Every entry gets a `section` key (default "") so ListView's section
    // role is always registered, even for pickers that never set one.
    function withSection(e) { return e.section !== undefined ? e : Object.assign({ section: "" }, e); }

    readonly property var filtered: {
        if (!typing) return entries.map(withSection);
        const q = input.text.toLowerCase().trim();
        const base = q === "" ? entries
            : entries.filter(e => (e.text + " " + (e.sub || "")).toLowerCase().indexOf(q) !== -1);
        return base.map(withSection);
    }
    // Filtering restarts at the top; a clipboard delete keeps your place.
    onFilteredChanged: list.currentIndex = typing
        ? 0
        : Math.max(0, Math.min(list.currentIndex, filtered.length - 1))

    function accept() {
        if (password) {
            const t = input.text;
            close();
            root.submitted(t);
            return;
        }
        const e = list.currentIndex >= 0 ? filtered[list.currentIndex] : null;
        // `keep: true` entries (on/off toggles) leave the picker open.
        if (!e || !e.keep) close();
        if (e) root.accepted(e);
    }

    // Box height that shows exactly `rows` rows plus `sections` section
    // headers (22px each) under the title/search/count block and footer.
    function fitRows(rows, sections) {
        const inset = frame + Theme.padding;
        const listH = rows * rowHeight + Math.max(0, rows - 1) * rowSpacing + sections * 22;
        return inset + list.y + listH + inset + (footer.visible ? footer.height + inset : 0);
    }

    function moveBy(n) {
        if (list.count === 0) return;
        list.currentIndex = Math.max(0, Math.min(list.count - 1, list.currentIndex + n));
        list.positionViewAtIndex(list.currentIndex, ListView.Contain);
    }
    function halfPage() { return Math.max(1, Math.floor(list.height / rowHeight / 2)); }

    // One key table for all three pickers. Ctrl motions work everywhere; the
    // bare vim keys only where there is no text field to steal them.
    function handleKey(e) {
        const ctrl = (e.modifiers & Qt.ControlModifier) !== 0;
        const vim = !root.typing && !ctrl;
        switch (e.key) {
        case Qt.Key_Escape:
            // First Esc closes a "/" search, the next one the picker.
            if (root.searching) {
                root.searching = false;
                input.text = "";
                keys.forceActiveFocus();
            } else root.close();
            e.accepted = true;
            return;
        case Qt.Key_Slash:
            if (vim && root.slashSearch) {
                root.searching = true;
                input.forceActiveFocus();
                e.accepted = true;
                return;
            }
            break;
        case Qt.Key_Up: root.moveBy(-1); e.accepted = true; return;
        case Qt.Key_Down: root.moveBy(1); e.accepted = true; return;
        case Qt.Key_PageUp: root.moveBy(-2 * root.halfPage()); e.accepted = true; return;
        case Qt.Key_PageDown: root.moveBy(2 * root.halfPage()); e.accepted = true; return;
        case Qt.Key_Home: if (vim) { root.moveBy(-list.count); e.accepted = true; } break;
        case Qt.Key_End: if (vim) { root.moveBy(list.count); e.accepted = true; } break;
        case Qt.Key_Return:
        case Qt.Key_Enter: root.acceptModifiers = e.modifiers; root.accept(); e.accepted = true; return;
        case Qt.Key_J: if (ctrl || vim) { root.moveBy(1); e.accepted = true; } break;
        case Qt.Key_K: if (ctrl || vim) { root.moveBy(-1); e.accepted = true; } break;
        case Qt.Key_D:
            if (ctrl) { root.moveBy(root.halfPage()); e.accepted = true; }
            else if (vim && list.currentIndex >= 0 && root.filtered.length) {
                root.removed(root.filtered[list.currentIndex]);
                e.accepted = true;
            }
            break;
        case Qt.Key_U: if (ctrl) { root.moveBy(-root.halfPage()); e.accepted = true; } break;
        case Qt.Key_L: if (vim) { root.accept(); e.accepted = true; } break;
        case Qt.Key_Q: if (vim) { root.close(); e.accepted = true; } break;
        case Qt.Key_G:
            if (vim) {
                if (e.modifiers & Qt.ShiftModifier) root.moveBy(list.count);
                else if (root.gPending) root.moveBy(-list.count);
                else { root.gPending = true; e.accepted = true; return; }
                e.accepted = true;
            }
            break;
        }
        root.gPending = false;
    }

    // Click-off to dismiss. Outside the box, so it never eats list clicks.
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Rectangle {
        id: box
        anchors.centerIn: parent
        width: root.boxWidth
        height: root.boxHeight
        color: Theme.mainBg
        radius: Theme.radius
        border.width: root.frame
        border.color: Theme.mainBr

        // Open: fade + scale past 1 + rise. Close: the same, faster, no bounce.
        opacity: root.shown ? 1 : 0
        scale: root.shown ? 1 : 0.93
        transform: Translate {
            y: root.shown ? 0 : 18
            Behavior on y { NumberAnimation { duration: 210; easing.type: Easing.OutCubic } }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: root.shown ? 110 : 110
                easing.type: Easing.OutQuad
                onRunningChanged: { console.log("DBG opacityAnim running", running, "shown", root.shown); if (!running && !root.shown) root.visible = false; }
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: root.shown ? 220 : 120
                easing.type: root.shown ? Easing.OutBack : Easing.InQuad
                easing.overshoot: 1.6
            }
        }

        // Swallows clicks so the dismiss-on-click-off area never sees them.
        MouseArea { anchors.fill: parent }

        // Catches keys whenever there is no text field to hold focus.
        Item {
            id: keys
            anchors.fill: parent
            Keys.onPressed: e => root.handleKey(e)
        }

        Column {
            id: body
            anchors {
                top: parent.top; left: parent.left; right: parent.right
                bottom: footer.visible ? footer.top : parent.bottom
                margins: root.frame + Theme.padding
            }
            spacing: Theme.spacing * 2

            Text {
                visible: root.showHeader
                text: root.title
                textFormat: Text.PlainText
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeight
            }

            // Boxed search field. Vim-driven pickers slide it in on "/".
            Rectangle {
                readonly property bool open: root.showHeader && (root.typing || root.password)
                visible: height > 0
                width: parent.width
                height: open ? 32 : 0
                opacity: open ? 1 : 0
                clip: true
                Behavior on height { enabled: root.slashSearch; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                Behavior on opacity { enabled: root.slashSearch; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                color: Theme.base
                radius: Theme.radius
                border.width: 1
                border.color: input.text.length > 0 ? Theme.accent : Theme.surface1

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: Theme.padding
                    anchors.rightMargin: Theme.padding
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.mainFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    selectionColor: Theme.mainBr
                    selectedTextColor: Theme.mainBg
                    echoMode: root.password ? TextInput.Password : TextInput.Normal
                    clip: true

                    cursorDelegate: Rectangle {
                        width: 2
                        color: Theme.accent
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.15; duration: 480; easing.type: Easing.InOutQuad }
                            NumberAnimation { to: 1.0; duration: 480; easing.type: Easing.InOutQuad }
                        }
                    }

                    Keys.onPressed: e => root.handleKey(e)
                }
            }

            Text {
                id: counter
                visible: root.showHeader && !root.password
                text: root.filtered.length + " " + root.countNoun
                textFormat: Text.PlainText
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                transformOrigin: Item.Left
                onTextChanged: pop.restart()
            }

            SequentialAnimation {
                id: pop
                ParallelAnimation {
                    NumberAnimation { target: counter; property: "scale"; to: 1.12; duration: 70; easing.type: Easing.OutQuad }
                    ColorAnimation { target: counter; property: "color"; to: Theme.accent; duration: 70 }
                }
                ParallelAnimation {
                    NumberAnimation { target: counter; property: "scale"; to: 1.0; duration: 140; easing.type: Easing.OutBack }
                    ColorAnimation { target: counter; property: "color"; to: Theme.overlay0; duration: 220 }
                }
            }

            ListView {
                id: list
                width: parent.width
                height: Math.max(0, parent.height - y)
                visible: !root.password
                clip: true
                model: root.filtered
                currentIndex: 0
                spacing: root.rowSpacing
                keyNavigationWraps: false
                boundsBehavior: Flickable.StopAtBounds
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 110
                highlightResizeDuration: 0

                // Slides between rows instead of jumping. Left edge bar
                // matches the active-tab underline convention (Segment.qml):
                // Theme.accent at Theme.underline thickness, not a one-off.
                highlight: Rectangle {
                    color: Theme.surface0
                    Rectangle {
                        width: Theme.underline
                        height: parent.height
                        color: Theme.accent
                    }
                }

                // Set by callers that group `entries` themselves (currently
                // only AppLauncher's "Recent" pin list); a "" section is
                // never shown, so Clipboard/Emoji render no header at all.
                section.property: "section"
                section.criteria: ViewSection.FullString
                section.delegate: Item {
                    width: list.width
                    height: section === "" ? 0 : 22

                    Text {
                        visible: section !== ""
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.padding
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        text: section
                        textFormat: Text.PlainText
                        color: Theme.overlay0
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 4
                        font.weight: Font.Bold
                    }
                }

                delegate: Item {
                    id: entry
                    required property int index
                    required property var modelData
                    readonly property bool cur: ListView.isCurrentItem
                    width: ListView.view.width
                    height: root.rowHeight

                    opacity: 0
                    transform: [
                        Translate { id: slide; x: -14 },
                        Translate {
                            x: entry.cur ? 6 : 0
                            Behavior on x { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                        }
                    ]

                    // Staggered on open, a plain fade while filtering.
                    SequentialAnimation {
                        running: true
                        PauseAnimation { duration: root.intro ? Math.min(entry.index, 11) * 11 : 0 }
                        ParallelAnimation {
                            NumberAnimation { target: entry; property: "opacity"; to: 1; duration: 130; easing.type: Easing.OutCubic }
                            NumberAnimation { target: slide; property: "x"; to: 0; duration: 170; easing.type: Easing.OutCubic }
                        }
                    }

                    Row {
                        id: rowContent
                        anchors.fill: parent
                        anchors.leftMargin: Theme.padding
                        anchors.rightMargin: Theme.padding
                        spacing: Theme.padding

                        Item {
                            visible: root.showIcons
                            width: root.showIcons ? root.iconSize : 0
                            height: parent.height

                            IconImage {
                                id: ico
                                anchors.centerIn: parent
                                implicitSize: root.iconSize
                                asynchronous: true
                                source: entry.modelData.icon || ""
                                visible: status === Image.Ready
                            }

                            // Missing or broken icon: a neutral glyph, same box.
                            Text {
                                anchors.centerIn: parent
                                visible: !ico.visible
                                text: ""
                                color: Theme.surface2
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                        }

                        // AppLauncher-only category tag (a.categories -> a
                        // Theme colour). No `badge` field on an entry means
                        // no box at all, so Clipboard/Emoji are untouched.
                        Item {
                            visible: !!entry.modelData.badge
                            width: entry.modelData.badge ? 10 : 0
                            height: parent.height

                            Rectangle {
                                anchors.centerIn: parent
                                width: 6
                                height: 6
                                radius: Theme.radius
                                color: entry.modelData.badge ? entry.modelData.badge.color : "transparent"
                            }
                        }

                        // Two-line mode (AppLauncher): name on top, sub below.
                        Column {
                            visible: root.twoLineRows
                            y: (parent.height - implicitHeight) / 2
                            width: Math.max(0, rowContent.width - x)
                            spacing: 1

                            Text {
                                width: parent.width
                                text: entry.modelData.text
                                textFormat: Text.PlainText
                                color: entry.cur ? Theme.mainBr : (entry.modelData.color || Theme.mainFg)
                                Behavior on color { ColorAnimation { duration: 120 } }
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.weight: Theme.fontWeight
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                visible: !!entry.modelData.sub
                                text: entry.modelData.sub || ""
                                textFormat: Text.PlainText
                                color: entry.cur ? Theme.subtext0 : Theme.overlay0
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                elide: Text.ElideRight
                            }
                        }

                        // Default one-line mode (Clipboard/Emoji unchanged).
                        Text {
                            visible: !root.twoLineRows
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            text: entry.modelData.text
                            textFormat: Text.PlainText
                            color: entry.cur ? Theme.mainBr : (entry.modelData.color || Theme.mainFg)
                            Behavior on color { ColorAnimation { duration: 120 } }
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.weight: Theme.fontWeight
                            elide: Text.ElideRight
                            width: Math.min(implicitWidth, parent.width - x)
                        }

                        Text {
                            visible: !root.twoLineRows && !!entry.modelData.sub
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            text: entry.modelData.sub || ""
                            textFormat: Text.PlainText
                            color: entry.cur ? Theme.subtext0 : Theme.overlay0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            elide: Text.ElideRight
                            width: Math.max(0, parent.width - x)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: list.currentIndex = entry.index
                        onClicked: { list.currentIndex = entry.index; root.acceptModifiers = 0; root.accept(); }
                    }
                }
            }
        }

        // Keycap hints along the bottom edge.
        Row {
            id: footer
            visible: root.hints.length > 0
            anchors { left: parent.left; bottom: parent.bottom; margins: root.frame + Theme.padding }
            spacing: Theme.padding + 4

            Repeater {
                model: root.hints
                Row {
                    required property var modelData
                    spacing: 6
                    Rectangle {
                        width: key.implicitWidth + 8
                        height: key.implicitHeight + 4
                        color: Theme.surface0
                        radius: Theme.radius
                        Text {
                            id: key
                            anchors.centerIn: parent
                            text: modelData[0]
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 4
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData[1]
                        color: Theme.overlay0
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 4
                    }
                }
            }
        }
    }
}
