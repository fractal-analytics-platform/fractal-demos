#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

LABEL="cardiac-tiny"

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH=$(pwd)/../images/10.5281_zenodo.8287221/
ZARR_DIR=$(pwd)/output_${LABEL}
###############################################################################

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Set useful variables
PROJECT_NAME="proj-$LABEL"
DS_NAME="ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
FRACTAL_CACHE_PATH=$(pwd)/".cache"
export FRACTAL_CACHE_PATH="$FRACTAL_CACHE_PATH"
rm -rv "$FRACTAL_CACHE_PATH"  2> /dev/null

###############################################################################

# Create project
PROJECT_ID=$(fractal --batch project new "$PROJECT_NAME")
echo "PROJECT_ID=$PROJECT_ID"  # Do not remove this line, it's used in fractal-containers

# Add input dataset, and add a resource to it
DS_ID=$(fractal --batch project add-dataset "$PROJECT_ID" "$DS_NAME" "$ZARR_DIR")
echo "DS_IN_ID=$DS_ID"

# Create workflow
WF_ID=$(fractal --batch workflow new "$WF_NAME" "$PROJECT_ID")
echo "WF_ID=$WF_ID"

###############################################################################

# Prepare some JSON files for task arguments (note: this has to happen here,
# because we need to include the path of the current directory)
sed "s|__INPUT_PATH__|$INPUT_PATH|g" Parameters/RAW_args_cellvoyager_to_ome_zarr_init.json > Parameters/args_cellvoyager_to_ome_zarr_init.json
CURRENT_DIRECTORY=$(pwd)
sed "s|__CURRENT_DIRECTORY__|$CURRENT_DIRECTORY|g" Parameters/RAW_args_measurement.json > Parameters/args_measurement.json

# ###############################################################################

# Add tasks to workflow
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Convert Cellvoyager to OME-Zarr" --args-non-parallel Parameters/args_cellvoyager_to_ome_zarr_init.json --meta-non-parallel Parameters/example_meta.json
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Maximum Intensity Projection HCS Plate" --args-non-parallel Parameters/copy_ome_zarr.json
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Cellpose Segmentation" --args-parallel Parameters/args_cellpose_segmentation.json
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Napari Workflows Wrapper" --args-parallel Parameters/args_measurement.json --meta-parallel Parameters/example_meta.json

# Apply workflow
JOB_ID=$(fractal --batch job submit "$PROJECT_ID" "$WF_ID" "$DS_ID")
echo "JOB_ID=$JOB_ID"  # Do not remove this line, it's used in fractal-containers
