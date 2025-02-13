#!/bin/bash

#########################################################
## Set IP address or website URL in "target" variable. ##
#########################################################

# IP address or URL.
target="8.8.8.8"

# @raycast.title Ping Monitor
# @raycast.author Caleb Stauffer
# @raycast.authorURL https://github.com/crstauf
# @raycast.description Ping an IP address or URL on an interval.

# @raycast.icon custom-icons/ping.png
# @raycast.mode inline
# @raycast.packageName Internet
# @raycast.refreshTime disabled
# @raycast.schemaVersion 1

if [ -z ${target+x} ]; then
	echo "Target is undefined.";
	exit 0
fi

output=$(ping -i 0.25 -t 3 -q "$target")
summary=$(echo "$output" | awk 'END{print}')

IFS=' ' read -ra array <<< $summary
times=$(echo ${array[3]})

avg=$(echo $times | awk -F/ '{print $2}')

echo "${target}: ${avg}${array[4]}"