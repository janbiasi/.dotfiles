#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Network Speed
# @raycast.mode inline
# @raycast.refreshTime disabled

# Optional parameters:
# @raycast.icon custom-icons/network.png

# Documentation:
# @raycast.packageName System
# @raycast.author Archie Lacoin
# @raycast.authorURL https://github.com/pomdtr
# @raycast.author LanikSJ
# @raycast.authorURL https://github.com/LanikSJ

result=$(networkQuality)

rtt=$(echo "$result" | grep "Idle Latency" | awk '{printf "%.1f",$3}')
mbps_down=$(echo "$result" | grep "Downlink capacity" | awk '{printf "%.1f", $3 tolower($4)}')
mbps_up=$(echo "$result" | grep "Uplink capacity" | awk '{printf "%.1f", $3 tolower($4)}')

echo "↓ ${mbps_down} mb/s  ↑ ${mbps_up} mb/s  ↔ ${rtt} ms"
