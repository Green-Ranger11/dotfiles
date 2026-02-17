#!/bin/bash
# Output bell icon for waybar - filled when notifications exist, outline when empty
swaync-client -swb | while read -r line; do
    count=$(echo "$line" | python3 -c "import sys,json; print(json.load(sys.stdin).get('text','0'))" 2>/dev/null)
    if [ "$count" != "0" ] && [ -n "$count" ]; then
        echo '󰂚'
    else
        echo '󰂜'
    fi
done
