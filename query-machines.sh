#!/bin/bash


#MACHINES="almaha bashiq buraq jasmine oqab raed shihab";
#OLD_MACHINES="almaha bashiq buraq oqab raed shihab";

for h in $MACHINES; 
do
	echo -e "\n## $h : $@ ##"
	ssh $h $@ 2>/dev/null
done
