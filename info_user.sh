#!/bin/bash

usage="Usage: infouser.sh [username]"

# Check if exactly one argument (username) is provided
if  [ $# -eq 1 ]; then
    user="$1"
    # Get the user's information line from /etc/passwd
    line=`cat /etc/passwd | grep "$user"`

    # Get the user's home directory
    home=`echo $line | cut -d: -f6`

    # Get the size of the user's home directory
    size=`du -sxh $home 2>/dev/null | cut -f1`

    # Get the directories (from the root) where the user has files
    dirs=()
    dir_a=""
    # Find directories owned by the user and extract the top-level directory
    for dir in `find / -type d -user $user 2>/dev/null | cut -d'/' -f 2`; do
        if [ "$dir_a" != "$dir" ]; then
            dirs+=("/$dir")
            dir_a="$dir"
        fi
    done

    # Get the number of active processes for the user
    proc=`ps -u "$user" | wc -l`
    proc=$((proc - 1))

    # Print the gathered information
    echo ""
    echo "Home: $home"
    echo "Home size: $size"
    echo "Other dirs: ${dirs[@]}"
    echo "Active processes: $proc"
    echo ""
else
    echo "$usage"
fi
