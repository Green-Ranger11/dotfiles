-- Keybindings Configuration
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER"

-- Rules applied to the floating TUI tools (old inline [float; size 1150 590; center])
local floatRules = { float = true, size = "1150 590", center = true }

-- Application launchers
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("sh $HOME/.config/rofi/bin/launcher"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("sh $HOME/.config/rofi/bin/emoji"))
hl.bind(mainMod .. " + slash",  hl.dsp.exec_cmd("rofi-rbw"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("kitty --class clippicker -o close_on_child_death=yes -e sh $HOME/.config/rofi/bin/clipboard", floatRules))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("kitty --class floating -e bluetui", floatRules))
-- -o color12: Textual hardcodes table headers to ansi_bright_blue in ANSI mode
-- (unreachable from gazelle's theme.toml); remap it to surface0 in this
-- dedicated float so headers render dark with readable text.
-- (Lua strings need no ## escape for a literal # like hyprlang did.)
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("kitty --class floating -o color12=#313244 -e gazelle", floatRules))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("sh $HOME/.config/waybar/scripts/vpn.sh toggle"))
-- herdr agent cockpit (absolute path: Hyprland's exec PATH lacks ~/.local/bin)
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("kitty --class herdr -e $HOME/.local/bin/herdr"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a -f hex"))

-- Session
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("env YAZI_FLOAT=1 EDITOR=nvim kitty --class yazi-float yazi", floatRules))

-- Hardware controls
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("brightnessctl s +5%"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("brightnessctl s 5%-"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("asusctl aura effect --next-mode"))

-- Fn keys
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86KbdBrightnessDown",  hl.dsp.exec_cmd("brightnessctl -d asus::kbd_backlight s 1-"),  { locked = true })
hl.bind("XF86KbdBrightnessUp",    hl.dsp.exec_cmd("brightnessctl -d asus::kbd_backlight s +1"),  { locked = true })
hl.bind("XF86Launch3",            hl.dsp.exec_cmd("asusctl aura effect --next-mode"),            { locked = true })
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd("brightnessctl s 5%-"), { repeating = true })
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd("brightnessctl s +5%"), { repeating = true })

-- Touchpad toggle, natively in Lua (was a /tmp/touchpad-off shell one-liner).
-- State lives in this upvalue, so a config reload resets it to "enabled"
-- (the old /tmp marker reset on reboot anyway).
local touchpadEnabled = true
local function toggleTouchpad()
    touchpadEnabled = not touchpadEnabled
    hl.device({ name = "asuf1204:00-2808:0201-touchpad", enabled = touchpadEnabled })
    hl.exec_cmd('notify-send -t 2000 "Touchpad" "' .. (touchpadEnabled and "Enabled" or "Disabled") .. '"')
end
hl.bind("XF86TouchpadToggle", toggleTouchpad, { locked = true })
hl.bind("F10", toggleTouchpad)

hl.bind("XF86Sleep",  hl.dsp.exec_cmd("systemctl suspend"),  { locked = true })
hl.bind("XF86RFKill", hl.dsp.exec_cmd("rfkill toggle all"),  { locked = true })

-- M keys
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),   { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),   { repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86Launch1",          hl.dsp.exec_cmd("rog-control-center"),                           { locked = true })

-- Screenshots (each command shared by its PRINT-key and letter-key binds)
local shotFull = [[grim -o "$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png && notify-send "Screenshot" "Saved to Pictures/Screenshots"]]
local shotEdit = [[grim -g "$(slurp)" - | swappy -f - && notify-send "Screenshot saved to Pictures"]]
local shotClip = [[grim -g "$(slurp -d)" - | wl-copy]]

-- Full screen (focused monitor) straight to file
hl.bind("PRINT",              hl.dsp.exec_cmd(shotFull))
hl.bind(mainMod .. " + I",    hl.dsp.exec_cmd(shotFull))
-- Region to editor, then save
hl.bind("CONTROL + PRINT",    hl.dsp.exec_cmd(shotEdit))
hl.bind("CONTROL + I",        hl.dsp.exec_cmd(shotEdit))
-- Region to clipboard
hl.bind("SHIFT + CONTROL + PRINT", hl.dsp.exec_cmd(shotClip))
hl.bind("SHIFT + CONTROL + I",     hl.dsp.exec_cmd(shotClip))

-- Move focus with mainMod + vim keys / arrow keys
local focusDirs = { h = "left", l = "right", k = "up", j = "down",
                    left = "left", right = "right", up = "up", down = "down" }
for key, dir in pairs(focusDirs) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
end

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move workspaces to different monitors
hl.bind("CTRL + ALT + " .. mainMod .. " + SHIFT + period", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind("CTRL + ALT + " .. mainMod .. " + SHIFT + comma",  hl.dsp.workspace.move({ monitor = "l" }))
