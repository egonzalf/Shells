#!/bin/bash

function print_usage {
    echo " Usage: $0 --user <username> --passwd <password> --serviceid <service_id> --requestor <requesting-number> --cellphone <cellphonenumbertolocate>"
    echo " or"
    echo " Usage: $0 -u <username> -p <password> -s <service_id> -r <requesting-number> -c <cellphonenumbertolocate>"
    echo " or a mix of those"

}

if /usr/bin/test "a--help" = "a$1" || /usr/bin/test  "-h" = "$1" 
then
    print_usage
    exit 0;
fi



user=MYUSER
passwd=PASSWORD
serviceid=SERVICE77    #77
sessionid=$RANDOM
requestor=56994409089
celular=56909876543    #56994409089

#session using uuid
sessionid=`/usr/bin/uuidgen`

correct="false"

while [ -n "$1"  ]
do
    case "$1" in
	"--user" | "-u" )  # user
	    user=$2
	    correct="true";
	    ;;
	"--passwd" | "-p" )  # passwd
	    passwd=$2
	    correct="true";
	    ;;
	"--serviceid" | "-s" )  # serviceid
	    serviceid=$2
	    correct="true";
	    ;;
#	"--sessionid" | "-e" )  # sessionid
#	    sessionid=$2
#	    ;;
	"--requestor" | "-r" )  # requestor
	    requestor=$2
	    correct="true";
	    ;;
	"--cellphone" | "-c" )  # celular
	    celular=$2
	    correct="true";
	    ;;
	* ) # default
	    if [ $correct = "false" ]
	    then
		print_usage >&2 
		exit 1;
	    fi
	    ;;
    esac
shift 2; # move arguments 
done;


echo "<!DOCTYPE svc_init SYSTEM \"MLP_SVC_INIT_300.DTD\">"
echo "<svc_init ver=\"3.0.0\">"
echo "    <hdr ver=\"3.0.0\">"
echo "        <client>"
echo "            <id>$user</id>"
echo "            <pwd>$passwd</pwd>"
echo "        </client>"
echo "        <serviceid>$serviceid</serviceid>"
echo "        <sessionid>$sessionid</sessionid>"
echo "        <requestor>$requestor</requestor>"
echo "    </hdr>"
echo "    <slir ver=\"3.0.0\">"
echo "        <msids>"
echo "            <msid type=\"MSISDN\">$celular</msid>"
echo "        </msids>"
echo "    </slir>"
echo "</svc_init>"
