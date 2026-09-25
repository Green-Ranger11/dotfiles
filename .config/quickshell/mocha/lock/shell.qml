// The REAL lock entry point - this is what would eventually replace
// hypridle/keybinds.lua's `hyprlock` invocation, via WlSessionLock
// (ext-session-lock-v1). NOT wired up anywhere. Do not run this against
// your live session until you've reviewed LockContext.qml/LockSurface.qml
// and tested via test.qml first - a bug here means either a lockout (PAM
// path wrong) or a bypass (unlocked set incorrectly).
//
// One WlSessionLockSurface per monitor is created automatically by
// Quickshell; they all share the single LockContext below.
import Quickshell
import Quickshell.Wayland

ShellRoot {
    LockContext {
        id: lockContext
        onUnlocked: {
            // Must unlock before quitting, or the compositor falls back to
            // its own (uninteractive) lock instead of actually unlocking.
            lock.locked = false;
            Qt.quit();
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
