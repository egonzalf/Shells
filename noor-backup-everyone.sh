#!/bin/bash

##############################################################################
## NOOR backup for every user under /home/
## will exclude listed files and files bigger than 50mb
## This is meant to be run as root
##############################################################################

MAXSIZE="50m"
# get the local machine name
hostname=$(hostname -s)

# Exclude pattern for rsync
excludelist=/tmp/.noor-exclude.list
cat > $excludelist << EOF
*.o
*.cu_o
#.svn/
#.git/
#*.so
#*.a
*.la
*.pyo
*.pyc
# Asuming user is doing backup on his/her own.
/noor-backup/
EOF

POSSIBLE_HOSTS="dm dm01 dm02"
DSTHOST='void'
for h in $POSSIBLE_HOSTS ; do
	if ping -q -c 3 $h.kaust.edu.sa; then
		DSTHOST="$h.kaust.edu.sa"
		break
	fi
done
[ "$DSTHOST" == "void" ] && echo 'no dsthost' && exit 1;

case $DSTHOST in
	noor1*)
		remotepath="/grs_data/labs/ecrc/gonzalea/ALLECRC/$hostname"
		;;
	*)
		remotepath="/rcsdata/ecrc/gonzalea/ALLECRC/$hostname"
		;;
esac

# lower priority
renice -n 5 -p $$ || true

for userdir in `find /home/ -maxdepth 1 -type d `; do
	# get username and check uid
	username=$(basename $userdir)
	id=$(id -u $username 2>/dev/null )
	[ -n "$id" ] && [ $id -gt 100000 ] || continue;

	#TODO: backup only recent files
	#find /path/to/dir -mtime -366 > /tmp/rsyncfiles # files younger than 1 year
	#rsync -Ravh --files-from=/tmp/rsyncfiles / root@www.someserver.com:/root/backup

	# ionice to avoid stressing the system (best-effort)
	# use delete-delay because is more efficient than delete-after
	ionice -c 2 -n 6 -t rsync -e 'ssh -i /home/gonzalea/.ssh/id_rsa -o "NumberOfPasswordPrompts 0"' -az -vv --exclude-from=$excludelist --delete-delay --delete-excluded --max-size=$MAXSIZE $userdir/ gonzalea@$DSTHOST:$remotepath/$username || continue;

	sleep 5
done
