// macOS shell, run by Laumei (`laumei -c mac`). Reuses mocha as-is; what's
// left out is Linux-only (PowerAuto drives hyprctl; notifications can't be
// received on macOS).
import Quickshell
import Quickshell.Io
import "../mocha/launcher"
import "../mocha/lock"
import "../mocha/osd"

ShellRoot {
    // One bar per display, like mocha.
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    // Volume popup. mocha's Osd also pops up on brightness changes, which
    // macOS auto-brightness would trigger constantly.
    OsdWindow { id: osdWindow }
    VolumeOsd { osd: osdWindow }

    // `ipc call lock trigger`; Laumei hands the lock to macOS.
    LockLayer {}

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
}
