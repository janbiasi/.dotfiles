#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title SSID
# @raycast.mode inline
# @raycast.refreshTime disabled

# Optional parameters:
# @raycast.icon custom-icons/network_name.png

# @Documentation:
# @raycast.packageName System
# @raycast.description Get current network connections.
# @raycast.author Jan Biasi
# @raycast.authorURL https://github.com/janbiasi

function get_wifi_ssid () {
  ssid=$(system_profiler SPAirPortDataType | awk '/Current Network Information:/ { getline; print substr($0, 13, (length($0) - 13)); exit }')
  echo "$ssid"
}

function get_internet_status () {
  if ! ping -q -c 2 google.com &>/dev/null; then
    echo " (No Internet)"
  fi
}

current_device=$(route get default 2>/dev/null | grep "interface" | awk '{print $2}')

# Exit if there's no connection
if [ -z "$current_device" ]; then
  echo "No connection"
  exit 0;
fi

service_info=$(networksetup -listnetworkserviceorder | grep "$current_device")
service_name=$(echo "$service_info" | awk -F  "(, )|(: )|[)]" '{print $2}')
wifi_ssid=$(get_wifi_ssid)
network_status=""

if grep -q "USB" <<< "$service_name"; then
  network_status+="Ethernet"
  network_status+=$(get_internet_status)

  # Check if also connected to Wi-fi
  if [ -n "$wifi_ssid" ]; then
    network_status+=" | $wifi_ssid"
  fi
elif grep -q "Wi-Fi" <<< "$service_name"; then
  network_status+="$wifi_ssid"
  network_status+=$(get_internet_status)
fi

echo "$network_status"
