#!/bin/sh
# Hyprland-style workspaces on yabai (see ~/.config/hypr/workspaces.lua):
# every space gets a ws<N> label, which skhd and the Laumei bar use as its
# workspace number, and ws2 lives on the external monitor when one is plugged
# in. Labels stick to spaces, so numbers survive spaces moving between
# displays. Run from yabairc and on display/space signals.

q() { yabai -m query "$@"; }

# Unlabelled spaces take the lowest free numbers, in display order.
used=" $(q --spaces | jq -r '.[].label' | sed -n 's/^ws//p' | tr '\n' ' ')"
for idx in $(q --spaces | jq -r '.[] | select(.label == "") | .index'); do
    n=1
    while case "$used" in *" $n "*) true ;; *) false ;; esac; do n=$((n + 1)); done
    yabai -m space "$idx" --label "ws$n"
    used="$used$n "
done

# The external monitor is any display that isn't the built-in panel.
builtin=$(osascript -l JavaScript -e 'ObjC.import("AppKit");
    $.NSScreen.screens.js.filter(s => s.localizedName.js.includes("Built-in"))
        .map(s => s.deviceDescription.objectForKey("NSScreenNumber").js)[0] || 0')
ext=$(q --displays | jq -r --argjson b "$builtin" '[.[] | select(.id != $b)][0].index // empty')
[ -n "$ext" ] || exit 0

ws2=$(q --spaces | jq -r '.[] | select(.label == "ws2") | .display')
if [ -z "$ws2" ]; then
    yabai -m space --create "$ext"
    yabai -m space "$(q --spaces --display "$ext" | jq -r 'last.index')" --label ws2
elif [ "$ws2" != "$ext" ]; then
    yabai -m space ws2 --display "$ext"
fi
