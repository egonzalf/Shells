#!/bin/bash


function printo {
    echo "TRAPO"
}

trap printo SIGTERM;

while sleep 1
do 
  echo 123
  sleep .2
  echo 456
  sleep .3
  echo 789
done