#!/bin/bash

mergefile=/tmp/allusers.txt
machines=${MACHINES:-almaha bashiq buraq condor jasmine oqab raed shihab thana}
csvfile="/tmp/users.csv"
tmp=/tmp/$$.tmp

for h in $machines;
do
	ip=$(host $h | cut -f 4 -d " " )
	echo "INSERT into servers (name,ip) VALUES ('$h','$ip') ON DUPLICATE KEY UPDATE ip = '$ip';"
	file=/tmp/machines.lastlog.$h.txt
	ssh $h 'lastlog --user 1000-' > $file
	#ssh $h "lastlog --user 1000- --time $activedays" > $file.active
	ssh $h cat /etc/passwd | awk -F: '{if ( $3 >= 1000 ) print $1" "$3" "$5}' >> $tmp
done

#sort but keep extra data (names), then uniq only by first field, reverse order again (ascending)
sort --reverse $tmp | awk '!x[$1]++' | tac > $mergefile

rm -f $csvfile || true

for i in USERNAME $machines; do echo -n "$i," >> $csvfile; done;
echo >> $csvfile

while read name uid extra
do
	#echo $name
	extra=${extra//,/ }; # replaces comma
	out="$name";
	for h in $machines
	do
		file=/tmp/machines.lastlog.$h.txt
		line=`grep -w $name $file`
		if [ "a" != "a$line" ]; then
			lastconn=$(echo $line | grep -v Never | awk '{print $(NF-3)" "$(NF-4)" "$NF }')
			lastdate=${lastconn:-"01 Jan 1970"}; # if never connected, defaults to 01-01-1970
			echo "INSERT INTO users (username,uid) VALUES('$name',$uid) ON DUPLICATE KEY UPDATE uid = IF( uid < VALUES(uid), VALUES(uid), uid );" 
			echo "INSERT INTO active_users (last,server,user) VALUES (STR_TO_DATE('$lastdate','%d %M %Y'), '$h', '$name') ON DUPLICATE KEY UPDATE last = STR_TO_DATE('$lastdate','%d %M %Y');" 
		fi
	done
done < $mergefile 

rm -f $tmp 

