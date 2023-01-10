#!/bin/bash

for i in {0..1800}; do
    NUM=`squeue -u $USER | grep -v JOBID | wc -l`
    DATE=`date "+%F-%T"`
    echo $DATE $NUM
    sleep 2
done
