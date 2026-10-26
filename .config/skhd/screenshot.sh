#!/bin/sh
# Screenshots like hypr/keybinds.lua: full = focused display to file,
# edit = region into Preview (saved), clip = region to clipboard.
dir="$HOME/Pictures/Screenshots"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
notify() { osascript -e "display notification \"$1\" with title \"Screenshot\""; }
mkdir -p "$dir"
case "$1" in
    full)
        # yabai's display index matches screencapture -D numbering.
        d=$(yabai -m query --displays --display | jq -r .index)
        screencapture -x -D "${d:-1}" "$file" && notify "Saved to Pictures/Screenshots" ;;
    edit) screencapture -i -P "$file" && [ -f "$file" ] && notify "Saved to Pictures/Screenshots" ;;
    clip) screencapture -ic ;;
esac
