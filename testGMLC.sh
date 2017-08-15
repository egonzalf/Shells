#!/bin/bash

fail=0
total=0

function print_usage {
    echo "usage: $0 --mlp <mlpfile> --res <xmlresponse>"
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

while [ -n "$1"  ]
do
    case "$1" in
        "--mlp" | "-m" )  # mlp
	    mlp=$2
	    correct="true"
	    shift 2
            ;;
        "--res" | "-r" )  # response
            res=$2
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

if [ -z $mlp ] || [ -z $res ]
then
                print_usage >&2
                exit 1;
fi

############

if [ $mlp = "random" ]
then
    mlp="/tmp/mlp$$"
    ./createMLP.sh -u dmapas -p sadawp -s 77 -r 56994409089 -c 56994409089 > $mlp
fi

mkdir -p /tmp/gmlc/

server=localhost
port=9210

loop=1;

md5ref_response=`cat $res | egrep -v -i "time|sessionid" | md5sum`

while [ $loop -gt 0 ] || [ $infinite ]
do

mlptmp=/tmp/gmlc/gmlcmlp$$_$total
restmp=/tmp/gmlc/gmlcres$$_$total
cat $mlp > $mlptmp
nc -w 30 $server $port < $mlp > $restmp 2>&1
md5response=`cat $restmp | egrep -v -i "time|sessionid" | md5sum`


#echo "$md5ref_response  ::  $md5response"
if [ "$md5ref_response=" = "$md5response=" ]
then
#    echo "test = OK ="
    echo "test \e[32m= OK =\e[0m"
    rm $restmp
    rm $mlptmp
else
    fail=$(($fail + 1))
#    echo "test ## FAIL ##"
    echo  "test \e[31m## FAIL ##\e[0m"
fi
#"\e[0m"

loop=$(($loop - 1))
total=$(($total + 1))

done

rm $mlp 