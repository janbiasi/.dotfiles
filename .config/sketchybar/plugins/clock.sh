#!/bin/bash

source "$CONFIG_DIR/themes/catppuccin.sh"

CAL=$(date '+%d %B %H:%M')

sketchybar --set $NAME \
           label="$CAL" \
           icon.color=${RED}
