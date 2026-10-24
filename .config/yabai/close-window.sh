#!/bin/sh
# Close the focused window, Hyprland-style: if it's the app's last window,
# quit the app instead (macOS otherwise leaves it running in the Dock).
# Quitting with the window still open, rather than closing it first, is what
# lets apps restore it: Firefox, for one, saves a session with no windows if
# its last window closes before the quit. The quit goes through the app, so
# unsaved-changes prompts still appear. Bound to alt+q in skhdrc.

win=$(yabai -m query --windows --window) || exit 0
id=$(printf '%s' "$win" | jq -r .id)
pid=$(printf '%s' "$win" | jq -r .pid)
app=$(printf '%s' "$win" | jq -r .app)

# The app's other real windows, on any space (minimized ones included).
others=$(yabai -m query --windows | jq --argjson pid "$pid" --argjson id "$id" \
    '[.[] | select(.pid == $pid and .id != $id and .subrole == "AXStandardWindow")] | length')

# Finder runs regardless of windows.
if [ "$others" -gt 0 ] || [ "$app" = "Finder" ]; then
    yabai -m window "$id" --close
    exit 0
fi

bundle=$(osascript -e "tell application \"System Events\" to get bundle identifier of first process whose unix id is $pid" 2>/dev/null)
if [ -n "$bundle" ] && [ "$bundle" != "missing value" ]; then
    osascript -e "quit app id \"$bundle\""
else
    yabai -m window "$id" --close
fi
