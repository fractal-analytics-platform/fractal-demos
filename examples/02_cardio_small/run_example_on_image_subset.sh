#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

LABEL="cardio-2x2-zenodo-subset"

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH=$(pwd)/../images/10.5281_zenodo.7057076
CURRENT_DIRECTORY=$(pwd)
ILLUMINATION_PROFILES_FOLDER=$(pwd)/../illum_corr_images/
ZARR_DIR=$(pwd)/output-${LABEL}
###############################################################################

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Set useful variables
PROJECT_NAME="Project $LABEL"
DS_NAME="Dataset $LABEL"
WF_NAME="Workflow $LABEL"
# HERE=$(pwd)

# Set cache path and remove any previous file from there
FRACTAL_CACHE_PATH=$(pwd)/".cache"
export FRACTAL_CACHE_PATH="$FRACTAL_CACHE_PATH"
rm -rv "$FRACTAL_CACHE_PATH" 2> /dev/null

###############################################################################

# Create project
PROJECT_ID=$(fractal --batch project new "$PROJECT_NAME")
echo "PROJECT_ID=$PROJECT_ID"  # Do not remove this line, it's used in fractal-containers

# Add dataset
DS_ID=$(fractal --batch project add-dataset "$PROJECT_ID" "$DS_NAME" "$ZARR_DIR")
echo "DS_IN_ID=$DS_ID"

# Create workflow
WF_ID=$(fractal --batch workflow new "$WF_NAME" "$PROJECT_ID")
echo "WF_ID=$WF_ID"

###############################################################################

# Prepare some JSON files for task arguments. Note that this has to happen a runtime,
# since the absolute paths are needed and not known in advance)

sed "s|__INPUT_PATH__|$INPUT_PATH|g" Parameters/RAW_args_cellvoyager_to_ome_zarr_init_subset.json > Parameters/args_cellvoyager_to_ome_zarr_init_subset.json
sed "s|__ILLUMINATION_PROFILES_FOLDER__|$ILLUMINATION_PROFILES_FOLDER|g" Parameters/RAW_args_illumination_correction.json > Parameters/args_illumination_correction.json
sed "s|__CURRENT_DIRECTORY__|$CURRENT_DIRECTORY|g" Parameters/RAW_args_measurements_3D.json > Parameters/args_measurements_3D.json
sed "s|__CURRENT_DIRECTORY__|$CURRENT_DIRECTORY|g" Parameters/RAW_args_measurements_1.json > Parameters/args_measurements_1.json
sed "s|__CURRENT_DIRECTORY__|$CURRENT_DIRECTORY|g" Parameters/RAW_args_measurements_2.json > Parameters/args_measurements_2.json
sed "s|__CURRENT_DIRECTORY__|$CURRENT_DIRECTORY|g" Parameters/RAW_args_measurements_3.json > Parameters/args_measurements_3.json
sed "s|__CURRENT_DIRECTORY__|$CURRENT_DIRECTORY|g" Parameters/RAW_args_measurements_4.json > Parameters/args_measurements_4.json

# ###############################################################################

# Convert to OME-Zarr
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Convert Cellvoyager to OME-Zarr" --args-non-parallel Parameters/args_cellvoyager_to_ome_zarr_init_subset.json --meta-non-parallel Parameters/example_meta.json

# Illumination correction
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Illumination Correction" --args-parallel Parameters/args_illumination_correction.json

# 3D Segmentation & measurements
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Cellpose Segmentation" --args-parallel Parameters/args_cellpose_segmentation_3D.json --meta-parallel Parameters/meta_cellpose.json
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Napari Workflows Wrapper" --args-parallel Parameters/args_measurement_3D.json

# Maximum intensity projection
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Maximum Intensity Projection HCS Plate" --args-non-parallel Parameters/args_mip.json

# 2D Segmentation
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Cellpose Segmentation" --args-parallel Parameters/args_cellpose_segmentation.json --meta-parallel Parameters/meta_cellpose.json

## Run a series of napari workflows

# Workflow 1
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Napari Workflows Wrapper" --args-parallel Parameters/args_measurements_1.json

# Workflow 2 
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Napari Workflows Wrapper" --args-parallel Parameters/args_measurements_2.json

# Workflow 3
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Napari Workflows Wrapper" --args-parallel Parameters/args_measurements_3.json

# Workflow 4
fractal --batch workflow add-task "$PROJECT_ID" "$WF_ID" --task-name "Napari Workflows Wrapper" --args-parallel Parameters/args_measurements_4.json

# Submit workflow for execution
JOB_ID=$(fractal --batch job submit "$PROJECT_ID" "$WF_ID" "$DS_ID")
echo "JOB_ID=$JOB_ID"  # Do not remove this line, it's used in fractal-containers
