#!/bin/bash

##############################################################################
## NOOR backup for every user under /home/
## will exclude listed files and files bigger than 5mb
## This is meant to be run as root
##############################################################################

# get the local machine name
hostname=$(hostname -s)

# Exclude pattern for rsync
excludelist=/tmp/.noor-exclude.list
cat > $excludelist << EOF
*.o
#.svn/
#.git/
*.so
*.a
noor-backup/
EOF


for userdir in `find /home/ -maxdepth 1 -type d `; do
	# get username and check uid
	username=$(basename $userdir)
	id=$(id -u $username 2>/dev/null )
	[ -n "$id" ] && [ $id -gt 100000 ] || continue;

	remotepath="/grs_data/labs/ecrc/gonzalea/ALLECRC/$hostname/$username"

	#TODO: backup only recent files
	#find /path/to/dir -mtime -366 > /tmp/rsyncfiles # files younger than 1 year
	#rsync -Ravh --files-from=/tmp/rsyncfiles / root@www.someserver.com:/root/backup

	nice -n +19 rsync -e 'ssh -i /home/gonzalea/.ssh/id_rsa -o "NumberOfPasswordPrompts 0"' -az -vv --exclude-from=$excludelist --delete --max-size=5m $userdir/ gonzalea@noor1.kaust.edu.sa:$remotepath || continue;

	sleep 5
done

