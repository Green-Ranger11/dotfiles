import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Battery: power-saver profile, laptop panel at 60Hz, backlight capped at
// 45%, keyboard backlight off. AC: performance, 144Hz, backlights restored.
// asusd flips the profile on plug events too, but not at boot (a battery
// boot kept ppd's saved "performance"), so this applies at startup as well.
Scope {
    id: root

    readonly property string panel: "amdgpu_bl1"
    readonly property string kbd: "asus::kbd_backlight"

    function apply(startup) {
        const bat = UPower.onBattery;
        PowerProfiles.profile = bat ? PowerProfile.PowerSaver
            : PowerProfiles.hasPerformanceProfile ? PowerProfile.Performance : PowerProfile.Balanced;
        // Same fields as the catch-all rule in hypr/monitors.lua, mode only.
        hypr.command = ["hyprctl", "eval", `hl.monitor({ output = "eDP-1", mode = "1920x1200@${bat ? 60 : 144}", position = "auto", scale = 1 })`];
        hypr.running = true;

        // Backlights: save on unplug, restore on plug-in (brightnessctl keeps
        // the saved state in $XDG_RUNTIME_DIR). At startup only dim, never
        // save: a shell reload on battery would otherwise save the dimmed
        // values and "restore" them later. Only dims, never brightens.
        const save = bat && !startup ? `brightnessctl -q -d ${panel} -s; brightnessctl -q -d ${kbd} -s; ` : "";
        const dim = `b=$(brightnessctl -m -d ${panel} | cut -d, -f4 | tr -d %); `
            + `[ "$b" -gt 45 ] && brightnessctl -q -d ${panel} set 45%; brightnessctl -q -d ${kbd} set 0`;
        const restore = `brightnessctl -q -d ${panel} -r; brightnessctl -q -d ${kbd} -r`;
        if (bat)
            light.command = ["sh", "-c", save + dim];
        else if (!startup)
            light.command = ["sh", "-c", restore];
        else
            return;
        light.running = true;
    }

    Component.onCompleted: apply(true)

    Connections {
        target: UPower
        function onOnBatteryChanged() { root.apply(false); }
    }

    // At login the ppd proxy isn't populated yet, so the startup apply sees
    // no performance profile and falls back to balanced. Re-run once it lands.
    Connections {
        target: PowerProfiles
        function onHasPerformanceProfileChanged() { root.apply(true); }
    }

    Process { id: hypr }
    Process { id: light }
}
