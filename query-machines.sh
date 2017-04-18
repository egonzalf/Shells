#!/bin/bash


#MACHINES="almaha bashiq buraq jasmine oqab raed shihab";
#OLD_MACHINES="almaha bashiq buraq oqab raed shihab";
if [ "$1" == "-l" -a "a$2" != "a" ];
then
	u="$2@"
	shift 2
fi

[ "a$1" == "a" ] && exit 1;

for h in $MACHINES; 
do
	h="$u$h"
	echo -e "\n## $h : $@ ##"
	ssh $h $@ 2>/dev/null
done
