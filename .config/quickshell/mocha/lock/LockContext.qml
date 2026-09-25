// Auth logic only, shared across every monitor's lock surface (mirrors
// quickshell-examples/lockscreen/LockContext.qml, the upstream reference for
// PamContext-based auth). Kept separate from LockSurface.qml so multi-monitor
// setups share one in-flight PAM session instead of racing several.
import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root
    signal unlocked()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property int failCount: 0

    onCurrentTextChanged: showFailure = false

    function tryUnlock() {
        if (currentText === "" || unlockInProgress) return;
        unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam

        // A custom configDirectory breaks PAM's own "include" resolution --
        // `include login` only searches inside that custom directory, not
        // /etc/pam.d, so it silently fails to find "login" and auth comes
        // back denied. Every real lock tool (hyprlock included) sidesteps
        // this by shipping its service file straight in /etc/pam.d instead,
        // so this does the same: no configDirectory override, default
        // /etc/pam.d, service file "quickshell-lock" (see pam/quickshell-lock
        // in this directory -- copy it to /etc/pam.d/ once, see its header).
        config: "quickshell-lock"

        onPamMessage: {
            if (this.responseRequired) this.respond(root.currentText);
        }

        onCompleted: result => {
            unlockInProgress = false;
            if (result === PamResult.Success) {
                root.unlocked();
            } else {
                root.currentText = "";
                root.failCount += 1;
                root.showFailure = true;
            }
        }

        onError: err => {
            // Fail closed: any PAM-level error (start failed, internal error)
            // is treated as a failed attempt, never as a silent unlock.
            unlockInProgress = false;
            root.currentText = "";
            root.showFailure = true;
        }
    }
}
