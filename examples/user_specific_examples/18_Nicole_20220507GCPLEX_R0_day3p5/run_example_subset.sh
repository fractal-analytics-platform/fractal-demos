###############################################################################
# THINGS TO BE CHANGED BY THE USER
LABEL="nicole-CGPLEX-subset-v4"

# For FMI: needs to point to the liberali group folder
DATA_BASE_PATH="TBD"

INPUT_PATH=$DATA_BASE_PATH"Fractal_Dev/test_datasets/FMI/3_manyZplanes_20220507GCPLEX_R0"

# Change cache directory or add proxy settings if necessary
WORKER_INIT="\
export CELLPOSE_LOCAL_MODELS_PATH=${HOME}/.cache/CELLPOSE_LOCAL_MODELS_PATH
export NUMBA_CACHE_DIR=${HOME}/.cache/NUMBA_CACHE_DIR
"
###############################################################################

# Adapt to settings to where you run the example
BASE_FOLDER_EXAMPLE=`pwd`/..

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

# Modify this to place the output somewhere else
OUTPUT_PATH=${PROJ_DIR}/output

# Create project
OUTPUT=`fractal --batch project new $PRJ_NAME $PROJ_DIR`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`
echo "PRJ_ID: $PRJ_ID"
echo "DS_IN_ID: $DS_IN_ID"

# Update dataset name/type, and add a resource
fractal dataset edit --name "$DS_IN_NAME" -t image --read-only $PRJ_ID $DS_IN_ID
fractal dataset add-resource -g "*.tif" $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID: $DS_OUT_ID"

fractal dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
fractal dataset add-resource -g "*.zarr" $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal workflow add-task $WF_ID "Create OME-Zarr structure" --args-file Parameters/create_zarr_structure.json
fractal workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr"
fractal workflow add-task $WF_ID "Copy OME-Zarr structure"
fractal workflow add-task $WF_ID "Maximum Intensity Projection"
# Add cellpose (setting parameters here because we need to set some paths in there)
echo "{\"labeling_channel\": \"A04_C01\", \"ROI_table_name\": \"FOV_ROI_table\", \"diameter_level0\": 1000, \"cellprob_threshold\": -1.0, \"flow_threshold\": 0.6, \"label_name\": \"organoids\", \"pretrained_model\": \"$DATA_BASE_PATH/Fractal_Dev/models/Hummingbird.331986\"}" > Parameters/cellpose_segmentation.json
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/cellpose_segmentation.json --meta-file Parameters/meta_cellpose.json
# Add napari workflow (setting parameters here because we need to set some paths in there)
echo "{\"level\": 0, \"ROI_table_name\": \"FOV_ROI_table\", \"workflow_file\": \"$PROJ_DIR/../regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"channel\": \"A04_C01\"},\"label_img\": {\"type\": \"label\", \"label_name\": \"organoids\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"organoids\"}}}" > Parameters/measurement.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/measurement.json

# Look at the current workflows
fractal workflow show $WF_ID
echo

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID --worker-init "$WORKER_INIT"
