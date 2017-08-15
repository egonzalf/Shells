#!/bin/bash

fail=0
total=0

function print_usage {
    echo "usage: $0 --repetitions <number>  [--delay <seconds>|--udelay <microseconds>]"
}

function signal_handler {
#    pp=`expr $fail / $total `
#    pp=$(($pp * 100))
#    echo "summary: $pp% of fails"
    exit 2;
}

#chequea que los resultados esten listos
function check_res {
    for i in `seq 1 $1`
      do
      if [ ${res[$i]} -eq 0 ]; then return 1; fi;
    done
    return 0; #success
}

trap signal_handler SIGINT

if [ ! -n "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
    print_usage
    exit 0;
fi

correct="false"
udelay=-1
delay=1

while [ -n "$1"  ]
do
    case "$1" in
        "--repetitions" | "-r" )  # repeticiones / numero de pruebas
	    repeat=$2
	    correct="true"
            ;;
        "--delay" | "-d" )  # delay between repetitions
            delay=$2
	    correct="true"
            ;;
        "--udelay" | "-u" )  # delay between repetitions
            udelay=$2
	    correct="true"
            ;;
	"--no-stop" ) #
	    infinite
	    ;;
        * ) # default                                                                                                                                       
            if [ $correct = "false" ]
            then
                print_usage >&2
                exit 1;
            fi
            ;;
    esac
    shift 2
done

mili=`expr $delay % 1000`
sec=`expr $delay / 1000`
#delay=`echo "$sec.$mili"`

#array de resultados
for i in `seq 1 $repeat`
do
  res[$i]=0;
done

mkdir -p ~/pruebas_carga/
#top -b -c -p `pgrep zwmain -d ,` > ~/pruebas_carga/loadtest_top_$$  2>&1 &
#toppid=$!


for i in `seq 1 $repeat`
do
  echo "iniciando[$i] : `date`"
  ini=`date +%s`
#    nc localhost 9210 < /home/gmlc/tests/puntual_serv77.mlp > /dev/null 2>&1 &
#    echo "resultado[$i]: "`./testGMLC.sh -m ./test_puntual_serv77_gmlc.mlp -r ./gmlc_response.txt ` &
#  echo -e "resultado[$i] -> `./testGMLC.sh -m \"random\" -r ./gmlc_response.txt ` : `date` :: $((`date +%s` - $ini))seconds" && res[$i]=1 &
# echo -e "resultado[$i] -> `./testGMLC.sh -m \"random\" -r ./gmlc_response_error.txt ` : `date` :: $((`date +%s` - $ini))seconds" && res[$i]=1 &

  echo -e "resultado[$i] -> `./testLocaliza.sh -a 1234 -b 4567 ` : `date` :: $((`date +%s` - $ini))seconds" && res[$i]=1 &

  if [ $udelay -ge 0 ]
  then
      usleep $udelay
  else
      sleep $delay
  fi

done

#until check_res $repeat
#do
#  echo "waitin... - $repeat"
#  sleep 1;
#done

sleep 2;
#kill $toppid
#rm ~/pruebas_carga/loadtest_top_$$
echo "### fin $0 ###"