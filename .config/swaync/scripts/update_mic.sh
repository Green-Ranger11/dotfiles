#!/bin/bash
# Check if default source (mic) is muted
MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
if [ "$MUTED" = "yes" ]; then
    echo true
else
    echo false
fi
