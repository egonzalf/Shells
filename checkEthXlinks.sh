#!/bin/bash

# script para verificar si las distintas ETHX tienen el cable conectado
# se debe tener permisos de super usuario para ejecutar el ethtool

function print_usage {
    echo "usage: $0 <max-ethX-suffix>"
}

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ ! -n "$1" ]
then
    max=0;
    print_usage
    echo "assuming <max-ethX-suffix> = $max"
else
    max=$1
fi

for i in `seq 0 $max`
do 
    ethtool eth$i | grep -q "Link detected: yes" \
	&& echo -e "eth$i CONNECTED" || echo -e "eth$i DISCONNECTED"
done 2> /dev/null


exit 0
