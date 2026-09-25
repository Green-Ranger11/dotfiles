import Quickshell.Io

PickerList {
    id: picker
    // Cursor-driven with vim keys; "/" slides in a search field when needed.
    searchable: false
    slashSearch: true
    title: "Clipboard"
    countNoun: "entries"
    hints: [["j/k", "navigate"], ["/", "search"], ["⏎", "copy"], ["d", "delete"], ["q", "close"]]
    // Exactly 5 rows visible; the rest scroll (j/k, ^d/^u).
    boxHeight: fitRows(5, 0)

    // cliphist list is cheap; re-read every time the picker opens.
    onVisibleChanged: if (visible) lister.running = true

    // Guarded: a stale id decodes to nothing, and an unguarded pipe would then
    // hand wl-copy an empty stream and wipe the clipboard.
    onAccepted: e => copy.exec(["sh", "-c",
        't=$(mktemp); cliphist decode "$1" > "$t"; [ -s "$t" ] && wl-copy < "$t"; rm -f "$t"',
        "_", e.data])

    // cliphist delete matches the whole `list` line on stdin, so keep it around.
    onRemoved: e => remover.exec(["sh", "-c", 'printf "%s\n" "$1" | cliphist delete', "_", e.raw])

    Process {
        id: lister
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.split("\n")) {
                    const tab = line.indexOf("\t");
                    if (tab < 1) continue;
                    out.push({
                        text: line.substring(tab + 1),
                        sub: "",
                        data: line.substring(0, tab),
                        raw: line
                    });
                }
                picker.entries = out;
            }
        }
    }

    Process { id: copy }
    Process { id: remover; onExited: lister.running = true }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { picker.toggle(); }
    }
}
