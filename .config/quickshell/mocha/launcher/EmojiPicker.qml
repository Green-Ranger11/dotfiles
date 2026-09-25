import Quickshell.Io

PickerList {
    id: picker
    title: "Emoji"
    countNoun: "emoji"
    hints: [["↑↓", "navigate"], ["⏎", "copy"], ["esc", "close"]]

    onAccepted: e => copy.exec(["wl-copy", "--", e.data])

    // Same data rofimoji uses, straight off disk. One shell glob beats ten
    // FileViews. ponytail: re-read only at startup; emoji sets don't move.
    Process {
        running: true
        command: ["sh", "-c", "cat /usr/lib/python3*/site-packages/picker/data/emojis_*.csv"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.split("\n")) {
                    const sp = line.indexOf(" ");
                    if (sp < 1) continue;
                    out.push({
                        text: line.substring(0, sp),
                        sub: line.substring(sp + 1).replace(/<\/?small>/g, ""),
                        data: line.substring(0, sp)
                    });
                }
                picker.entries = out;
            }
        }
    }

    Process { id: copy }

    IpcHandler {
        target: "emoji"
        function toggle(): void { picker.toggle(); }
    }
}
