import Quickshell
import Quickshell.Io

PickerList {
    id: picker
    title: "Emoji"
    countNoun: "emoji"
    // Vim-driven like the clipboard: j/k to move, "/" slides in the search.
    searchable: false
    slashSearch: true
    hints: [["j/k", "navigate"], ["/", "search"], ["⏎", "copy"], ["q", "close"]]

    // Every emoji from emojis.csv, and the most recently copied ones (newest
    // first, capped at 50) persisted in the Quickshell state dir.
    property var all: []
    property var recent: []

    // Recent emoji on top under a "Recent" heading, then everything else in
    // file order. Search still filters both.
    entries: {
        const byChar = {};
        for (const e of all) byChar[e.data] = e;
        const top = recent.filter(c => byChar[c]).map(c => Object.assign({}, byChar[c], { section: "Recent" }));
        const seen = new Set(recent);
        return top.concat(all.filter(e => !seen.has(e.data)));
    }

    onAccepted: e => {
        copy.exec(["wl-copy", "--", e.data]);
        recent = [e.data].concat(recent.filter(c => c !== e.data)).slice(0, 50);
        recentFile.setText(recent.join("\n") + "\n");
    }

    FileView {
        id: recentFile
        path: Quickshell.stateDir + "/emoji-recent"
        printErrors: false // missing until the first copy
        onLoaded: picker.recent = text().split("\n").filter(c => c)
    }

    // emojis.csv: rofimoji's emoji data (Unicode names), vendored so rofimoji
    // itself isn't needed. Regenerate from a rofimoji install if Unicode adds
    // emoji: cat /usr/lib/python3*/site-packages/picker/data/emojis_*.csv
    FileView {
        path: Qt.resolvedUrl("emojis.csv")
        onLoaded: {
            const out = [];
            for (const line of text().split("\n")) {
                const sp = line.indexOf(" ");
                if (sp < 1)
                    continue;
                out.push({
                    text: line.substring(0, sp),
                    sub: line.substring(sp + 1).replace(/<\/?small>/g, ""),
                    data: line.substring(0, sp)
                });
            }
            picker.all = out;
        }
    }

    Process {
        id: copy
    }

    IpcHandler {
        target: "emoji"
        function toggle(): void {
            picker.toggle();
        }
    }
}
