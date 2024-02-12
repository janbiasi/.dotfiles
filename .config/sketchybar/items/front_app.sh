#!/bin/bash

sketchybar --add item front_app left \
           --set front_app       background.color=$PINK \
                                 icon.color=$TRUE_BLACK \
                                 icon.font="sketchybar-app-font:Regular:16.0" \
                                 label.color=$TRUE_BLACK \
                                 script="$PLUGIN_DIR/front_app.sh"            \
           --subscribe front_app front_app_switched
