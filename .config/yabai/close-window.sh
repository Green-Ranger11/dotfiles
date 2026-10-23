#!/bin/sh
# Close the focused window, Hyprland-style: if it was the app's last window,
# quit the app too (macOS otherwise leaves it running in the Dock). The quit
# goes through the app, so unsaved-changes prompts still appear. Bound to
# alt+q in skhdrc.

win=$(yabai -m query --windows --window) || exit 0
id=$(printf '%s' "$win" | jq -r .id)
pid=$(printf '%s' "$win" | jq -r .pid)
app=$(printf '%s' "$win" | jq -r .app)

yabai -m window "$id" --close || exit 0

# Finder runs regardless of windows.
[ "$app" = "Finder" ] && exit 0

# Give the app a moment to tear the window down (or show a save sheet,
# which keeps it as a window and stops the quit).
sleep 0.4
left=$(yabai -m query --windows | jq --argjson pid "$pid" --argjson id "$id" \
    '[.[] | select(.pid == $pid and .id != $id)] | length')
[ "$left" -eq 0 ] || exit 0

bundle=$(osascript -e "tell application \"System Events\" to get bundle identifier of first process whose unix id is $pid" 2>/dev/null)
[ -n "$bundle" ] && [ "$bundle" != "missing value" ] && osascript -e "quit app id \"$bundle\""
