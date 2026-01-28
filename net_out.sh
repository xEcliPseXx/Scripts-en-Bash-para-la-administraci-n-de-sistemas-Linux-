#!/bin/bash

# Add /sbin to the PATH environment variable
export PATH=$PATH:/sbin

# Usage message for the script
usage="Usage: net-out.sh [time_in_sec]"
time=0

# Function to display network interface names and the number of transmitted packets
function net {
    echo ""
    # Use the ifconfig command to get interface names and packet statistics
    ifc=`ifconfig`
    # Extract interface names and transmitted packet counts
    name=`echo "$ifc" | grep flags | cut -d: -f1`
    pkt=`echo "$ifc" | grep "TX packets" | tr -s ' ' | cut -d' ' -f4`
    l=`echo "$name" | wc -l`
    total=0
    # Iterate through each interface to display its name and packet count
    for i in $(seq 1 $l); do
        read name <<< `echo "$ifc" | sed "${i}q;d"`
        read pkt <<< `echo "$pkt" | sed "${i}q;d"`
        total=$((total+pkt))
        echo "$name -> $pkt"
    done
    echo "Total -> $total"
    echo ""
}

# If no parameters are provided
if [ $# -eq 0 ]; then
    net
# If one parameter is provided
elif [ $# -eq 1 ]; then
    # Extract numeric characters from the parameter to determine the sleep time
    time="$(echo $1 | grep -o -E '[0-9]+')"
    # If no numeric characters are found
    if [ "$time" == "" ]; then
        echo $usage; exit 1
    fi
    # Continuously call the net function at the specified time interval
    while true; do
        net
        sleep "$time"
    done

else
    echo $usage; exit 1
fi
