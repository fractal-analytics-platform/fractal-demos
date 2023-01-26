# LABEL needs to be the same as in the initial workflow
LABEL="1"

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Get IDs from the first workflow
PRJ_ID="13"
# Output dataset from the first workflow is both input & output now
DS_OUT_ID="26"

###############################################################################

WORKER_INIT="\
export CELLPOSE_LOCAL_MODELS_PATH=${HOME}/.cache/CELLPOSE_LOCAL_MODELS_PATH
export NUMBA_CACHE_DIR=${HOME}/.cache/NUMBA_CACHE_DIR
export NAPARI_CONFIG=${HOME}/.cache/NAPARI_CACHE_DIR
export XDG_CONFIG_HOME=${HOME}/.cache/XDG
"

# Set useful variables
PRJ_NAME="proj-$LABEL"
WF_NAME="Workflow Contiuation $LABEL"

# Define/initialize empty project folder and temporary file
PROJ_DIR=`pwd`/tmp_${LABEL}

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=${PROJ_DIR}/output
OUTPUT_PATH=${PROJ_DIR}/output
###############################################################################

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/args_cellpose_segmentation_cells.json --meta-file Parameters/example_meta.json
echo "{\"level\": 0, \"ROI_table_name\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"cells\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"cells\"}}}" > Parameters/args_measurement_cells.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/args_measurement_cells.json --meta-file Parameters/example_meta.json

# Look at the current workflows
fractal workflow show $WF_ID
echo

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_OUT_ID --worker-init "$WORKER_INIT"
