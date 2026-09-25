import QtQuick
import Quickshell
import Quickshell.Io

// Bitwarden (rbw) picker, replacing rofi-rbw. Toggled over IPC
// (qs ipc call bitwarden toggle), bound to Super+/.
//
// Copies instead of typing: rofi-rbw's `action = type` needs wtype, which
// isn't installed. Copies are marked --sensitive, so cliphist skips them,
// and the clipboard is cleared after 30s if it still holds the secret.
PickerList {
    id: picker
    title: "Bitwarden"
    countNoun: "items"
    // Vim-driven like clipboard/emoji: j/k to move, "/" slides in the search.
    searchable: false
    slashSearch: true
    hints: [["j/k", "navigate"], ["/", "search"], ["⏎", "copy password"], ["⇧⏎", "copy username"], ["q", "close"]]

    // Vault items from rbw, and the ids of the 20 most recently copied ones
    // (ids only, no secrets) persisted in the Quickshell state dir.
    property var items: []
    property var recent: []

    // Recently used items on top under a "Recent" heading, then A-Z.
    entries: {
        const byId = {};
        for (const e of items) byId[e.data.id] = e;
        const top = recent.filter(id => byId[id]).map(id => Object.assign({}, byId[id], { section: "Recent" }));
        const seen = new Set(recent);
        return top.concat(items.filter(e => !seen.has(e.data.id)));
    }

    FileView {
        id: recentFile
        path: Quickshell.stateDir + "/bitwarden-recent"
        printErrors: false // missing until the first copy
        onLoaded: picker.recent = text().split("\n").filter(id => id)
    }
    boxWidth: 560

    // Unlock first (rbw's pinentry must not sit under this overlay), then
    // list, then show. Cancelled unlock: nothing opens.
    function toggleVault() {
        if (shown) close();
        else if (!loader.running) loader.running = true;
    }

    onAccepted: e => {
        recent = [e.data.id].concat(recent.filter(id => id !== e.data.id)).slice(0, 20);
        recentFile.setText(recent.join("\n") + "\n");
        if (acceptModifiers & Qt.ShiftModifier)
            copy.exec(["sh", "-c", 'printf %s "$1" | wl-copy', "_", e.data.user]);
        else
            copy.exec(["sh", "-c", `
                v=$(rbw get "$1") || exit 1
                printf %s "$v" | wl-copy --sensitive
                notify-send -a Bitwarden -t 3000 "Password copied" "$2 (clears in 30s)"
                sleep 30
                [ "$(wl-paste -n 2>/dev/null)" = "$v" ] && wl-copy --clear
            `, "_", e.data.id, e.text]);
    }

    Process {
        id: loader
        command: ["sh", "-c", "rbw unlock && rbw list --fields id,name,user,folder"]
        // Surface rbw failures (not configured, wrong password) instead of
        // silently opening nothing. A cancelled pinentry also lands here.
        stderr: StdioCollector {
            onStreamFinished: if (text.trim() !== "")
                notify.exec(["notify-send", "-a", "Bitwarden", "-u", "critical", "rbw failed", text.trim().split("\n")[0]])
        }
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.split("\n")) {
                    const [id, name, user, folder] = line.split("\t");
                    if (!id) continue;
                    out.push({ text: name, sub: [user, folder].filter(x => x).join("  "), data: { id: id, user: user || "" } });
                }
                out.sort((a, b) => a.text.localeCompare(b.text));
                picker.items = out;
                if (out.length) picker.open();
            }
        }
    }

    Process { id: copy }
    Process { id: notify }

    IpcHandler {
        target: "bitwarden"
        function toggle(): void { picker.toggleVault(); }
    }
}
