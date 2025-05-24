#!/bin/bash

# Query connected monitors
INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"

connected=$(hyprctl monitors | grep "$EXTERNAL")

if [[ $connected ]]; then
    # External monitor is connected
    hyprctl dispatch dpms on $EXTERNAL
    hyprctl dispatch moveworkspacetomonitor 1 $EXTERNAL
    hyprctl dispatch focusmonitor $EXTERNAL
    hyprctl reload
else
    # External monitor is disconnected
    hyprctl reload
fi

