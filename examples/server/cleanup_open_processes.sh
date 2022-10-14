#!/bin/bash

## (1) REMOVE ALL PROCESSES WITH FILES OPEN ON A GIVEN PORT (e.g. 8001)

PORT=`cat PORT`

echo "lsof -i :$PORT"
echo
lsof -i :$PORT
echo
echo

PIDs=`lsof -i :$PORT | awk '(NR>1) {print $2}'`

echo "now killing following processes:"
echo
for PID in $PIDs; do
   ps aux | grep $PID | grep -v grep
   kill -9 $PID
done

# (2) REMOVE ALL PROCESSES WITH NAMES MATCHING TO SOME KEYWORDS

KEYWORDS="process_worker_pool HTEX parsl multiprocessing"

for KEY in $KEYWORDS; do
    PIDs=`ps aux | grep $KEY | grep -v grep | awk '(NR>1) {print $2}'`
    echo "Grepping and killing $KEY processes"
    echo $PIDs

    for PID in $PIDs; do
        kill $PID
    done
    sleep 0.1
    echo
done
