#!/bin/bash

p=0
usage="Usage: BadUser.sh [-p] or BadUser.sh [-t] [d/m]"

# Detect input options: only valid options are: no parameters, -p, and -t
if [ $# -ne 0 ]; then
    if  [ $# -eq 1 ]; then
        if [ $1 == "-p" ]; then
            p=1
        else
            echo $usage; exit 1
        fi  
    # If the -t option is used with the time interval
    elif [ $1 == "-t" ]; then
        p=2
        num_t="$(echo $2 | grep -o -E '[0-9]+')"
        int_t="$(echo $2 | grep -o -E '[a-z]+')"
        if [ "$int_t" == "d" ]; then
            :
        elif [ "$int_t" == "m" ]; then
            num_t=$(($num_t*30))
        else
            echo $usage; exit 1
        fi
    else 
        echo $usage; exit 1
    fi
fi

# Read the password file and get only the user name field
for user in `cat /etc/passwd | cut -d: -f1`; do
    home=`cat /etc/passwd | grep "^$user\>" | cut -d: -f6`
    if [ -d $home ]; then
        num_fich=`find $home -type f -user $user 2>/dev/null| wc -l`
    else
        num_fich=0
    fi

    if [ $num_fich -eq 0 ] ; then
        # If the -p option is used
        if [ $p -eq 1 ]; then
            user_proc=$(expr `ps -u $user | wc -l` - 1)
            if [ $user_proc -eq 0 ]; then
                echo "$user"
            fi
        # If the -t option is used
        elif [ $p -eq 2 ]; then
            user_proc=$(expr `ps -u $user | wc -l` - 1)
            # The user is included if they have no active processes
            if [ $user_proc -eq 0 ]; then
                user_last=$(expr `last "$user" -s -$num_t"days" | wc -l` - 2)
                # The user is included if no login is detected in the last num_t days
                if [ $user_last -eq 0 ]; then
                    user_mod=$(expr `find -user "$user" -ctime $num_t | wc -l`)
                    # The user is included if no file modifications are detected in the last num_t days
                    if [ $user_mod -eq 0 ]; then
                        echo "$user"
                    fi
                fi
            fi
        # If neither -p nor -t options are used
        else
            echo "$user"
        fi
    fi
done
