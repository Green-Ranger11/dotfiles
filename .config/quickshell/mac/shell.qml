// macOS shell, run by Laumei (`laumei -c mac`). Reuses mocha as-is; what's
// left out is Linux-only (PowerAuto drives hyprctl).
import Quickshell
import Quickshell.Io
import "../mocha/launcher"
import "../mocha/lock"
import "../mocha/notifications"
import "../mocha/osd"

ShellRoot {
    // Toasts for notify-send, history for those plus macOS notifications
    // (Laumei copies them in with LAUMEI_NC_BRIDGE=1; macOS shows their banners).
    NotificationLayer {}

    // One bar per display, like mocha.
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    // Volume and brightness popups. BrightnessOsd skips the slow drift of
    // macOS auto-brightness.
    OsdWindow { id: osdWindow }
    VolumeOsd { osd: osdWindow }
    BrightnessOsd { osd: osdWindow }

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
