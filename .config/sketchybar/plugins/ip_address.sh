#!/bin/sh

source "$CONFIG_DIR/themes/catppuccin.sh"

IP_ADDRESS=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1)
IS_VPN=$(scutil --nwi | grep -m1 'utun' | awk '{ print $1 }')

if [[ $IS_VPN != "" ]]; then
	COLOR=$SKY
	ICON=􀎡
	LABEL="VPN"
elif [[ $IP_ADDRESS != "" ]]; then
	COLOR=$BLUE
	ICON=􀙇
	LABEL=$IP_ADDRESS
else
	COLOR=$WHITE
	ICON=􀇿
	LABEL="Not Connected"
fi

sketchybar --set $NAME icon.color=$COLOR \
	icon=$ICON \
	label="$LABEL"
