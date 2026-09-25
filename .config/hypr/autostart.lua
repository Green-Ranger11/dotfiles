-- Autostart Applications
-- Commands that run once at Hyprland startup
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- Update environment FIRST (required for Waybar to find Hyprland socket)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE XDG_MENU_PREFIX")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- KDE services -- kbuildsycoca6 must run BEFORE kded6 so the service cache
    -- is populated when kded6 reads which modules to autoload. Quickshell hosts
    -- its own StatusNotifierWatcher, so this only matters for other KDE bits now.
    hl.exec_cmd("sh -c 'kbuildsycoca6 --noincremental; kded6'")

    -- Core services (after environment is set)
    -- NOTE: kdeconnect-indicator races kded6's tray watcher at login. On slow
    -- cold boots it can lose and the tray icon won't appear (process still
    -- runs). Rare; fix when it happens: pkill -f kdeconnect-ind && kdeconnect-indicator &
    -- quickshell replaces waybar (bar), swaync (notifications) and rofi
    -- (launcher/emoji/clipboard pickers). Both are still installed: put them
    -- back on this line to fall back.
    hl.exec_cmd("qs -p $HOME/.config/quickshell/mocha & hyprpaper & kdeconnect-indicator")
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
