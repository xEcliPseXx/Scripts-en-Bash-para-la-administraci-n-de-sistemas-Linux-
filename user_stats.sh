#!/bin/bash

echo ""
echo " --- Login Summary ---"
echo ""

# Iterate through each user in /etc/passwd
for user in `cat /etc/passwd | cut -d: -f1`; do
	# Get the total number of logins for the user (who has logged in at least once)
	logins=`last | grep "^$user" | wc -l`
	
	# Calculate total login time
	if [ $logins -gt 0 ]; then
		total_minutes=0
		# Extract login times and sum them up
		for i in `last | grep "$user" | grep -Eo '\([0-9]{2}:[0-9]{2}\)'` ; do
			minutes=${i##(*:} ; minutes=${minutes%%)}
			hours=${i%%:*)}   ; hours=${hours##(}
			minutes=$(echo $minutes | sed 's/^0*//')
			hours=$(echo $hours | sed 's/^0*//')
			let 'total_minutes+=hours*60+minutes'
		done
		echo "User $user: Total login time $total_minutes min, total number of logins: $logins"
	fi
done

echo ""
echo " --- Connected Users Summary ---"
echo ""

# Iterate through each user in /etc/passwd
for user in `cat /etc/passwd | cut -d: -f1`; do
	# Get the number of processes the user has
	proc=$(expr `ps -u "$user" | wc -l` - 1)
	if [ $proc -gt 0 ]; then
		cpu=0
		# Calculate total CPU usage percentage for the user's processes
		read cpu <<< $(top -b -n 1 -u "$user" | awk 'NR>7 { sum += $9; } END { print sum; }')
		echo "User $user: $proc processes -> $cpu% CPU"
	fi
done

echo ""
