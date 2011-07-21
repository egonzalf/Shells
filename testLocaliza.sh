#!/bin/bash

fail=0
total=0

function print_usage {
    echo "usage: $0 --msisdna <> --msisdnb <> [--result <>]"
}

function signal_handler {
    pp=`expr $fail / $total `
    pp=$(($pp * 100))
    echo "summary: $pp% of fails"
    exit 2;
}

trap signal_handler SIGINT

if [ ! -n "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
    print_usage
    exit 0;
fi

correct="false"
result=0  # valor por omision

while [ -n "$1"  ]
do
    case "$1" in
        "--msisdna" | "-a" )  # solicitante
	    a=$2
	    correct="true"
	    shift 2
            ;;
        "--msisdnb" | "-b" )  # numero a localizar
            b=$2
	    correct="true"
	    shift 2
            ;;
        "--result" | "-r" )  # resultado esperado
            result=$2
	    correct="true"
	    shift 2
            ;;
	"--no-stop" ) #
	    infinite=1
	    shift 1
	    ;;
        * ) # default                                                                                                                                       
            if [ $correct = "false" ]
            then
                print_usage >&2
                exit 1;
            fi
            ;;
    esac
done

if [ -z $a ] || [ -z $b ]
then
                print_usage >&2
                exit 1;
fi

############

mkdir -p /tmp/gmlc/

server=192.168.10.254
port=9209

loop=1;

#md5ref_response=`cat $res | egrep -v -i "time|sessionid" | md5sum`
md5ref_response=`echo "<HTML memory='x=-33.44422&y=-70.64629'></HTML>" | md5sum`

while [ $loop -gt 0 ] || [ $infinite ]
do

restmp=/tmp/gmlc/gmlcres$$_$total
/usr/bin/curl --connect-timeout 2 --max-time 23 "http://$server:$port/localizar?SERVICIO=77&MSISDN_A=$a&MSISDN_B=$b" -o $restmp > /dev/null 2>&1
md5response=`egrep -i -o "resgmlc=[0-9]+" $restmp 2> /dev/null`
#md5response=`cat $restmp | md5sum`

md5ref_response="resgmlc=$result"

#echo "$md5ref_response  ::  $md5response"
if [ "$md5ref_response=" = "$md5response=" ]
then
#    echo "test = OK ="
    echo -e "test \e[32m= OK =\e[0m"
    rm $restmp
else
    fail=$(($fail + 1))
#    echo "test ## FAIL ##"
    echo  -e "test \e[31m## FAIL ##\e[0m : $md5response"
fi
#"\e[0m"

loop=$(($loop - 1))
total=$(($total + 1))

done

