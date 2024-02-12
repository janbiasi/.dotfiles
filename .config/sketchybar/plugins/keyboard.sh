#!/bin/bash

# this is jank and ugly, I know
LAYOUT="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep "KeyboardLayout Name" | cut -c 33- | rev | cut -c 2- | rev)"

# specify short layouts individually.
case "$LAYOUT" in
    "\"Swiss German\"")
      SHORT_LAYOUT="🇨🇭";;
    "\"ABC\"")
      SHORT_LAYOUT="🇺🇸";;
    *) SHORT_LAYOUT=$LAYOUT;;
esac

sketchybar --set keyboard label="$SHORT_LAYOUT" \
                          label.padding_left=5 \
                          label.padding_right=5
