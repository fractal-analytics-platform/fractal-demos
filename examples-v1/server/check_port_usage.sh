#!/bin/bash

## Show processes with files open on a given port

if [ $# -eq 0 ]

then

    echo "No arguments supplied, please provide the port number"

else

    PORT=$1

    echo "lsof -i :$PORT"
    lsof -i :$PORT
    echo

    PIDs=`lsof -i :$PORT | awk '(NR>1) {print $2}'`
    echo "PIDs connected to PORT $PORT (that can be killed with \`kill -9\`)"
    echo $PIDs
    echo

fi
