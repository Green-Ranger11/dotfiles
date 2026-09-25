import Quickshell
import Quickshell.Io
import ".."

PickerList {
    id: picker
    title: "Applications"
    boxWidth: 560
    countNoun: "applications"
    hints: [["↑↓", "navigate"], ["⏎", "launch"], ["esc", "close"]]
    showIcons: true
    // Launcher-only look: bigger icon, name+sub stacked, room for both.
    iconSize: 24
    twoLineRows: true
    rowHeight: 40

    // Category -> Theme colour, a handful of buckets. Categories= not in
    // this map (or missing) just gets no badge instead of a guess.
    readonly property var categoryColors: ({
        Development: Theme.mauve,
        AudioVideo: Theme.teal,
        Audio: Theme.teal,
        Video: Theme.teal,
        System: Theme.peach,
        Network: Theme.sapphire,
        Graphics: Theme.pink,
        Game: Theme.red,
        Office: Theme.yellow
    })

    function badgeFor(cats) {
        for (const c of (cats || [])) {
            const color = picker.categoryColors[c];
            if (color) return { label: c, color: color };
        }
        return null;
    }

    // Recent-apps persistence was dropped: it depended on FileView.adapter /
    // JsonAdapter / watchChanges / reload() / writeAdapter(), none of which
    // exist on the installed Quickshell (0.3.1) -- /usr/lib/qt6/qml/Quickshell/
    // Io/FileView.qml only has text()/data(), no adapter API at all. That API
    // may exist in a newer Quickshell; re-add if this system's ever upgraded.

    // iconPath(name, true) resolves against the icon theme and returns "" when
    // the name is missing, which the delegate turns into a fallback glyph.
    entries: DesktopEntries.applications.values
        .filter(a => !a.noDisplay)
        .map(a => ({
            text: a.name,
            sub: a.genericName || a.comment || "",
            icon: a.icon ? Quickshell.iconPath(a.icon, true) : "",
            badge: picker.badgeFor(a.categories),
            data: a
        }))
        .sort((a, b) => a.text.localeCompare(b.text))

    onAccepted: e => e.data.execute()

    IpcHandler {
        target: "launcher"
        function toggle(): void { picker.toggle(); }
    }
}
