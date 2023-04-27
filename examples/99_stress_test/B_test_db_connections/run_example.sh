#!/bin/bash

# Set label from args (useful to avoid uniqueness constraints)
LABEL=$1

# Create project and I/O datasets
OUTPUT=`fractal --batch project new "project-$LABEL"`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`
fractal --batch dataset add-resource $PRJ_ID $DS_IN_ID `pwd`/tmp
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "output-ds-$LABEL"`
OUTPUT_PATH=`pwd`/output-$LABEL
mkdir -p $OUTPUT_PATH
fractal --batch dataset add-resource $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# TEST 1: create dummy workflow and add the same task N times
WF_ID=`fractal --batch workflow new "dummy-workflow-$LABEL" $PRJ_ID`
for IND_WFTASK in {1..20}; do
    echo "Add WorkflowTask $IND_WFTASK/20"
    fractal --batch workflow add-task $WF_ID "prepare_metadata"
done

# Create actual workflow
WF_ID=`fractal --batch workflow new "workflow-$LABEL" $PRJ_ID`
mkdir -p Parameters

# Create parameter files
echo "{\"num_components\": 2}" > Parameters/prepare_metadata-args.json
echo "{\"sleep_time\": 30}" > Parameters/sleep_task-args.json

# Add tasks to workflow
fractal --batch workflow add-task $WF_ID "prepare_metadata" --args-file Parameters/prepare_metadata-args.json
fractal --batch workflow add-task $WF_ID "sleep_task" --args-file Parameters/sleep_task-args.json

# TEST 2: Apply workflow N times
for IND_APPLY in {1..20}; do
    echo "Call workflow-apply $IND_APPLY/20"
    fractal --batch workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID
    echo
done
