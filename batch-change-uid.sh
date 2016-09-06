#!/bin/sh


file=$1
if ! test -f $file; then exit 1; fi

while read username newid
do
	[ -z $newid ] && continue
	[ -z $username ] && continue
	if ! id $username ; then continue; fi 
	echo "Changing $username to new id:$newid"
	usermod -u $newid $username
	id $username
	echo;
done < $file
