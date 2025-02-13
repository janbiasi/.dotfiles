#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title System
# @raycast.mode inline
# @raycast.refreshTime disabled
# @raycast.packageName Dashboard

# Optional parameters:
# @raycast.icon custom-icons/memory.png

#cpu_mem=$(ps -A -o %cpu,%mem | awk '{ cpu += $1; mem += $2} END {print "CPU: "cpu"% MEM: "mem"%"}'%)
mem=$(memory_pressure | awk '{ field=$NF };END {print field}' | tr -d '%')
#cpu=$(ps -A -o %cpu | awk '{s+=$1} END {print s "%"}')
lpm=$(pmset -g | grep lowpowermode | awk '{print $NF}')

cpu=$(top -l 1 | grep -E "^CPU" | awk '{printf "%.1f", $7}')
# CPU used cpu=$(top -l 1 | grep -E "^CPU" | awk '{print ($3+$5)}')


echo "Free RAM ${mem}% - Idle CPU ${cpu}% - LPM ${lpm}"