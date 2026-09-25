pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// The whole notification daemon: D-Bus server, history, DND, IPC.
// Owns org.freedesktop.Notifications, so swaync must not be running.
Singleton {
    id: root

    property bool dnd: false
    property bool panelOpen: false

    // Notifications currently shown as toasts, newest first. A subset of
    // history; entries leave when they expire or get dismissed.
    property var popups: []

    // Everything the server still holds, newest first.
    // Not readonly: the offscreen preview harness overrides it with stubs.
    property var history: server.trackedNotifications.values.slice().reverse()
    readonly property int count: history.length

    // Notification carries no timestamp, so keep our own, keyed by id.
    property var times: ({})
    // Bumped every minute so the "5m" labels re-evaluate.
    property int clock: 0

    readonly property int maxHistory: 50
    readonly property string syncHint: "x-canonical-private-synchronous"

    function age(id) {
        clock; // dependency, so labels refresh
        const t = times[id];
        if (!t)
            return "";
        const m = Math.floor((Date.now() - t) / 60000);
        if (m < 1)
            return "now";
        if (m < 60)
            return m + "m";
        const h = Math.floor(m / 60);
        return h < 24 ? h + "h" : Math.floor(h / 24) + "d";
    }

    function drop(n) {
        root.popups = root.popups.filter(p => p !== n);
    }

    function clearAll() {
        // Copy first: dismissing mutates trackedNotifications underneath us.
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
        root.popups = [];
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true
        extraHints: [root.syncHint]

        onNotification: n => {
            n.tracked = true;
            root.times[n.id] = Date.now();
            n.closed.connect(() => root.drop(n));

            // x-canonical-private-synchronous: one live notification per key
            // (volume/brightness OSDs), replaced rather than stacked.
            const key = n.hints[root.syncHint];
            if (key) {
                for (const old of server.trackedNotifications.values.slice())
                    if (old !== n && old.hints[root.syncHint] === key)
                        old.dismiss();
            }

            if (!root.dnd && !root.panelOpen)
                root.popups = [n].concat(root.popups);

            const all = server.trackedNotifications.values;
            for (let i = 0; i < all.length - root.maxHistory; i++)
                all[i].dismiss();
        }
    }

    Timer {
        running: true
        interval: 60000
        repeat: true
        onTriggered: root.clock++
    }

    IpcHandler {
        target: "notifs"

        function toggle(): void {
            root.panelOpen = !root.panelOpen;
            if (root.panelOpen)
                root.popups = [];
        }
        function open(): void {
            root.panelOpen = true;
            root.popups = [];
        }
        function close(): void {
            root.panelOpen = false;
        }
        function dnd(): bool {
            root.dnd = !root.dnd;
            if (root.dnd)
                root.popups = [];
            return root.dnd;
        }
        function clear(): void {
            root.clearAll();
        }
        // "<count> <dnd> <panelOpen>", e.g. "3 false true"
        function status(): string {
            return root.count + " " + root.dnd + " " + root.panelOpen;
        }
    }
}
