#!/bin/bash

LABEL=$1

###############################################################################

# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=`pwd`/tmp
OUTPUT_PATH=`pwd`/output-$LABEL
mkdir -p $OUTPUT_PATH
###############################################################################

# Create project
OUTPUT=`fractal --batch project new $PRJ_NAME`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`

# Update dataset name/type, and add a resource
fractal --batch dataset add-resource $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
fractal --batch dataset add-resource $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow and add tasks
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
fractal --batch workflow add-task $WF_ID "prepare_metadata" --args-file Parameters/prepare_metadata-args.json
fractal --batch workflow add-task $WF_ID "sleep_task" --args-file Parameters/sleep_task-args.json --meta-file Parameters/sleep_task-meta-A.json
# fractal --batch workflow add-task $WF_ID "sleep_task" --args-file Parameters/sleep_task-args.json --meta-file Parameters/sleep_task-meta-B.json
# fractal --batch workflow add-task $WF_ID "sleep_task" --args-file Parameters/sleep_task-args.json --meta-file Parameters/sleep_task-meta-C.json

# Apply workflow
time fractal --batch workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID
