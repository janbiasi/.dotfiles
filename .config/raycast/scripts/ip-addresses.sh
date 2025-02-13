#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title IP
# @raycast.mode inline
# @raycast.refreshTime disabled
# @raycast.packageName Dashboard

# Optional parameters:
# @raycast.icon custom-icons/info.png

#cpu_mem=$(ps -A -o %cpu,%mem | awk '{ cpu += $1; mem += $2} END {print "CPU: "cpu"% MEM: "mem"%"}'%)
#lan_ip=$(ipconfig getifaddr en0)
lan_ip=$(ifconfig -l | xargs -n1 ipconfig getifaddr)
#cpu=$(ps -A -o %cpu | awk '{s+=$1} END {print s "%"}')
#wan_ip=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com)
wan_ip=$(curl -s http://ipecho.net/plain; echo)

#cpu=$(top -l 1 | grep -E "^CPU" | awk '{printf "%.1f", $7}')
# CPU used cpu=$(top -l 1 | grep -E "^CPU" | awk '{print ($3+$5)}')


echo "LAN ${lan_ip} - WAN ${wan_ip}"