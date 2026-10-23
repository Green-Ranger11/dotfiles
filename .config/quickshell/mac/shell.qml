// macOS shell, run by Laumei (`laumei -c mac`). Reuses the mocha
// pickers as-is; only what macOS can host is loaded here.
import Quickshell
import Quickshell.Io
import "../mocha/launcher"

ShellRoot {
    // One bar per display, like mocha.
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    AppLauncher {}
    EmojiPicker {}
    ClipboardPicker {}
    NetworkPicker {}
    BluetoothPicker {}
    PowerPicker {}
    BitwardenPicker {}

    // Clipboard history for ClipboardPicker; Hyprland's autostart runs the
    // same pipeline on Linux. Copies marked concealed (password managers,
    // `wl-copy --sensitive`) are skipped.
    Process {
        running: true
        command: ["wl-paste", "--watch", "cliphist", "store"]
    }

    // PowerPicker's Lock calls `qs ipc call lock trigger` on this shell; on
    // Linux the mocha LockLayer answers it.
    IpcHandler {
        target: "lock"
        function trigger(): void { locker.running = true; }
    }
    Process {
        id: locker
        command: ["loginctl", "lock-session"]
    }
}
