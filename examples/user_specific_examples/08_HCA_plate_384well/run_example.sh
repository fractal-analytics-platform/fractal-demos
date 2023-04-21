LABEL="HCA_Plate_mainCluster_F016-4"

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../../00_user_setup/.fractal.env .fractal.env

DATABASEPATH=TBD

# Initialization for some environment variables for the worker
# Needed on clusters where users don't have write access to the conda env and 
# fractal user cache directories
BASE_CACHE_DIR=${HOME}/.cache
WORKER_INIT="\
export CELLPOSE_LOCAL_MODELS_PATH=$BASE_CACHE_DIR/CELLPOSE_LOCAL_MODELS_PATH
export NUMBA_CACHE_DIR=$BASE_CACHE_DIR/NUMBA_CACHE_DIR
export NAPARI_CONFIG=$BASE_CACHE_DIR/napari_config.json
export XDG_CONFIG_HOME=$BASE_CACHE_DIR/XDG_CONFIG
export XDG_CACHE_HOME=$BASE_CACHE_DIR/XDG
"

# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH} 2> /dev/null

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=${DATABASEPATH}Users/kahnmaur/1_Data/1_Imaging/211123_HCA_1-2_Take2/D8_R1/TIF
OUTPUT_PATH=${DATABASEPATH}Users/luetjoel/Fractal/HCA_$LABEL
###############################################################################

# Create project
OUTPUT=`fractal --batch project new $PRJ_NAME`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`
echo "PRJ_ID: $PRJ_ID"
echo "DS_IN_ID: $DS_IN_ID"

# Update dataset name/type, and add a resource
fractal dataset edit --new-name "$DS_IN_NAME" --new-type image --make-read-only $PRJ_ID $DS_IN_ID
fractal dataset add-resource $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID: $DS_OUT_ID"

fractal dataset edit --new-type zarr --remove-read-only $PRJ_ID $DS_OUT_ID
fractal dataset add-resource $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal workflow add-task $WF_ID "Create OME-Zarr structure" --args-file Parameters/create_zarr_structure.json --meta-file Parameters/create_ome_zarr_meta.json
fractal workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr"

fractal workflow add-task $WF_ID "Copy OME-Zarr structure"
fractal workflow add-task $WF_ID "Maximum Intensity Projection"

# Organoid segmentation
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/cellpose_segmentation_overlap.json

echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"organoids\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"organoids\"}}}" > Parameters/measurement.json
fractal workflow add-task $WF_ID "Napari workflows wrapper"

# Look at the current workflows
# fractal workflow show $WF_ID
# echo

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID --worker-init "$WORKER_INIT"
