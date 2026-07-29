-- Hyprland Configuration - Main Entry Point (Lua, Hyprland 0.55+)
-- See https://wiki.hypr.land/Configuring/Start/
--
-- Migrated from hyprland.conf + conf.d/*.conf (hyprlang). Modules load in the
-- same order the old source= lines did.
--
-- Still hyprlang (separate tools, NOT part of this config):
--   hyprlock.conf, hyprpaper.conf, themes/mocha.conf (consumed by hyprlock)

require("monitors")
require("env")
require("autostart")
require("input")
require("appearance")
require("layouts")
require("workspaces")
require("keybinds")
require("windowrules")
