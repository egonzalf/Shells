#!/bin/bash

function check_res {
for i in `seq 1 $1`
do
  if [ ${res[$i]} -eq 0 ]; then return 1; fi;
done
return 0;
}

function signal_handler {
for i in `seq 1 $repeat`
do
  res[$i]=2;
done

}

trap signal_handler SIGINT


repeat=5

for i in `seq 1 $repeat`
do
  res[$i]=0;
done



until check_res $repeat
do
  echo "waitin... - $repeat"
  sleep 1;
done

echo "chaolin"

