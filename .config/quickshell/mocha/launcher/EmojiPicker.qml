import Quickshell.Io

PickerList {
    id: picker
    title: "Emoji"
    countNoun: "emoji"
    hints: [["↑↓", "navigate"], ["⏎", "copy"], ["esc", "close"]]

    onAccepted: e => copy.exec(["wl-copy", "--", e.data])

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
            picker.entries = out;
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
