# Register user (this step will change in the future)
curl -d '{"email":"test@me.com", "password":"test"}' -H "Content-Type: application/json" -X POST localhost:8000/auth/register

# Set useful variables
PRJ_NAME="myproj-10w-5x5"
DS_IN_NAME="input-ds"
DS_OUT_NAME="output-ds"
WF_NAME="WF 10w-5x5"

# Define/initialize empty folder for temporary files
TMPDIR=`pwd`/$PRJ_NAME
rm -r $TMPDIR
mkdir $TMPDIR

INPUT_PATH=/data/active/fractal/3D/PelkmansLab/CardiacMultiplexing/Cycle1_5x5_10wells_constantZ
OUTPUT_PATH=/data/active/fractal/tests/20220920_10well_5x5

TMPJSON=${TMPDIR}/tmp.json
TMPTASKS=${TMPDIR}/core_tasks.json

CMD="fractal"
CMD_JSON="python aux_extract_from_simple_json.py $TMPJSON"
CMD_CORE_TASKS="python aux_extract_id_for_core_task.py $TMPTASKS"
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

SUBTASK_ID=`$CMD_CORE_TASKS "Cellpose Segmentation"`
echo "{\"labeling_level\": 1, \"executor\": \"gpu\"}" > ${TMPDIR}/args_labeling.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_labeling.json

SUBTASK_ID=`$CMD_CORE_TASKS "Replicate Zarr structure"`
$CMD task add-subtask $WF_ID $SUBTASK_ID

SUBTASK_ID=`$CMD_CORE_TASKS "Maximum Intensity Projection"`
$CMD task add-subtask $WF_ID $SUBTASK_ID

# Apply workflow
$CMD task apply $PRJ_ID $DS_IN_ID $DS_OUT_ID $WF_ID
