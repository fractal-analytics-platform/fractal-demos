# For the demo: Run everything as the current user
USERNAME="$(whoami)"
PORT=8001
echo -e "FRACTAL_USER=$USERNAME@me.com\nFRACTAL_PASSWORD=test\nFRACTAL_SERVER=http://localhost:$PORT" > .fractal.env

###############################################################################
# THINGS TO BE CHANGED BY THE USER
# Adapt to settings to where you run the example
BASE_FOLDER_EXAMPLE="/data/homes/$USERNAME/03_fractal/fractal-demos/examples"
###############################################################################


LABEL="zebrafish_subset"

###############################################################################
# IMPORTANT: modify the following lines, depending on your preferences
# 1. They MUST include a `cd` command to a path where your user can write. The
#    simplest is to use `cd $HOME`, but notice that this will create many sh
#    scripts in your folder. You can also use `cd $HOME/.fractal_scripts`, but
#    first make sure that such folder exists
# 2. They MAY include additional commands to load a python environment. The ones
#    used in the current example are appropriate for the UZH Pelkmans lab setup.
TARGET_DIR=~/.tmp_fractal
rm -r $TARGET_DIR
mkdir $TARGET_DIR
WORKER_INIT="\
export HOME=$HOME; \
cd $TARGET_DIR; \
source /opt/easybuild/software/Anaconda3/2019.07/etc/profile.d/conda.sh; \
conda activate /data/homes/fractal/sharedfractal; \
"
###############################################################################

# Set useful variables
PRJ_NAME="proj-"$USERNAME"-"$LABEL
DS_IN_NAME="input-ds-"$USERNAME"-"$LABEL
DS_OUT_NAME="output-ds-"$USERNAME"-"$LABEL
WF_NAME="WF-2x2-"$USERNAME"-"$LABEL

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -v ${FRACTAL_CACHE_PATH}/session
rm -v ${FRACTAL_CACHE_PATH}/tasks

# Define/initialize empty project folder and temporary file
PROJ_DIR=$BASE_FOLDER_EXAMPLE/tmp_${LABEL}
rm -r $PROJ_DIR
mkdir $PROJ_DIR
TMPJSON=${PROJ_DIR}/tmp.json

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH="/data/active/fractal/3D/PelkmansLab/zebrafish_subset_renamed/"
OUTPUT_PATH='/data/active/jluethi/Fractal/20221108-zebrafish-subset/'
###############################################################################

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
fractal dataset add-resource -g "*.tif" $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
fractal dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
fractal dataset add-resource -g "*.zarr" $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch task new "$WF_NAME" workflow image zarr`
echo "WF_ID: $WF_ID"

# Add subtasks

echo "{\"num_levels\": 5, \"executor\": \"cpu-low\", \"coarsening_xy\": 2, \"channel_parameters\": {\"A01_C01\": {\"label\": \"Channel 1\",\"colormap\": \"00FFFF\",\"start\": 110,\"end\": 200 }, \"A02_C02\": {\"label\": \"Channel 2\",\"colormap\": \"FF00FF\",\"start\": 110,\"end\": 250 }, \"A03_C03\": {\"label\": \"Channel 3\",\"colormap\": \"FFFF00\",\"start\": 110,\"end\": 1000 }}}" > ${PROJ_DIR}/args_create.json
fractal task add-subtask $WF_ID "Create OME-ZARR structure" --args-file ${PROJ_DIR}/args_create.json

echo "{\"executor\": \"cpu-mid\"}" > ${PROJ_DIR}/args_yoko.json
fractal task add-subtask $WF_ID "Yokogawa to Zarr" > ${PROJ_DIR}/args_yoko.json

echo "{\"labeling_level\": 2, \"executor\": \"gpu\", \"ROI_table_name\": \"FOV_ROI_table\"}" > ${PROJ_DIR}/args_labeling.json
fractal task add-subtask $WF_ID "Cellpose Segmentation" --args-file ${PROJ_DIR}/args_labeling.json

echo "{\"executor\": \"cpu-low\"}" > ${PROJ_DIR}/args_replicate.json
fractal task add-subtask $WF_ID "Replicate Zarr structure" --args-file ${PROJ_DIR}/args_replicate.json

echo "{\"executor\": \"cpu-low\"}" > ${PROJ_DIR}/args_mip.json
fractal task add-subtask $WF_ID "Maximum Intensity Projection" --args-file ${PROJ_DIR}/args_mip.json

echo "{\"labeling_level\": 2, \"executor\": \"gpu\", \"ROI_table_name\": \"well_ROI_table\", \"diameter_level0\": 1200.0, \"cellprob_threshold\": -1.0, \"flow_threshold\":  0.6}" > ${PROJ_DIR}/args_labeling2.json
fractal task add-subtask $WF_ID "Cellpose Segmentation" --args-file ${PROJ_DIR}/args_labeling2.json

# Measurement wasn't successful, I didn't debug this yet
# echo "{\"level\": 0, \"measurement_table_name\": \"nuclei\", \"executor\": \"cpu-high\", \"ROI_table_name\": \"well_ROI_table\", \"workflow_file\": \"$BASE_FOLDER_EXAMPLE/11_zebrafish_subset/regionprops_from_existing_labels_feature.yaml\"}" > ${PROJ_DIR}/args_measurement.json
# fractal task add-subtask $WF_ID "Measurement" --args-file ${PROJ_DIR}/args_measurement.json

# Apply workflow
fractal task apply $PRJ_ID $DS_IN_ID $DS_OUT_ID $WF_ID --worker_init "$WORKER_INIT"