#!/bin/bash

# Experimental script to automate task collection on Apple Silicon Macs

# This is to be run in the fractal client environemnt that was just installed
# One can also run steps 1-3 in a new environment and then run steps 4 and 
# onwards in the client environment by adapting the paths.
# Having separate task & client environemnts is cleaner and should certainly 
# be done in actual deployments. For local testing, installing everything in
# the client environment works though.

TASK_VERSION="0.7.4"
# 1. Manually install the dependencies that are creating issues
conda install imagecodecs -y

# 2. Install the tasks package
pip install fractal-tasks-core==$TASK_VERSION

# 3. Get the Python executable
PYTHON_SOURCE=`which python`
TASK_BASE_PATH=${PYTHON_SOURCE%bin/python}lib/python3.9/site-packages/fractal_tasks_core

# 4. Add the tasks to Fractal manually
fractal task new --input-type image --output-type zarr --default-args-file manual_task_collection_params/create_ome_zarr.json --meta-file manual_task_collection_params/meta_zarr_structure.json "Create OME-Zarr structure" "$PYTHON_SOURCE $TASK_BASE_PATH/create_ome_zarr.py" "manual:fractal-tasks-core==$TASK_VERSION-create_ome_zarr"

fractal task new --input-type zarr --output-type zarr --default-args-file manual_task_collection_params/yokogawa_to_zarr.json --meta-file manual_task_collection_params/meta_parallel_task.json "Convert Yokogawa to OME-Zarr" "$PYTHON_SOURCE $TASK_BASE_PATH/yokogawa_to_ome_zarr.py" "manual:fractal-tasks-core==$TASK_VERSION-yokogawa_to_ome_zarr"

fractal task new --input-type zarr --output-type zarr --default-args-file manual_task_collection_params/copy_ome_zarr.json --meta-file manual_task_collection_params/meta_zarr_structure.json "Copy OME-Zarr structure" "$PYTHON_SOURCE $TASK_BASE_PATH/copy_ome_zarr.py" "manual:fractal-tasks-core==$TASK_VERSION-copy_ome_zarr"

fractal task new --input-type zarr --output-type zarr --default-args-file manual_task_collection_params/maximum_intensity_projection.json --meta-file manual_task_collection_params/meta_parallel_task.json "Maximum Intensity Projection" "$PYTHON_SOURCE $TASK_BASE_PATH/maximum_intensity_projection.py" "manual:fractal-tasks-core==$TASK_VERSION-maximum_intensity_projection"

fractal task new --input-type zarr --output-type zarr --default-args-file manual_task_collection_params/cellpose_segmentation.json --meta-file manual_task_collection_params/meta_cellpose.json "Cellpose Segmentation" "$PYTHON_SOURCE $TASK_BASE_PATH/cellpose_segmentation.py" "manual:fractal-tasks-core==$TASK_VERSION-cellpose_segmentation"

fractal task new --input-type zarr --output-type zarr --default-args-file manual_task_collection_params/illumination_correction.json --meta-file manual_task_collection_params/meta_parallel_task.json "Illumination correction" "$PYTHON_SOURCE $TASK_BASE_PATH/illumination_correction.py" "manual:fractal-tasks-core==$TASK_VERSION-illumination_correction"

fractal task new --input-type zarr --output-type zarr --default-args-file manual_task_collection_params/napari_workflows_wrapper.json --meta-file manual_task_collection_params/meta_parallel_task.json "Napari workflows wrapper" "$PYTHON_SOURCE $TASK_BASE_PATH/napari_workflows_wrapper.py" "manual:fractal-tasks-core==$TASK_VERSION-napari_workflows_wrapper"

fractal task new --input-type image --output-type zarr --default-args-file manual_task_collection_params/create_ome_zarr_multiplex.json --meta-file manual_task_collection_params/meta_zarr_structure.json "Create OME-ZARR structure (multiplexing)" "$PYTHON_SOURCE $TASK_BASE_PATH/create_ome_zarr_multiplex.py" "manual:fractal-tasks-core==$TASK_VERSION-create_ome_zarr_multiplex"

