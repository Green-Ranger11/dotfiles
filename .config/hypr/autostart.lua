-- Autostart Applications
-- Commands that run once at Hyprland startup
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- Update environment FIRST (required for Waybar to find Hyprland socket)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE XDG_MENU_PREFIX")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- KDE services -- kbuildsycoca6 must run BEFORE kded6 so the service cache
    -- is populated when kded6 reads which modules to autoload (otherwise the
    -- statusnotifierwatcher module doesn't load and waybar's tray stays empty).
    hl.exec_cmd("sh -c 'kbuildsycoca6 --noincremental; kded6'")

    -- Core services (after environment is set)
    hl.exec_cmd("waybar & hyprpaper & kdeconnect-indicator & swaync")
    hl.exec_cmd("wl-paste --watch cliphist store")

    -- KDE Connect (binaries not installed yet -- kept for when kdeconnect lands)
    hl.exec_cmd("/usr/lib/kdeconnectd&!")
    hl.exec_cmd("/usr/bin/indicator-kdeconnect&!")

    -- Startup applications
    -- Windowrules in workspaces.lua handle workspace assignment automatically
    hl.exec_cmd("kitty")
    hl.exec_cmd("firefox")
    -- vesktop-bin is a native package (/usr/bin/vesktop) -- NOT a flatpak.
    hl.exec_cmd("vesktop")
end)
