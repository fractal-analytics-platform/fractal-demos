LABEL="reversed_1"

###############################################################################
# IMPORTANT: modify the following lines so that they point to the actual input paths of the data
# INPUT_PATH=/data/active/fractal/3D/PelkmansLab/CardiacMultiplexing/tiny_multiplexing
INPUT_PATH=`pwd`/../images/tiny_multiplexing
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
rm -rv ${FRACTAL_CACHE_PATH} 2> /dev/null

###############################################################################

# Create project
PROJECT_ID=`fractal --batch project new $PROJECT_NAME`
echo "PROJECT_ID: $PROJECT_ID"

# Add input dataset, and add three resources to it
DS_IN_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_IN_NAME" --type image --make-read-only`
echo "DS_IN_ID: $DS_IN_ID"
fractal dataset add-resource $PROJECT_ID $DS_IN_ID $INPUT_PATH/cycle3
fractal dataset add-resource $PROJECT_ID $DS_IN_ID $INPUT_PATH/cycle2
fractal dataset add-resource $PROJECT_ID $DS_IN_ID $INPUT_PATH/cycle1

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_OUT_NAME" --type zarr`
echo "DS_OUT_ID: $DS_OUT_ID"
fractal dataset add-resource $PROJECT_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PROJECT_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Create OME-ZARR structure (multiplexing)" --args-file Parameters/create_zarr_structure_multiplex_reversed.json  --meta-file Parameters/example_meta.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Convert Yokogawa to OME-Zarr"
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Copy OME-Zarr structure" --args-file Parameters/copy_ome_zarr.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Maximum Intensity Projection"
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Calculate registration (image-based)" --args-file Parameters/calculate_registration.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Apply Registration to ROI Tables"
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Apply Registration to Image" --args-file Parameters/apply_registration_to_image.json

# Apply workflow
fractal workflow apply $PROJECT_ID $WF_ID $DS_IN_ID $DS_OUT_ID
