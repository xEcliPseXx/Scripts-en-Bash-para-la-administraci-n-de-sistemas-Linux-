#!/bin/bash

# Add /sbin to the PATH environment variable
export PATH=$PATH:/sbin

# Various messages and options for usage
op=0
usage="Usage: ocupacio.sh [-g group] max_space_allowed(G/M/K/B)"
error_msg=false
there_is_user=false

# Function to write error message code to .profile
function error {
    echo '# window message indicating that the space limit has been exceeded' >> "$dir/.profile"
    echo 'xmessage -center -title "Warning: Size exceeded" -buttons "Okay","Don.t show anymore" "The files that this user contains are too large, please delete or compress some of them in order to reduce the disk space used."' >> "$dir/.profile"
    echo 'if [ "$?" -eq "102" ]; then' >> "$dir/.profile"
    echo '   sed -i "$((${LINENO} - 3)),$((${LINENO} + 1))d" '$dir'/.profile' >> "$dir/.profile"
    echo 'fi' >> "$dir/.profile"
}

# Check for command-line options: valid options are no parameters and -p
if [ $# -ne 0 ]; then

    # Case: users
    if  [ $# -eq 1 ]; then
        op=1;
        numb="$(echo $1 | grep -o -E '[0-9]+')";
        unit="$(echo $1 | grep -o -E '[A-Z]+')";
        echo ""
        echo ">> The following users exceed the space limit."
    # Case: group
    elif [ $# -eq 3 ] && [ $1 == "-g" ]; then
        op=2;
        numb="$(echo $3 | grep -o -E '[0-9]+')";
        unit="$(echo $3 | grep -o -E '[A-Z]+')";
        # Get an array with the users of the group
        group=`cat /etc/group | grep "^$2\>"`
        IFS=':' read -r -a  users <<< "$group"
        users=("${users[@]:3}")
        echo ""
        echo ">> The following users in group -$2- exceed the space limit."
    # Invalid values
    else 
        echo $usage; exit 1
    fi

    echo ">> They measure:"
    echo ""

    # Convert the input value to Bytes
    if [ "$unit" == "G" ]; then
        numb1=$(($numb*1024))
        if [ "$numb" -ne "$numb1" ]; then 
            numb="$numb1"
            unit='M'
        fi 
    fi
    if [ "$unit" == "M" ]; then
        numb1=$(($numb*1024))
        if [ "$numb" -ne "$numb1" ]; then 
            numb="$numb1"
            unit='K'
        fi 
    fi
    if [ "$unit" == "K" ]; then
        numb1=$(($numb*1024))
        if [ "$numb" -ne "$numb1" ]; then 
            numb="$numb1"
            unit='B'
        fi 
    fi

    if [ "$unit" != "B" ] && [ "$unit" != "K" ] && [ "$unit" != "M" ] && [ "$unit" != "G" ]; then
        echo $usage; exit 1
    fi
fi

# Case: users
if [ $op -eq 1 ]; then
    IFS=$'\n'
    for line in `cat /etc/passwd`; do

        dir=`echo $line | cut -d: -f6`
        user=`echo $line | cut -d: -f1`

        # Check for users that exist but their folder doesn't exist
        if [ -d $dir ]; then
            sp=`du -sx $dir 2>/dev/null | cut -f1`
            numb1="$(echo $sp | grep -o -E '[0-9]+')";
            numb1=$(($numb1*1024))
            # Check if the size is larger
            if [ "$numb1" -gt "$numb" ]; then
                echo -e "$user -> $sp KB"
                there_is_user=true;
                error
                error_msg=true
            fi
        fi
    done
fi

# Case: group
if [ $op -eq 2 ]; then
    sp_group=0
    IFS=$'\n'
    for line in `cat /etc/passwd`; do

        dir=`echo $line | cut -d: -f6`
        user=`echo $line | cut -d: -f1`

        if [[ " ${users[@]} " =~ " ${user} " ]]; then
            if [ -d $dir ]; then
                sp=`du -sx $dir 2>/dev/null | cut -f1`
                numb1="$(echo $sp | grep -o -E '[0-9]+')";
                numb1=$(($numb1*1024))
                # Check if the size is larger
                if [ "$numb1" -gt "$numb" ]; then
                    echo -e "$user -> $sp KB"
                    there_is_user=true;
                    error
                    error_msg=true
                fi
                sp_group=$(($sp_group + $sp))
            fi
        fi
    done
    echo ""
    echo -e "Total space used by group -$2- -> $sp_group KB"
fi

# If no users exceed the limit
if [ $there_is_user == false ]; then
    if [ $op -eq 1 ]; then
        echo "No user exceeds the indicated space limit."
    elif [ $op -eq 2 ]; then
        echo ""
        echo "No user in group exceeds the indicated space limit."
    fi
fi
echo ""
