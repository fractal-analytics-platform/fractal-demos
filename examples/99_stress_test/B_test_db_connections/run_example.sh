#!/bin/bash

# Set label from args (useful to avoid uniqueness constraints)
LABEL=$1

# Create project and I/O datasets
PROJECT_ID=`fractal --batch project new "project-$LABEL"`
DS_IN_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_IN_NAME" --type image --make-read-only`
fractal --batch dataset add-resource $PROJECT_ID $DS_IN_ID `pwd`/tmp
DS_OUT_ID=`fractal --batch project add-dataset $PROJECT_ID "output-ds-$LABEL"`
OUTPUT_PATH=`pwd`/output-$LABEL
mkdir -p $OUTPUT_PATH
fractal --batch dataset add-resource $PROJECT_ID $DS_OUT_ID $OUTPUT_PATH

# TEST 1: create dummy workflow and add the same task N times
WF_ID=`fractal --batch workflow new "dummy-workflow-$LABEL" $PROJECT_ID`
for IND_WFTASK in {1..20}; do
    echo "Add WorkflowTask $IND_WFTASK/20"
    fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "prepare_metadata"
done

# Create actual workflow
WF_ID=`fractal --batch workflow new "workflow-$LABEL" $PROJECT_ID`
mkdir -p Parameters

# Create parameter files
echo "{\"num_components\": 2}" > Parameters/prepare_metadata-args.json
echo "{\"sleep_time\": 30}" > Parameters/sleep_task-args.json

# Add tasks to workflow
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "prepare_metadata" --args-file Parameters/prepare_metadata-args.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "sleep_task" --args-file Parameters/sleep_task-args.json

# TEST 2: Apply workflow N times
for IND_APPLY in {1..20}; do
    echo "Call workflow-apply $IND_APPLY/20"
    fractal --batch workflow apply $PROJECT_ID $WF_ID $DS_IN_ID $DS_OUT_ID
    echo
done
