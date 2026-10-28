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
if [ -n "$ext" ]; then
    ws2=$(q --spaces | jq -r '.[] | select(.label == "ws2") | .display')
    if [ -z "$ws2" ]; then
        yabai -m space --create "$ext"
        yabai -m space "$(q --spaces --display "$ext" | jq -r 'last.index')" --label ws2
    elif [ "$ws2" != "$ext" ]; then
        yabai -m space ws2 --display "$ext"
    fi
fi

# Apps on fixed workspaces, like Hyprland's windowrules: chat on 1, terminal
# and phone on 2, browser on 3. yabai turns a rule's label into a space index
# when the rule is added, so the rules are re-added (same label replaces) once
# spaces have moved; --apply moves windows that are already open.
rule() { l=$1; shift; yabai -m rule --add label="ws-$l" "$@"; }
rule discord app="^Discord$" space=ws1
rule kitty app="^kitty$" title!="^(nvim-scratch|yazi-float)$" space=ws2
rule phone app="^(Device Hub|Simulator|scrcpy|qemu-system.*)$" space=ws2
rule browser app="^(Firefox|Google Chrome)$" space=ws3
yabai -m rule --apply
