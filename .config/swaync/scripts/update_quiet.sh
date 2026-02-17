#!/bin/bash
# Check if power-saver profile is active
if [ "$(powerprofilesctl get)" = "power-saver" ]; then
    echo true
else
    echo false
fi
