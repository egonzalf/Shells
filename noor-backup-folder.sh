#!/bin/bash

##############################################################################
## Requirements for the NOOR backup
## 1) Request a Noor account and ask to be part of rc-ecrc group
## 2) Set up a passwordless ssh connection to noor1 (using ssh keys)
## 3) create noor-backup directory:
##    mkdir -p $HOME/noor-backup
## 4) Uncomment this script in your crontab
##    crontab -e
##############################################################################

LOCALDIR=$HOME/noor-backup
LOCALDIR=$HOME
#REMOTEHOST=noor2.kaust.edu.sa
REMOTEHOST=dm02.kaust.edu.sa

# get the local machine name
hostname=$(hostname -s)

# if directory doesn't exist, exit
[ -d $LOCALDIR ] || exit 101;

# if userid is less than 100000, exit
id=$(id -u $USER)
[ $id -gt 100000 ] || exit 102;

attempts=0
MAXATTEMPTS=3

REMOTEPATH="/rcsdata/ecrc/$USER/$hostname"

while [ $attempts -lt $MAXATTEMPTS ] ; do 
	attempts=$((attempts + 1));
	# if max attempts reached, try to use 'real' path in noor
	[ $attempts -eq $((MAXATTEMPTS)) ] && REMOTEPATH="/grs_data/labs/ecrc/$USER/$hostname"

	# copy data, deleting files that no longer exists locally.
	# Files are stored in the path /rcsdata/ecrc/$USER/$hostname at NOOR
	# Files are kept for 60 days in IT's own backup system, just in case.
	rsync -e 'ssh -o "NumberOfPasswordPrompts 0"' -a --delete $LOCALDIR/ $REMOTEHOST:$REMOTEPATH && break;
done

exit $((attempts-1))

