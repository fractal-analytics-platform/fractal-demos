# Register user (this step will change in the future)
curl -d '{"email":"test@me.com", "password":"test"}' -H "Content-Type: application/json" -X POST localhost:8000/auth/register
echo -e "FRACTAL_USER=test@me.com\nFRACTAL_PASSWORD=test" > .fractal.env
echo

# Set useful variables
PRJ_NAME="myproj-gridless"
DS_IN_NAME="input-ds"
DS_OUT_NAME="output-ds"
WF_NAME="WF gridless"
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -r $FRACTAL_CACHE_PATH

# Define/initialize empty folder for temporary files
TMPDIR=`pwd`/$PRJ_NAME
rm -r $TMPDIR
mkdir $TMPDIR

INPUT_PATH=/data/active/fractal/Liberali/FractalTesting20220124/gridless_Yokogawa_recording-FMI/20220316_sec_FOCM_test-R1_E2/day3/TIF
OUTPUT_PATH=/data/active/jluethi/Fractal/20220927_FMI_gridless
rm -rv $OUTPUT_PATH

TMPJSON=${TMPDIR}/tmp.json
TMPTASKS=${TMPDIR}/core_tasks.json

CMD="fractal"
CMD_JSON="python aux_extract_from_simple_json.py $TMPJSON"
$CMD task list > $TMPTASKS

# Create project
$CMD -j project new $PRJ_NAME $TMPDIR > $TMPJSON
PRJ_ID=`$CMD_JSON id`
DS_IN_ID=`$CMD_JSON id`
echo "PRJ_ID: $PRJ_ID"
echo "DS_IN_ID: $DS_IN_ID"

# Update dataset name/type, and add a resource
$CMD dataset edit --name "$DS_IN_NAME" -t image --read-only $PRJ_ID $DS_IN_ID
$CMD dataset add-resource -g "*.tif" $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`$CMD --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
$CMD dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
$CMD dataset add-resource -g "*.zarr" $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`$CMD --batch task new "$WF_NAME" workflow image zarr`
echo "WF_ID: $WF_ID"

# Add subtasks

echo "{\"num_levels\": 5, \"coarsening_xy\": 2, \"channel_parameters\": {\"A01_C01\": {\"label\": \"C01\",\"colormap\": \"00FFFF\",\"start\": 110,\"end\": 2000}}}" > ${TMPDIR}/args_create.json
$CMD task add-subtask $WF_ID "Create OME-ZARR structure" --args-file ${TMPDIR}/args_create.json

$CMD task add-subtask $WF_ID "Yokogawa to Zarr"

echo "{\"executor\": \"cpu-low\"}" > ${TMPDIR}/args_replicate.json
$CMD task add-subtask $WF_ID "Replicate Zarr structure" --args-file ${TMPDIR}/args_replicate.json

echo "{\"executor\": \"cpu-mid\"}" > ${TMPDIR}/args_mip.json
$CMD task add-subtask $WF_ID "Maximum Intensity Projection" --args-file ${TMPDIR}/args_mip.json

# echo "{\"labeling_level\": 3, \"executor\": \"cpu-mid\", \"ROI_table_name\": \"well_ROI_table\", \"diameter_level0\": 500.0, \"cellprob_threshold\": -3.0}" > ${TMPDIR}/args_labeling.json
# $CMD task add-subtask $WF_ID "Per-FOV image labeling" --args-file ${TMPDIR}/args_labeling.json

# echo "{\"level\": 0, \"measurement_table_name\": \"organoid_measurements\", \"ROI_table_name\": \"well_ROI_table\", \"executor\": \"cpu-mid\", \"workflow_file\": \"/data/homes/jluethi/fractal_3repo/fractal/examples/05_10x10_test_constant_z/regionprops_from_existing_labels_feature.yaml\"}" > ${TMPDIR}/args_measurement.json
# $CMD task add-subtask $WF_ID "Measurement" --args-file ${TMPDIR}/args_measurement.json

# Apply workflow
$CMD task apply $PRJ_ID $DS_IN_ID $DS_OUT_ID $WF_ID
