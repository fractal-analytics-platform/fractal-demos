#!/bin/bash

LABEL=$1

###############################################################################
# THINGS TO BE CHANGED BY THE USER
# Adapt to settings to where you run the example
BASE_FOLDER_EXAMPLE=`pwd`/..
###############################################################################

# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Define/initialize empty project folder and temporary file
PROJ_DIR=`pwd`/tmp/${LABEL}
rm -r $PROJ_DIR
mkdir -p $PROJ_DIR

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=/tmp/
OUTPUT_PATH=${PROJ_DIR}/output
###############################################################################

# Create project
OUTPUT=`fractal --batch project new $PRJ_NAME $PROJ_DIR`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`

# Update dataset name/type, and add a resource
fractal --batch dataset add-resource $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`

# fractal dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
fractal --batch dataset add-resource $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`

# Add tasks to workflow
fractal --batch workflow add-task $WF_ID 1
fractal --batch workflow add-task $WF_ID 2 --args-file Parameters/edit_task.json

# Apply workflow
time fractal --batch workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID --worker-init "$WORKER_INIT"
