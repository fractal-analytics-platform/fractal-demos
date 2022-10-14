LABEL="dummy"

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

# Set input/output paths
INPUT_PATH=/tmp
OUTPUT_PATH=${PROJ_DIR}/output

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
fractal dataset edit -t none --read-write $PRJ_ID $DS_OUT_ID
fractal dataset add-resource -g "*.json" $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch task new "$WF_NAME" workflow image zarr`
echo "WF_ID: $WF_ID"

# Add subtasks
echo "{\"message\": \"bottle\", \"index\": 1}" > ${PROJ_DIR}/args_tmp.json
fractal task add-subtask $WF_ID "dummy" --args-file ${PROJ_DIR}/args_tmp.json

# Apply workflow
fractal task apply $PRJ_ID $DS_IN_ID $DS_OUT_ID $WF_ID
