#!/bin/bash
# Check if idle inhibitor is active
if pgrep -f "systemd-inhibit --what=idle" > /dev/null; then
    echo true
else
    echo false
fi
