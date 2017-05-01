#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

for username in `cut -d: -f1 /etc/passwd`; do
	id=$(id -u $username 2>/dev/null )
	[ -n "$id" ] && [ $id -gt 100000 ] || continue;

	echo "-> $username"
	sudo -u $username -H /opt/noor-backup-folder.sh
	sleep 1.3
done

