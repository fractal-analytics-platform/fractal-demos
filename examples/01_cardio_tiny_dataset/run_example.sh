#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

LABEL="cardiac-tiny-$1"

###############################################################################
# IMPORTANT: This defines the location of input & output data
# Set cache path and remove any previous file from there
FRACTAL_CACHE_PATH=$(pwd)/".cache"
export FRACTAL_CACHE_PATH="$FRACTAL_CACHE_PATH"
if [ -d "$FRACTAL_CACHE_PATH" ]; then
    rm -rv "$FRACTAL_CACHE_PATH"  2> /dev/null
fi

###############################################################################

SUBMISSION_SCRIPT=submissions.sh
echo > "$SUBMISSION_SCRIPT"

N_INDICES=10

for INDEX in $(seq 1 $N_INDICES); do

    ZARR_DIR=$(pwd)/output_${LABEL}_${INDEX}

    # Set useful variables
    PROJECT_NAME="Project $LABEL / $INDEX"
    DS_NAME="Dataset $LABEL"
    WF_NAME="Workflow $LABEL"


    # Create project, dataset, workflow
    PROJECT_ID=$(fractal --batch project new "$PROJECT_NAME")
    echo "PROJECT_ID=$PROJECT_ID"  # Do not remove this line, it's used in fractal-containers
    DS_ID=$(fractal --batch project add-dataset "$PROJECT_ID" "$DS_NAME" "$ZARR_DIR")
    echo "DS_IN_ID=$DS_ID"
    WF_ID=$(fractal --batch workflow new "$WF_NAME" "$PROJECT_ID")
    echo "WF_ID=$WF_ID"

    # Add tasks to workflow
    fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "create_ome_zarr_compound" --args-non-parallel Parameters/args_create_ome_zarr_compound.json
    fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "generic_task" --args-non-parallel Parameters/args_generic_task.json
    fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "illumination_correction"
    fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "generic_task" --args-non-parallel Parameters/args_generic_task.json

    SUBMISSION_LINE="fractal --batch job submit $PROJECT_ID $WF_ID $DS_ID"
    echo "$SUBMISSION_LINE"
    echo "$SUBMISSION_LINE" >> "$SUBMISSION_SCRIPT"
done
