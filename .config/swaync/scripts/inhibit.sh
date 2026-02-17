#!/bin/bash
# Toggle idle inhibitor via systemd-inhibit
if pgrep -f "systemd-inhibit --what=idle" > /dev/null; then
    pkill -f "systemd-inhibit --what=idle"
else
    systemd-inhibit --what=idle --who=swaync --why="User toggled" sleep infinity &
    disown
fi
