LABEL='multiplexing_reversed_v3'

###############################################################################
# THINGS TO BE CHANGED BY THE USER
# Adapt to settings to where you run the example
BASE_FOLDER_EXAMPLE=`pwd`/..
###############################################################################

###############################################################################
# IMPORTANT: modify the following lines, depending on your preferences
# 1. They MUST include a `cd` command to a path where your user can write. The
#    simplest is to use `cd $HOME`, but notice that this will create many sh
#    scripts in your folder. You can also use `cd $HOME/fractal_parsl_scripts`,
#    but first make sure that such folder exists
# 2. They MAY include additional commands to load a python environment. The ones
#    used in the current example are appropriate for the UZH setup.
WORKER_INIT="\
export HOME=$HOME; \
mkdir -p $HOME/fractal_parsl_scripts; \
cd $HOME/fractal_parsl_scripts; \
"
###############################################################################


# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH}

# Define/initialize empty project folder and temporary file
PROJ_DIR=`pwd`/tmp_${LABEL}
rm -r $PROJ_DIR
mkdir $PROJ_DIR

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
# FIXME: replace INPUT_PATH with an actual path
#INPUT_PATH=$BASE_FOLDER_EXAMPLE/images/tiny_multiplexing
INPUT_PATH=/data/active/fractal/3D/PelkmansLab/CardiacMultiplexing/tiny_multiplexing
OUTPUT_PATH=${PROJ_DIR}/output
###############################################################################

# Create project
OUTPUT=`fractal --batch project new $PRJ_NAME $PROJ_DIR`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`
echo "PRJ_ID: $PRJ_ID"
echo "DS_IN_ID: $DS_IN_ID"

# Update dataset name/type, and add a resource
fractal dataset edit --name "$DS_IN_NAME" -t image --read-only $PRJ_ID $DS_IN_ID
fractal dataset add-resource -g "*.png" $PRJ_ID $DS_IN_ID $INPUT_PATH/cycle3
fractal dataset add-resource -g "*.png" $PRJ_ID $DS_IN_ID $INPUT_PATH/cycle2
fractal dataset add-resource -g "*.png" $PRJ_ID $DS_IN_ID $INPUT_PATH/cycle1

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID: $DS_IN_ID"

fractal dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
fractal dataset add-resource -g "*.zarr" $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
# Check the IDs! Those only work if they are the only ones that were registered
# 1 -> create_zarr_structure
# 2 -> yokogawa_to_zarr
# 3 -> Replicate Zarr structure
# 4 -> Maximum Intensity Projection
# 5 -> Cellpose Segmentation
# 6 -> Measurement -> to be deprecated
# 7 -> Illumination correction
# 8 -> Napari workflows wrapper
# 9 -> Create OME-ZARR structure (multiplexing)
fractal workflow add-task $WF_ID 9 --args-file Parameters/create_zarr_structure_multiplex_reversed.json
fractal workflow add-task $WF_ID 2
fractal workflow add-task $WF_ID 3
fractal workflow add-task $WF_ID 4

# Look at the current workflows
fractal workflow show $WF_ID
echo

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID --worker-init "$WORKER_INIT"
