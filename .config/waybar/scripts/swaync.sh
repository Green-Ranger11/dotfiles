#!/bin/bash
# Emit waybar JSON for the swaync module.
# Shows the pending-notification count next to the bell (blank when zero) and
# passes swaync's class through so CSS can restyle when notifications exist.
swaync-client -swb | while read -r line; do
    echo "$line" | python3 -c '
import sys, json
d = json.load(sys.stdin)
count = str(d.get("text", "0"))
cls = d.get("class", "none")
print(json.dumps({
    "text": "" if count in ("0", "") else count,
    "alt": cls,
    "class": cls,
    "tooltip": d.get("tooltip") or ("%s notification(s)" % count if count not in ("0", "") else "No notifications"),
}))
sys.stdout.flush()
' 2>/dev/null
done
