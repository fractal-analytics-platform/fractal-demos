fractal task check-collection
LABEL="cardio_tiny"

###############################################################################
# THINGS TO BE CHANGED BY THE USER
# Adapt to settings to where you run the example
BASE_FOLDER_EXAMPLE=`pwd`/..
###############################################################################

###############################################################################
# IMPORTANT: modify the following lines, depending on your preferences
# 1. They MUST include a `cd` command to a path where your user can write. The
#    simplest is to use `cd $HOME`, but notice that this will create many sh
#    scripts in your folder. You can also use `cd $HOME/.fractal_scripts`, but
#    first make sure that such folder exists
# 2. They MAY include additional commands to load a python environment. The ones
#    used in the current example are appropriate for the UZH setup.
WORKER_INIT="\
export HOME=$HOME; \
cd $HOME; \
"
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

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=$BASE_FOLDER_EXAMPLE/images/10.5281_zenodo.7059515
OUTPUT_PATH=${PROJ_DIR}/output
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
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add subtasks
# 1 -> create_zarr_structure
# 2 -> yokogawa_to_zarr
echo "{\"num_levels\": 5, \"coarsening_xy\": 2, \"channel_parameters\": {\"A01_C01\": {\"label\": \"DAPI\",\"colormap\": \"00FFFF\",\"start\": 110,\"end\": 800 }, \"A01_C02\": {\"label\": \"nanog\",\"colormap\": \"FF00FF\",\"start\": 110,\"end\": 290 }, \"A02_C03\": {\"label\": \"Lamin B1\",\"colormap\": \"FFFF00\",\"start\": 110,\"end\": 1600 }}}" > ${PROJ_DIR}/args_create.json
#fractal workflow add-task 1 1 --args-file ${PROJ_DIR}/args_create.json

#fractal workflow add-task 1 2

# fractal task add-subtask $WF_ID "Replicate Zarr structure"

# fractal task add-subtask $WF_ID "Maximum Intensity Projection"

# echo "{\"labeling_level\": 3, \"executor\": \"cpu-low\"}" > ${PROJ_DIR}/args_labeling.json
# fractal task add-subtask $WF_ID "Cellpose Segmentation" --args-file ${PROJ_DIR}/args_labeling.json

# Apply workflow
# fractal task apply $PRJ_ID $DS_IN_ID $DS_OUT_ID $WF_ID --worker_init "$WORKER_INIT"
