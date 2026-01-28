#!/bin/bash

usage="Usage: class_act.sh [Number_of_days] [Name+surname]"

echo ""

# Extract the number of days from the first argument
days="$(echo $1 | grep -o -E '[0-9]+')"

# Check that there are exactly 2 arguments and the number of days is not empty
if  [ $# -eq 2 ] && [ -n "$days" ]; then
    sum=0
    
    # Get the line from the passwd file that contains the user's information
    line=`cat /etc/passwd | grep "$2"`

    # Extract the username, home directory, and full name (without commas) from the line
    user=`echo "$line" | cut -d: -f1`
    home=`echo "$line" | cut -d: -f6`
    name=`echo "$line" | cut -d: -f5`
    name="$(echo "$name" | cut -d ',' -f1)"

    # Get the list of files modified in the user's home directory within the specified number of days
    list=`find "$home" -type f -mtime -"$days" -ls 2>/dev/null`

    # Count the number of lines in the list to determine the number of modified files
    mod=`echo "$list" | wc -l`
    mod=$((mod - 1))

    # Sum the file sizes from the list
    read space <<< `echo "$list" | awk '{ sum += $7; } END { print sum; }'`

    # Convert the total file size from Bytes to MegaBytes
    space=$((space/1024/1024))
    
    # Print the results
    echo " '$name' ($user) $mod files modified in the last $days days, occupying $space MB"
else
    echo "$usage"
fi

echo ""
