# For the demo: Run everything as the current user
USERNAME="$(whoami)"
PORT=8001
echo -e "FRACTAL_USER=$USERNAME@me.com\nFRACTAL_PASSWORD=test\nFRACTAL_SERVER=http://localhost:$PORT" > .fractal.env

###############################################################################
# THINGS TO BE CHANGED BY THE USER
# Adapt to settings to where you run the example
BASE_FOLDER_EXAMPLE="/data/homes/$USERNAME/fractal-demos/demo-november-2022"
###############################################################################


LABEL="cardio_2x2"

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

# Set useful variables. Project names must be unique per user 
# (so if you rerun this script without deleting the output, change that)
PRJ_NAME="proj-"$USERNAME
DS_IN_NAME="input-ds-"$USERNAME
DS_OUT_NAME="output-ds-"$USERNAME
WF_NAME="WF-2x2-"$USERNAME

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -v ${FRACTAL_CACHE_PATH}/session
rm -v ${FRACTAL_CACHE_PATH}/tasks

# Define/initialize empty project folder and temporary file
# If you want to use this script in production, make sure you define 
# input & output paths explicitly and don't remove the $PROJ_DIR anymore
PROJ_DIR=$BASE_FOLDER_EXAMPLE/output_${LABEL}
rm -r $PROJ_DIR
mkdir $PROJ_DIR
TMPJSON=${PROJ_DIR}/tmp.json

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=$BASE_FOLDER_EXAMPLE/images/10.5281_zenodo.7057076
OUTPUT_PATH=${PROJ_DIR}/
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
fractal dataset add-resource -g "*.png" $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
fractal dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
fractal dataset add-resource -g "*.zarr" $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch task new "$WF_NAME" workflow image zarr`
echo "WF_ID: $WF_ID"

# Add subtasks

echo "{\"num_levels\": 5, \"executor\": \"cpu-low\", \"coarsening_xy\": 2, \"channel_parameters\": {\"A01_C01\": {\"label\": \"DAPI\",\"colormap\": \"00FFFF\",\"start\": 50,\"end\": 700 }, \"A01_C02\": {\"label\": \"nanog\",\"colormap\": \"FF00FF\",\"start\": 20,\"end\": 200 }, \"A02_C03\": {\"label\": \"Lamin B1\",\"colormap\": \"FFFF00\",\"start\": 50,\"end\": 1500 }}}" > ${PROJ_DIR}/args_create.json
fractal task add-subtask $WF_ID "Create OME-ZARR structure" --args-file ${PROJ_DIR}/args_create.json

echo "{\"executor\": \"cpu-low\"}" > ${PROJ_DIR}/args_yoko.json
fractal task add-subtask $WF_ID "Yokogawa to Zarr" > ${PROJ_DIR}/args_yoko.json

# Paths of illumination correction images need to be accessible on the server.
# This works if one runs the client from the same machine as the server. Otherwise, change `root_path_corr`
echo "{\"overwrite\": true, \"executor\": \"cpu-low\", \"dict_corr\": {\"root_path_corr\": \"$BASE_FOLDER_EXAMPLE/illum_corr_images/\", \"A01_C01\": \"20220621_UZH_manual_illumcorr_40x_A01_C01.png\", \"A01_C02\": \"20220621_UZH_manual_illumcorr_40x_A01_C02.png\", \"A02_C03\": \"20220621_UZH_manual_illumcorr_40x_A02_C03.png\"}}" > ${PROJ_DIR}/args_illum.json
fractal task add-subtask $WF_ID "Illumination correction" --args-file ${PROJ_DIR}/args_illum.json

echo "{\"executor\": \"cpu-low\"}" > ${PROJ_DIR}/args_replicate.json
fractal task add-subtask $WF_ID "Replicate Zarr structure" --args-file ${PROJ_DIR}/args_replicate.json

echo "{\"executor\": \"cpu-low\"}" > ${PROJ_DIR}/args_mip.json
fractal task add-subtask $WF_ID "Maximum Intensity Projection" --args-file ${PROJ_DIR}/args_mip.json

echo "{\"labeling_level\": 2, \"executor\": \"cpu-mid\", \"ROI_table_name\": \"well_ROI_table\"}" > ${PROJ_DIR}/args_labeling.json
fractal task add-subtask $WF_ID "Cellpose Segmentation" --args-file ${PROJ_DIR}/args_labeling.json

echo "{\"level\": 0, \"measurement_table_name\": \"nuclei\", \"executor\": \"cpu-mid\", \"ROI_table_name\": \"well_ROI_table\",\"workflow_file\": \"$BASE_FOLDER_EXAMPLE/example_2x2_cardio_uzh/regionprops_from_existing_labels_feature.yaml\"}" > ${PROJ_DIR}/args_measurement.json
fractal task add-subtask $WF_ID "Measurement" --args-file ${PROJ_DIR}/args_measurement.json

# Apply workflow
fractal task apply $PRJ_ID $DS_IN_ID $DS_OUT_ID $WF_ID --worker_init "$WORKER_INIT"