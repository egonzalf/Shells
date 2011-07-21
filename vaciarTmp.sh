#!/bin/bash

### script that cleans /tmp according to:
### - files older than 1 week
### - disk usage above 95% -> decrese age limit by 1 day until free space is above 5%

touch /tmp/vaciarTmp.log

for days in `seq 31 -1 1`  # count from 31 backwards
do
    used_pctg=`df -P | grep /$ | awk '{printf("%d", (100*($3/($4+$3))))}'`

    if [ $used_pctg -lt 90 ] #if usage is less than 90%, exit
    then
	#echo "out!"
	break
    fi

    #echo "#$days"
    find /tmp/ -mindepth 1 -mount -atime +$days -delete

done
