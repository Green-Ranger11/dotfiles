#!/bin/bash
# Toggle power-saver profile (quiet mode)
CURRENT=$(powerprofilesctl get)
if [ "$CURRENT" = "power-saver" ]; then
    powerprofilesctl set balanced
else
    powerprofilesctl set power-saver
fi
