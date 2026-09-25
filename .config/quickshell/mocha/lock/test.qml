// Scratch harness - a FloatingWindow, NOT WlSessionLock, so this never locks
// the real session no matter how it's run. Safe to launch directly.
//
// Quickshell refuses relative imports that escape the config root, so
// `qs -p .../mocha/lock` can't see Theme in ".." (same issue as
// notifications/shell.qml). Test from a mirror root instead:
//
//   mkdir /tmp/lockroot && cd /tmp/lockroot
//   cp ~/.config/quickshell/mocha/{Theme,Label,Segment,Divider,Chip,Sys}.qml qmldir .
//   ln -s ~/.config/quickshell/mocha/lock lock
//   printf 'import QtQuick\nimport Quickshell\nimport "lock"\nShellRoot {\n  LockContext { id: lc; onUnlocked: Qt.quit() }\n  FloatingWindow { LockSurface { anchors.fill: parent; context: lc } }\n  Connections { target: Quickshell; function onLastWindowClosed() { Qt.quit(); } }\n}\n' > shell.qml
//   qs -p /tmp/lockroot
//
// This actually runs the real PAM prompt against your account (the lock.conf
// service just includes the system "login" chain), so a correct password
// really unlocks (closes the window) and a wrong one shows the fail text -
// it's a real end-to-end auth test, just in a window instead of a compositor
// lock, so a mistake here can't strand you at a black screen.
import QtQuick
import Quickshell

ShellRoot {
    LockContext {
        id: lockContext
        onUnlocked: Qt.quit()
    }

    FloatingWindow {
        LockSurface {
            anchors.fill: parent
            context: lockContext
        }
    }

    Connections {
        target: Quickshell
        function onLastWindowClosed() { Qt.quit(); }
    }
}
