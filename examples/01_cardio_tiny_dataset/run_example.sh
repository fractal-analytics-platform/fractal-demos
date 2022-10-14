LABEL="cardio_tiny"

###############################################################################
# IMPORTANT: MODIFY THE FOLLOWING TWO LINES SO THAT THEY POINT TO ABSOLUTE PATHS
INPUT_PATH=`pwd`/../images/10.5281_zenodo.7059515
OUTPUT_PATH=${PROJ_DIR}/output
###############################################################################

# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -v ${FRACTAL_CACHE_PATH}/session
rm -v ${FRACTAL_CACHE_PATH}/tasks

# Define/initialize empty project folder and temporary file
PROJ_DIR=`pwd`/tmp_${LABEL}
rm -r $PROJ_DIR
mkdir $PROJ_DIR
TMPJSON=${PROJ_DIR}/tmp.json

# Define useful auxiliary command (this will be removed in the future)
CMD_JSON="python aux_extract_id_from_project_json.py $TMPJSON"

# Create project
fractal -j project new $PRJ_NAME $PROJ_DIR > $TMPJSON
PRJ_ID=`$CMD_JSON project_id`
DS_IN_ID=`$CMD_JSON dataset_id "default"`
echo "PRJ_ID: $PRJ_ID"
echo "DS_IN_ID: $DS_IN_ID"

# Update dataset name/type, and add a resource
fractal dataset edit --name "$DS_IN_NAME" -t image --read-only $PRJ_ID $DS_IN_ID
fractal dataset add-resource -g "*.png" $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
fractal dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
fractal dataset add-resource -g "*.zarr" $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch task new "$WF_NAME" workflow image zarr`
echo "WF_ID: $WF_ID"

# Add subtasks

echo "{\"num_levels\": 5, \"coarsening_xy\": 2, \"channel_parameters\": {\"A01_C01\": {\"label\": \"DAPI\",\"colormap\": \"00FFFF\",\"start\": 110,\"end\": 800 }, \"A01_C02\": {\"label\": \"nanog\",\"colormap\": \"FF00FF\",\"start\": 110,\"end\": 290 }, \"A02_C03\": {\"label\": \"Lamin B1\",\"colormap\": \"FFFF00\",\"start\": 110,\"end\": 1600 }}}" > ${PROJ_DIR}/args_create.json
fractal task add-subtask $WF_ID "Create OME-ZARR structure" --args-file ${PROJ_DIR}/args_create.json

fractal task add-subtask $WF_ID "Yokogawa to Zarr"

echo "{\"labeling_level\": 1, \"executor\": \"gpu\"}" > ${PROJ_DIR}/args_labeling.json
fractal task add-subtask $WF_ID "Cellpose Segmentation" --args-file ${PROJ_DIR}/args_labeling.json

fractal task add-subtask $WF_ID "Replicate Zarr structure"

fractal task add-subtask $WF_ID "Maximum Intensity Projection"

# Apply workflow
fractal task apply $PRJ_ID $DS_IN_ID $DS_OUT_ID $WF_ID
