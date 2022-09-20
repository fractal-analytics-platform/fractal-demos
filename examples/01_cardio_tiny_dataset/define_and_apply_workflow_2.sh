# Register user (this step will change in the future)
#http POST localhost:8000/auth/register email=test@me.com password=test

# Set useful variables
PRJ_NAME="myproj-2"
DS_IN_NAME="input-ds-2"
DS_OUT_NAME="output-ds-2"
WF_NAME="My workflow 2"


# Define/initialize empty folder for temporary files
TMPDIR=`pwd`/$PRJ_NAME
rm -r $TMPDIR
mkdir $TMPDIR
TMPJSON=${TMPDIR}/tmp.json
TMPTASKS=${TMPDIR}/core_tasks.json

INPUT_PATH=../images/10.5281_zenodo.7059515
OUTPUT_PATH=${TMPDIR}/output

CMD="fractal"
CMD_JSON="poetry run python aux_extract_from_simple_json.py $TMPJSON"
CMD_CORE_TASKS="poetry run python aux_extract_id_for_core_task.py $TMPTASKS"
$CMD task list > $TMPTASKS

# Create project
$CMD -j project new $PRJ_NAME $TMPDIR > $TMPJSON
PRJ_ID=`$CMD_JSON id`
DS_IN_ID=`$CMD_JSON id`
echo "PRJ_ID: $PRJ_ID"
echo "DS_IN_ID: $DS_IN_ID"

# Update dataset name/type, and add a resource
$CMD dataset edit --name "$DS_IN_NAME" -t image --read-only $PRJ_ID $DS_IN_ID
$CMD dataset add-resource -g "*.png" $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`$CMD --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
$CMD dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
$CMD dataset add-resource -g "*.zarr" $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`$CMD --batch task new "$WF_NAME" workflow image zarr`
echo "WF_ID: $WF_ID"

# Add subtasks

SUBTASK_ID=`$CMD_CORE_TASKS "Create OME-ZARR structure"`
echo "{\"num_levels\": 5, \"coarsening_xy\": 2, \"channel_parameters\": {\"A01_C01\": {\"label\": \"DAPI\",\"colormap\": \"00FFFF\",\"start\": 110,\"end\": 800 }, \"A01_C02\": {\"label\": \"nanog\",\"colormap\": \"FF00FF\",\"start\": 110,\"end\": 290 }, \"A02_C03\": {\"label\": \"Lamin B1\",\"colormap\": \"FFFF00\",\"start\": 110,\"end\": 1600 }}}" > ${TMPDIR}/args_create.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_create.json

SUBTASK_ID=`$CMD_CORE_TASKS "Yokogawa to Zarr"`
$CMD task add-subtask $WF_ID $SUBTASK_ID

SUBTASK_ID=`$CMD_CORE_TASKS "Per-FOV image labeling"`
echo "{\"labeling_level\": 4}" > ${TMPDIR}/args_labeling.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_labeling.json

SUBTASK_ID=`$CMD_CORE_TASKS "Replicate Zarr structure"`
$CMD task add-subtask $WF_ID $SUBTASK_ID

SUBTASK_ID=`$CMD_CORE_TASKS "Maximum Intensity Projection"`
$CMD task add-subtask $WF_ID $SUBTASK_ID

# Apply workflow
$CMD task apply $PRJ_ID $DS_IN_ID $DS_OUT_ID $WF_ID
