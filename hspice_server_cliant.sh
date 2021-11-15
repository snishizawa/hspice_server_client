#!/bin/zsh

NUM_CPU=4
START=0
END=7
PORT=2500
HOST=`hostname`
# wakeup server
for I in `seq 1 $NUM_CPU`; do
  COREID=$(($I % $NUM_CPU))
  PORTA=$HOST":"$PORT$COREID
  echo "hspice -CC -port $PORTA -stop 0.3 & > /dev/null 2>&1"
  echo "start hspice $PORTA"
done
wait

# run spice 
for I in `seq $START $END`; do
  NUM_PROC=$(($NUM_PROC + 1))
  COREID=$(($I % $NUM_CPU))
  PORTA=$HOST":"$PORT$COREID
  FILE="input_"$I".sp"
  echo "hspice -CC $FILE -port $PORTA & > /dev/null 2>&1"
  echo "run hspice $PORTA"
  sleep 1
  if(($NUM_PROC >= $NUM_CPU)); then
    wait
    NUM_PROC=0;
  fi
done
wait
# kill server
for I in `seq 1 $NUM_CPU`; do
  COREID=$(($I % $NUM_CPU))
  PORTA=$HOST":"$PORT$COREID
  echo "hspice -CC -K -port $PORTA > /dev/null 2>&1"
  echo "kill hspice $PORTA"
done
wait

