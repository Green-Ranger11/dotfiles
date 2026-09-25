import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

// The real lock entry, folded into the always-running shell instead of
// spawned as its own `qs -p` process. shell.qml (the standalone ShellRoot
// version) can never work that way: LockSurface.qml reaches up to Theme via
// "..", and Quickshell refuses relative imports that escape the config root
// a bare-file `qs -p .../lock/shell.qml` invocation is rooted at -- same
// restriction documented in notifications/shell.qml and lock/test.qml.
// Living here, inside mocha/'s own shell.qml, means the import never leaves
// the root that's already loaded, so there is nothing to escape.
Item {
    id: root

    LockContext {
        id: lockContext
        onUnlocked: lock.locked = false
    }

    WlSessionLock {
        id: lock
        locked: false

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    IpcHandler {
        target: "lock"
        function trigger(): void { lock.locked = true; }
    }
}
