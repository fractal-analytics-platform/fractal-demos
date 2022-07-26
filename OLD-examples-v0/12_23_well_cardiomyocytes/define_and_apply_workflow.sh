# Register user (this step will change in the future)
curl -d '{"email":"test@me.com", "password":"test"}' -H "Content-Type: application/json" -X POST localhost:8000/auth/register
echo

# Set useful variables
PRJ_NAME="myproj-23-well"
DS_IN_NAME="input-ds"
DS_OUT_NAME="output-ds"
WF_NAME="WF 23 well"

# Define/initialize empty folder for temporary files
TMPDIR=`pwd`/$PRJ_NAME
rm -r $TMPDIR
mkdir $TMPDIR

INPUT_PATH=/data/active/jluethi/20200810-CardiomyocyteDifferentiation14/Cycle1/images_renamed
OUTPUT_PATH=/data/active/jluethi/Fractal/20220929_23well_Cardiomyocytes
rm -rv $OUTPUT_PATH

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
echo "{\"num_levels\": 5, \"coarsening_xy\": 2, \"executor\": \"cpu-mid\", \"channel_parameters\": {\"A01_C01\": {\"label\": \"DAPI\",\"colormap\": \"00FFFF\",\"start\": 110,\"end\": 800 }, \"A01_C02\": {\"label\": \"nanog\",\"colormap\": \"FF00FF\",\"start\": 110,\"end\": 290 }, \"A02_C03\": {\"label\": \"Lamin B1\",\"colormap\": \"FFFF00\",\"start\": 110,\"end\": 1600 }}}" > ${TMPDIR}/args_create.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_create.json

SUBTASK_ID=`$CMD_CORE_TASKS "Yokogawa to Zarr"`
echo "{\"executor\": \"cpu-mid\"}" > ${TMPDIR}/args_yoko.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_yoko.json

SUBTASK_ID=`$CMD_CORE_TASKS "Illumination correction"`
echo "{\"overwrite\": true, \"executor\": \"cpu-mid\", \"dict_corr\": {\"root_path_corr\": \"/data/active/fractal/3D/PelkmansLab/IlluminationCorrection_Matrices_UZH/\", \"A01_C01\": \"20220621_UZH_manual_illumcorr_40x_A01_C01.tif\", \"A01_C02\": \"20220621_UZH_manual_illumcorr_40x_A01_C02.tif\", \"A02_C03\": \"20220621_UZH_manual_illumcorr_40x_A02_C03.tif\"}}" > ${TMPDIR}/args_illum.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_illum.json

SUBTASK_ID=`$CMD_CORE_TASKS "Replicate Zarr structure"`
echo "{\"executor\": \"cpu-mid\"}" > ${TMPDIR}/args_replicate.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_replicate.json

SUBTASK_ID=`$CMD_CORE_TASKS "Maximum Intensity Projection"`
echo "{\"executor\": \"cpu-mid\"}" > ${TMPDIR}/args_mip.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_mip.json

SUBTASK_ID=`$CMD_CORE_TASKS "Cellpose Segmentation"`
echo "{\"labeling_level\": 2, \"executor\": \"cpu-high\", \"ROI_table_name\": \"well_ROI_table\"}" > ${TMPDIR}/args_labeling.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_labeling.json

SUBTASK_ID=`$CMD_CORE_TASKS "Measurement"`
echo "{\"level\": 0, \"measurement_table_name\": \"organoid_measurements\", \"ROI_table_name\": \"well_ROI_table\", \"executor\": \"cpu-high\", \"workflow_file\": \"${TMPDIR}/../regionprops_from_existing_labels_feature.yaml\"}" > ${TMPDIR}/args_measurement.json
$CMD task add-subtask $WF_ID $SUBTASK_ID --args-file ${TMPDIR}/args_measurement.json

# Apply workflow
$CMD task apply $PRJ_ID $DS_IN_ID $DS_OUT_ID $WF_ID
