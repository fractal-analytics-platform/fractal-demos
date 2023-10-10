#!/bin/bash

LABEL=$1

###############################################################################

# Set useful variables
PROJECT_NAME="proj-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=`pwd`/tmp
OUTPUT_PATH=`pwd`/output-$LABEL
mkdir -p $OUTPUT_PATH
###############################################################################

# Create project
PROJECT_ID=`fractal --batch project new $PROJECT_NAME`

# Add input dataset, and add a resource to it
DS_IN_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_IN_NAME" --type image --make-read-only`
echo "DS_IN_ID: $DS_IN_ID"
fractal dataset add-resource $PROJECT_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_OUT_NAME" --type zarr`
fractal --batch dataset add-resource $PROJECT_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow and add tasks
WF_ID=`fractal --batch workflow new "$WF_NAME" $PROJECT_ID`
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "prepare_metadata" --args-file Parameters/prepare_metadata-args.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "sleep_task" --args-file Parameters/sleep_task-args.json --meta-file Parameters/sleep_task-meta-A.json

# Apply workflow
# time fractal --batch workflow apply $PROJECT_ID $WF_ID $DS_IN_ID $DS_OUT_ID
