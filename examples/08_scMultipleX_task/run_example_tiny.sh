LABEL="cardiac-tiny-scmultiplex2"

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH=`pwd`/../images/10.5281_zenodo.8287221/
OUTPUT_PATH=`pwd`/tmp_$LABEL
###############################################################################

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Set useful variables
PROJECT_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH}  2> /dev/null

###############################################################################

# Create project
PROJECT_ID=`fractal --batch project new $PROJECT_NAME`
echo "PROJECT_ID: $PROJECT_ID"

# Add input dataset, and add a resource to it
DS_IN_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_IN_NAME" --type image --make-read-only`
echo "DS_IN_ID: $DS_IN_ID"
fractal dataset add-resource $PROJECT_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_OUT_NAME" --type zarr`
echo "DS_OUT_ID: $DS_OUT_ID"
fractal dataset add-resource $PROJECT_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PROJECT_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Create OME-Zarr structure" --args-file Parameters_tiny/args_create_ome_zarr.json --meta-file Parameters_tiny/example_meta.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Convert Yokogawa to OME-Zarr"
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Copy OME-Zarr structure" --args-file Parameters_tiny/copy_ome_zarr.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Maximum Intensity Projection"
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Cellpose Segmentation" --args-file Parameters_tiny/args_cellpose_segmentation.json --meta-file Parameters_tiny/cellpose_meta.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "scMultipleX Measurements" --args-file Parameters_tiny/scmultiplex.json

# Apply workflow
fractal workflow apply $PROJECT_ID $WF_ID $DS_IN_ID $DS_OUT_ID